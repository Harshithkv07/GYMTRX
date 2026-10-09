import 'package:drift/drift.dart';

/// Decides which optional fields a set offers when expanded.
/// Stored by index: only ever append new values.
enum ExerciseKind { strength, bodyweight, cardio, timed }

/// One entry per calendar day. `dayKey` is yyyymmdd in local time.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dayKey => integer().unique()();
  TextColumn get note => text().nullable()();
  IntColumn get durationMin => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class MuscleGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Stable identifier for seeded groups (drives the body map); null for custom ones.
  TextColumn get slug => text().nullable().unique()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

@TableIndex(name: 'idx_session_groups_group', columns: {#groupId})
class SessionGroups extends Table {
  IntColumn get sessionId => integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get groupId => integer().references(MuscleGroups, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, groupId};
}

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get groupId => integer().nullable().references(MuscleGroups, #id, onDelete: KeyAction.setNull)();
  IntColumn get kind => intEnum<ExerciseKind>()();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

@TableIndex(name: 'idx_session_exercises_session', columns: {#sessionId})
@TableIndex(name: 'idx_session_exercises_exercise', columns: {#exerciseId})
class SessionExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get note => text().nullable()();
}

/// Every field is optional: sets are a detail the user may never record.
@TableIndex(name: 'idx_exercise_sets_entry', columns: {#sessionExerciseId})
class ExerciseSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionExerciseId =>
      integer().references(SessionExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSec => integer().nullable()();
  RealColumn get distanceKm => real().nullable()();
}

/// Independent of sessions: a weigh-in can happen on a rest day.
class BodyWeights extends Table {
  IntColumn get dayKey => integer()();
  RealColumn get weightKg => real()();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {dayKey};
}
