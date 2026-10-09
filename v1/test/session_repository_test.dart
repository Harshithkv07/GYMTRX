import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/data/database/app_database.dart';
import 'package:gymtrx/data/repositories/session_repository.dart';

void main() {
  late AppDatabase db;
  late SessionRepository repo;
  late Map<String, int> groupId;
  late Map<String, int> exerciseId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = SessionRepository(db);
    groupId = {for (final g in await db.select(db.muscleGroups).get()) g.slug!: g.id};
    exerciseId = {for (final e in await db.select(db.exercises).get()) e.name: e.id};
  });

  tearDown(() => db.close());

  test('seeds the library', () async {
    expect(groupId.keys, containsAll(['chest', 'legs', 'cardio', 'full_body']));
    expect(exerciseId, contains('Bench Press'));
  });

  test('quick capture then details later', () async {
    const day = 20261008;
    await repo.setGroupSelected(day, groupId['chest']!, true);
    await repo.setGroupSelected(day, groupId['triceps']!, true);

    var summaries = await repo.watchSummaries().first;
    expect(summaries.single.dayKey, day);
    expect(summaries.single.groupIds, hasLength(2));
    expect(summaries.single.needsDetails, isTrue);

    // Late at night: add an exercise with an optional set and a note.
    final se = await repo.addExercise(day, exerciseId['Bench Press']!);
    final setId = await repo.addSet(se);
    await repo.updateSet(setId, const ExerciseSetsCompanion(weightKg: Value(60), reps: Value(8)));
    await repo.addSet(se); // copies the previous set
    await repo.setNote(day, '  felt strong  ');

    final detail = await repo.loadEntry(day);
    expect(detail!.groups.map((g) => g.slug), ['chest', 'triceps']);
    expect(detail.exercises.single.sets, hasLength(2));
    expect(detail.exercises.single.sets.last.weightKg, 60);
    expect(detail.exercises.single.sets.last.reps, 8);
    expect(detail.session.note, 'felt strong');

    summaries = await repo.watchSummaries().first;
    expect(summaries.single.exerciseCount, 1);
    expect(summaries.single.hasNote, isTrue);
  });

  test('empty entries are pruned, non-empty ones are kept', () async {
    const day = 20261008;
    await repo.setGroupSelected(day, groupId['legs']!, true);
    await repo.setGroupSelected(day, groupId['legs']!, false);
    expect(await repo.pruneIfEmpty(day), isTrue);
    expect(await repo.loadEntry(day), isNull);

    await repo.setDuration(day, 45);
    expect(await repo.pruneIfEmpty(day), isFalse);
  });

  test('delete then undo restores everything', () async {
    const day = 20261005;
    await repo.setGroups(day, [groupId['back']!, groupId['biceps']!]);
    final se = await repo.addExercise(day, exerciseId['Pull-up']!);
    final setId = await repo.addSet(se);
    await repo.updateSet(setId, const ExerciseSetsCompanion(reps: Value(10)));
    await repo.setExerciseNote(se, 'wide grip');

    final snap = await repo.deleteEntry(day);
    expect(await repo.loadEntry(day), isNull);
    expect(await db.select(db.exerciseSets).get(), isEmpty, reason: 'sets cascade with the entry');

    await repo.restoreEntry(snap!);
    final restored = await repo.loadEntry(day);
    expect(restored!.groups, hasLength(2));
    expect(restored.exercises.single.row.note, 'wide grip');
    expect(restored.exercises.single.sets.single.reps, 10);
  });

  test('last performance looks only at earlier days with sets', () async {
    final bench = exerciseId['Bench Press']!;
    final a = await repo.addExercise(20261001, bench);
    final s = await repo.addSet(a);
    await repo.updateSet(s, const ExerciseSetsCompanion(weightKg: Value(57.5), reps: Value(8)));
    await repo.addExercise(20261004, bench); // logged without sets

    final last = await repo.lastPerformance(bench, 20261008);
    expect(last!.dayKey, 20261001);
    expect(last.sets.single.weightKg, 57.5);
    expect(await repo.lastPerformance(bench, 20261001), isNull);
  });
}
