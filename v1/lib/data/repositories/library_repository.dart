import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Muscle groups and exercises. Nothing with history is ever hard-deleted;
/// it is hidden instead so past entries keep their names.
class LibraryRepository {
  LibraryRepository(this.db);

  final AppDatabase db;

  Stream<List<MuscleGroup>> watchGroups() =>
      (db.select(db.muscleGroups)..orderBy([(g) => OrderingTerm.asc(g.sortOrder), (g) => OrderingTerm.asc(g.id)]))
          .watch();

  Stream<List<Exercise>> watchExercises() =>
      (db.select(db.exercises)..orderBy([(e) => OrderingTerm.asc(e.name)])).watch();

  Future<int> addGroup(String name) async {
    final next = await db
        .customSelect('SELECT COALESCE(MAX(sort_order), -1) + 1 AS p FROM muscle_groups')
        .getSingle();
    return db
        .into(db.muscleGroups)
        .insert(
          MuscleGroupsCompanion.insert(
            name: name.trim(),
            sortOrder: Value(next.read<int>('p')),
            isCustom: const Value(true),
          ),
        );
  }

  Future<void> renameGroup(int id, String name) => (db.update(db.muscleGroups)..where((g) => g.id.equals(id)))
      .write(MuscleGroupsCompanion(name: Value(name.trim())));

  Future<void> setGroupHidden(int id, bool hidden) => (db.update(db.muscleGroups)..where((g) => g.id.equals(id)))
      .write(MuscleGroupsCompanion(hidden: Value(hidden)));

  Future<void> reorderGroups(List<int> idsInOrder) => db.batch((b) {
    for (var i = 0; i < idsInOrder.length; i++) {
      b.update(db.muscleGroups, MuscleGroupsCompanion(sortOrder: Value(i)), where: (g) => g.id.equals(idsInOrder[i]));
    }
  });

  Future<int> addExercise(String name, {int? groupId, ExerciseKind kind = ExerciseKind.strength}) => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          name: name.trim(),
          groupId: Value(groupId),
          kind: kind,
          isCustom: const Value(true),
        ),
      );

  Future<void> updateExercise(int id, {String? name, Value<int?> groupId = const Value.absent(), ExerciseKind? kind}) =>
      (db.update(db.exercises)..where((e) => e.id.equals(id))).write(
        ExercisesCompanion(
          name: name == null ? const Value.absent() : Value(name.trim()),
          groupId: groupId,
          kind: kind == null ? const Value.absent() : Value(kind),
        ),
      );

  Future<void> setExerciseHidden(int id, bool hidden) => (db.update(db.exercises)..where((e) => e.id.equals(id)))
      .write(ExercisesCompanion(hidden: Value(hidden)));
}
