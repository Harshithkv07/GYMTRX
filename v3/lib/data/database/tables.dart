import 'package:drift/drift.dart';

/// Decides which optional fields a set offers when expanded.
/// Stored by index: only ever append new values.
enum ExerciseKind { strength, bodyweight, cardio, timed }

/// Stored by index: only ever append new values.
enum GoalKind { lift, bodyWeight }

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

// ------------------------------------------------------------- schema v2

/// A progress photo. The image lives in `<documents>/photos/[fileName]`;
/// photos can be taken on rest days, so they hang off a day, not a session.
@TableIndex(name: 'idx_progress_photos_day', columns: {#dayKey})
class ProgressPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dayKey => integer()();
  TextColumn get fileName => text().unique()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Lift targets (an exercise at [targetKg] × [targetReps]) and the
/// body-weight target. Session-count goals live in settings.
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get kind => intEnum<GoalKind>()();
  IntColumn get exerciseId => integer().nullable().references(Exercises, #id, onDelete: KeyAction.cascade)();
  RealColumn get targetKg => real()();

  /// Lift goals: reps the target weight must be lifted for; null = 1.
  IntColumn get targetReps => integer().nullable()();

  /// Body-weight goals: the weight when the goal was set, for progress.
  RealColumn get startKg => real().nullable()();
  IntColumn get createdDayKey => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Set once, the first time the goal is reached.
  IntColumn get achievedDayKey => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// One training day of the weekly program; rest days have no row.
class ProgramDays extends Table {
  /// ISO weekday, 1 = Monday … 7 = Sunday.
  IntColumn get weekday => integer()();
  TextColumn get label => text()();

  @override
  Set<Column<Object>> get primaryKey => {weekday};
}

class ProgramDayGroups extends Table {
  IntColumn get weekday => integer().references(ProgramDays, #weekday, onDelete: KeyAction.cascade)();
  IntColumn get groupId => integer().references(MuscleGroups, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {weekday, groupId};
}

class ProgramDayExercises extends Table {
  IntColumn get weekday => integer().references(ProgramDays, #weekday, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {weekday, exerciseId};
}
