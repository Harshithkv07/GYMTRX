import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/progress.dart';

/// The weekly program: which weekdays are training days and what they cover.
class ProgramRepository {
  ProgramRepository(this.db);

  final AppDatabase db;

  List<TableInfo> get _tables => [db.programDays, db.programDayGroups, db.programDayExercises];

  /// Training days keyed by ISO weekday, re-emitted on every change.
  Stream<Map<int, ProgramDayPlan>> watchProgram() async* {
    yield await loadProgram();
    await for (final _ in db.tableUpdates(TableUpdateQuery.onAllTables(_tables))) {
      yield await loadProgram();
    }
  }

  Future<Map<int, ProgramDayPlan>> loadProgram() async {
    final days = await db.select(db.programDays).get();
    final groups = await db.select(db.programDayGroups).get();
    final exercises = await (db.select(
      db.programDayExercises,
    )..orderBy([(e) => OrderingTerm.asc(e.position)])).get();
    return {
      for (final d in days)
        d.weekday: ProgramDayPlan(
          weekday: d.weekday,
          label: d.label,
          groupIds: [
            for (final g in groups)
              if (g.weekday == d.weekday) g.groupId,
          ],
          exerciseIds: [
            for (final e in exercises)
              if (e.weekday == d.weekday) e.exerciseId,
          ],
        ),
    };
  }

  Future<void> saveDay(ProgramDayPlan plan) => db.transaction(() async {
    await db
        .into(db.programDays)
        .insertOnConflictUpdate(ProgramDaysCompanion.insert(weekday: Value(plan.weekday), label: plan.label));
    await (db.delete(db.programDayGroups)..where((g) => g.weekday.equals(plan.weekday))).go();
    await (db.delete(db.programDayExercises)..where((e) => e.weekday.equals(plan.weekday))).go();
    await db.batch((b) {
      b.insertAll(db.programDayGroups, [
        for (final id in plan.groupIds) ProgramDayGroupsCompanion.insert(weekday: plan.weekday, groupId: id),
      ], mode: InsertMode.insertOrIgnore);
      b.insertAll(db.programDayExercises, [
        for (var i = 0; i < plan.exerciseIds.length; i++)
          ProgramDayExercisesCompanion.insert(weekday: plan.weekday, exerciseId: plan.exerciseIds[i], position: i),
      ], mode: InsertMode.insertOrIgnore);
    });
  });

  /// Makes [weekday] a rest day.
  Future<void> clearDay(int weekday) => (db.delete(db.programDays)..where((d) => d.weekday.equals(weekday))).go();

  Future<void> clearAll() => db.delete(db.programDays).go();
}
