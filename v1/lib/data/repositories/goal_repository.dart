import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Lift targets and the body-weight target. Weekly and monthly session goals
/// are plain numbers and live in settings.
class GoalRepository {
  GoalRepository(this.db);

  final AppDatabase db;

  /// Body-weight goal first, then lifts in the order they were added.
  Stream<List<Goal>> watchAll() =>
      (db.select(db.goals)..orderBy([(g) => OrderingTerm.asc(g.sortOrder), (g) => OrderingTerm.asc(g.id)])).watch();

  Future<int> addLift({required int exerciseId, required double targetKg, int? targetReps, required int today}) async {
    final next = await db
        .customSelect('SELECT COALESCE(MAX(sort_order), 0) + 1 AS n FROM goals')
        .getSingle();
    return db
        .into(db.goals)
        .insert(
          GoalsCompanion.insert(
            kind: GoalKind.lift,
            exerciseId: Value(exerciseId),
            targetKg: targetKg,
            targetReps: Value(targetReps),
            createdDayKey: today,
            sortOrder: Value(next.read<int>('n')),
          ),
        );
  }

  /// There's only ever one body-weight goal: a new one replaces the old.
  Future<int> setBodyWeight({required double targetKg, required double? startKg, required int today}) =>
      db.transaction(() async {
        await (db.delete(db.goals)..where((g) => g.kind.equalsValue(GoalKind.bodyWeight))).go();
        return db
            .into(db.goals)
            .insert(
              GoalsCompanion.insert(
                kind: GoalKind.bodyWeight,
                targetKg: targetKg,
                startKg: Value(startKg),
                createdDayKey: today,
                sortOrder: const Value(-1),
              ),
            );
      });

  /// Editing a target starts it fresh, so a reached goal can be raised.
  Future<void> updateLift(int id, {required double targetKg, int? targetReps}) =>
      (db.update(db.goals)..where((g) => g.id.equals(id))).write(
        GoalsCompanion(targetKg: Value(targetKg), targetReps: Value(targetReps), achievedDayKey: const Value(null)),
      );

  Future<void> setAchieved(int id, int? dayKey) =>
      (db.update(db.goals)..where((g) => g.id.equals(id))).write(GoalsCompanion(achievedDayKey: Value(dayKey)));

  Future<void> remove(int id) => (db.delete(db.goals)..where((g) => g.id.equals(id))).go();

  /// Puts a removed goal back, for undo.
  Future<void> restore(Goal goal) => db.into(db.goals).insert(goal, mode: InsertMode.insertOrReplace);
}
