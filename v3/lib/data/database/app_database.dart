import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'seed_data.dart';
import 'tables.dart';

export 'tables.dart' show ExerciseKind, GoalKind;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Sessions,
    MuscleGroups,
    SessionGroups,
    Exercises,
    SessionExercises,
    ExerciseSets,
    BodyWeights,
    ProgressPhotos,
    Goals,
    ProgramDays,
    ProgramDayGroups,
    ProgramDayExercises,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'gymtrx'));

  /// 1: GYMTRX 1.0 and 2.0. 2: photos, goals and the weekly program (3.0).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedLibrary(this);
    },
    onUpgrade: (m, from, to) async {
      // Never seed here: the library already exists and may be customised.
      if (from < 2) {
        await m.createTable(progressPhotos);
        await m.create(idxProgressPhotosDay);
        await m.createTable(goals);
        await m.createTable(programDays);
        await m.createTable(programDayGroups);
        await m.createTable(programDayExercises);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Tables whose changes affect what an entry looks like.
  List<TableInfo> get entryTables => [sessions, sessionGroups, sessionExercises, exerciseSets, exercises, muscleGroups];
}
