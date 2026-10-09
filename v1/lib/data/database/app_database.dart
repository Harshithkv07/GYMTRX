import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'seed_data.dart';
import 'tables.dart';

export 'tables.dart' show ExerciseKind;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Sessions, MuscleGroups, SessionGroups, Exercises, SessionExercises, ExerciseSets, BodyWeights],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'gymtrx'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedLibrary(this);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Tables whose changes affect what an entry looks like.
  List<TableInfo> get entryTables => [sessions, sessionGroups, sessionExercises, exerciseSets, exercises, muscleGroups];
}
