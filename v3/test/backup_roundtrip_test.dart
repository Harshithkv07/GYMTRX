import 'dart:convert';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/data/database/app_database.dart';
import 'package:gymtrx/data/repositories/body_weight_repository.dart';
import 'package:gymtrx/data/repositories/library_repository.dart';
import 'package:gymtrx/data/repositories/session_repository.dart';
import 'package:gymtrx/data/services/backup_service.dart';

Map<String, Object?> _comparable(String json) {
  final map = (jsonDecode(json) as Map).cast<String, Object?>()..remove('exportedAt');
  return map;
}

void main() {
  // Two independent in-memory databases on purpose (old phone, new phone).
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('export → restore into a fresh install → export gives identical data', () async {
    final a = AppDatabase(NativeDatabase.memory());
    final sessions = SessionRepository(a);
    final groups = {for (final g in await a.select(a.muscleGroups).get()) g.slug!: g.id};
    final ex = {for (final e in await a.select(a.exercises).get()) e.name: e.id};

    // A custom exercise, a hidden group shown, a couple of entries and weigh-ins.
    final custom = await LibraryRepository(a).addExercise('Landmine Press', groupId: groups['shoulders']);
    await LibraryRepository(a).setGroupHidden(groups['calves']!, false);
    await sessions.setGroups(20261001, [groups['legs']!, groups['calves']!]);
    final squat = await sessions.addExercise(20261001, ex['Squat']!);
    final s1 = await sessions.addSet(squat);
    await sessions.updateSet(s1, const ExerciseSetsCompanion(weightKg: Value(80.5), reps: Value(5)));
    await sessions.addSet(squat);
    await sessions.setNote(20261001, 'Knees felt fine');
    await sessions.setGroups(20261004, [groups['shoulders']!]);
    await sessions.addExercise(20261004, custom);
    await sessions.setDuration(20261004, 50);
    await BodyWeightRepository(a).upsert(20261001, 72.4);
    await BodyWeightRepository(a).upsert(20261003, 72.1);

    final first = await BackupService(a).export(settings: {'unit': 'kg', 'weekStart': 1});
    final parsed = BackupService.parse(first);
    expect(parsed.entryCount, 2);
    expect(parsed.weighInCount, 2);
    expect(parsed.firstDay, 20261001);
    expect(parsed.lastDay, 20261004);
    expect(parsed.settings['unit'], 'kg');

    // A fresh install (its own seed data gets replaced).
    final b = AppDatabase(NativeDatabase.memory());
    await BackupService(b).restore(parsed);
    final second = await BackupService(b).export(settings: {'unit': 'kg', 'weekStart': 1});

    expect(_comparable(second), _comparable(first));
    final restored = await SessionRepository(b).loadEntry(20261001);
    expect(restored!.session.note, 'Knees felt fine');
    expect(restored.exercises.single.sets.first.weightKg, 80.5);

    await a.close();
    await b.close();
  });

  test('rejects files that are not backups', () {
    expect(() => BackupService.parse('not json'), throwsFormatException);
    expect(() => BackupService.parse('{"format":"other"}'), throwsFormatException);
    expect(
      () => BackupService.parse('{"format":"gymtrx-backup","version":99}'),
      throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('newer'))),
    );
  });
}
