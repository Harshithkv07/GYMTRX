import 'package:flutter/foundation.dart';

import '../database/app_database.dart';

/// Lightweight view of one day's entry. Drives calendar cells, cards, the
/// heatmap, insights and the home-screen widget.
@immutable
class EntrySummary {
  const EntrySummary({
    required this.sessionId,
    required this.dayKey,
    required this.groupIds,
    required this.exerciseCount,
    required this.hasNote,
    this.durationMin,
  });

  final int sessionId;
  final int dayKey;
  final List<int> groupIds;
  final int exerciseCount;
  final bool hasNote;
  final int? durationMin;

  /// Only muscle groups so far: the "quick capture" state.
  bool get needsDetails => exerciseCount == 0;
}

@immutable
class ExerciseEntry {
  const ExerciseEntry({required this.row, required this.exercise, required this.sets});

  final SessionExercise row;
  final Exercise exercise;
  final List<ExerciseSet> sets;
}

/// Everything recorded for one day.
@immutable
class EntryDetail {
  const EntryDetail({required this.session, required this.groups, required this.exercises});

  final Session session;
  final List<MuscleGroup> groups;
  final List<ExerciseEntry> exercises;

  int get dayKey => session.dayKey;
  Set<int> get groupIds => {for (final g in groups) g.id};
}

/// A deleted entry held in memory so "Undo" can put it back.
@immutable
class EntrySnapshot {
  const EntrySnapshot({
    required this.dayKey,
    required this.note,
    required this.durationMin,
    required this.createdAt,
    required this.groupIds,
    required this.exercises,
    this.startedAt,
  });

  final int dayKey;
  final String? note;
  final int? durationMin;
  final DateTime createdAt;
  final DateTime? startedAt;
  final List<int> groupIds;
  final List<({int exerciseId, String? note, List<ExerciseSet> sets})> exercises;

  factory EntrySnapshot.of(EntryDetail d) => EntrySnapshot(
    dayKey: d.dayKey,
    note: d.session.note,
    durationMin: d.session.durationMin,
    createdAt: d.session.createdAt,
    startedAt: d.session.startedAt,
    groupIds: [for (final g in d.groups) g.id],
    exercises: [for (final e in d.exercises) (exerciseId: e.exercise.id, note: e.row.note, sets: e.sets)],
  );
}

/// How often and how recently an exercise was logged.
@immutable
class ExerciseStat {
  const ExerciseStat({required this.exercise, required this.count, required this.lastDayKey});

  final Exercise exercise;
  final int count;
  final int lastDayKey;
}

/// One day's record of a single exercise, for its history screen.
@immutable
class ExerciseHistoryItem {
  const ExerciseHistoryItem({required this.dayKey, required this.note, required this.sets});

  final int dayKey;
  final String? note;
  final List<ExerciseSet> sets;
}

/// The most recent earlier day this exercise had sets: the "last time" hint.
typedef LastPerformance = ({int dayKey, List<ExerciseSet> sets});
