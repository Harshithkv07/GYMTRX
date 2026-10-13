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
    SessionHealth,
    DailyHealth,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'gymtrx'));

  /// 1: the original log. 2: photos, goals and the weekly program.
  /// 3: start times, the exercise guide link, weigh-in sources and the
  /// Health Connect caches. Earlier builds of GYMTRX wrote 1 and 2, and
  /// Android's own backup can bring such a database back, so every step stays.
  @override
  int get schemaVersion => 3;

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
      if (from < 3) {
        await m.addColumn(sessions, sessions.startedAt);
        await m.addColumn(exercises, exercises.guideId);
        await m.addColumn(bodyWeights, bodyWeights.source);
        await m.createTable(sessionHealth);
        await m.createTable(dailyHealth);
        // Link the seeded exercises that are still around to their guide entries.
        for (final (name, _, _, guideId) in seedExercises) {
          await (update(exercises)..where((e) => e.name.equals(name) & e.isCustom.equals(false))).write(
            ExercisesCompanion(guideId: Value(guideId)),
          );
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Tables whose changes affect what an entry looks like.
  List<TableInfo> get entryTables => [sessions, sessionGroups, sessionExercises, exerciseSets, exercises, muscleGroups];
}
