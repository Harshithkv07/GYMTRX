import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/models/progress.dart';
import '../program_plan.dart';
import '../records.dart';
import '../streaks.dart';
import '../trends.dart';
import 'data_providers.dart';
import 'settings_provider.dart';

/// Every personal record, recomputed whenever a set changes.
final prIndexProvider = Provider<PrIndex>((ref) {
  final rows = ref.watch(setRecordsProvider).value;
  return rows == null ? PrIndex.empty : computePrIndex(rows);
});

/// Logged sets by id, to show the full set behind a record.
final setRecordByIdProvider = Provider<Map<int, SetRecordRow>>((ref) {
  final rows = ref.watch(setRecordsProvider).value ?? const <SetRecordRow>[];
  return {for (final r in rows) r.setId: r};
});

/// The weekly goal that applied to a given week.
final weeklyGoalForProvider = Provider<int Function(int weekKey)>((ref) {
  final (log, goal) = ref.watch(settingsProvider.select((s) => (s.weeklyGoalLog, s.weeklyGoal)));
  return goalLookup(log, goal);
});

final streakProvider = Provider<StreakStats>((ref) {
  final entries = ref.watch(summariesProvider).value;
  if (entries == null) return StreakStats.empty;
  return weeklyStreak(
    [for (final e in entries) e.dayKey],
    today: ref.watch(logicalTodayProvider),
    weekStart: ref.watch(settingsProvider.select((s) => s.weekStart)),
    goalFor: ref.watch(weeklyGoalForProvider),
  );
});

/// Sessions this month against the monthly goal (0 = no goal).
final monthProgressProvider = Provider<({int count, int goal})>((ref) {
  final entries = ref.watch(summariesProvider).value ?? const [];
  return (
    count: monthCount([for (final e in entries) e.dayKey], ref.watch(logicalTodayProvider)),
    goal: ref.watch(settingsProvider.select((s) => s.monthlyGoal)),
  );
});

@immutable
class GoalProgress {
  const GoalProgress({required this.goal, required this.fraction, this.achievedDay, this.currentKg, this.exercise});

  final Goal goal;

  /// 0..1
  final double fraction;

  /// When the target was reached; null while it hasn't been.
  final int? achievedDay;

  /// Lift goals: best weight at the target reps. Body weight: latest weigh-in.
  final double? currentKg;
  final Exercise? exercise;

  bool get achieved => achievedDay != null;
}

final goalProgressProvider = Provider<List<GoalProgress>>((ref) {
  final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
  if (goals.isEmpty) return const [];
  final rows = ref.watch(setRecordsProvider).value ?? const [];
  final exercises = ref.watch(exercisesByIdProvider);
  final weights = ref.watch(bodyWeightsProvider).value ?? const <BodyWeight>[];

  return [
    for (final g in goals)
      switch (g.kind) {
        GoalKind.lift => () {
          final reps = g.targetReps ?? 1;
          final best = bestAtReps(rows, g.exerciseId ?? -1, reps);
          final day = firstDayReaching(rows, g.exerciseId ?? -1, g.targetKg, reps);
          return GoalProgress(
            goal: g,
            fraction: best == null ? 0 : (best.kg / g.targetKg).clamp(0.0, 1.0),
            achievedDay: day,
            currentKg: best?.kg,
            exercise: exercises[g.exerciseId],
          );
        }(),
        GoalKind.bodyWeight => () {
          if (weights.isEmpty) return GoalProgress(goal: g, fraction: 0);
          final latest = weights.last;
          final start =
              g.startKg ??
              weights
                  .firstWhere((w) => w.dayKey >= g.createdDayKey, orElse: () => weights.last)
                  .weightKg;
          final p = bodyWeightGoal(startKg: start, targetKg: g.targetKg, currentKg: latest.weightKg);
          return GoalProgress(
            goal: g,
            fraction: p.fraction,
            achievedDay: p.achieved ? latest.dayKey : null,
            currentKg: latest.weightKg,
          );
        }(),
      },
  ];
});

/// How each day relates to the weekly program.
final planOfProvider = Provider<PlanStatus Function(int day)>((ref) {
  final program = ref.watch(programProvider).value ?? const {};
  final start = ref.watch(settingsProvider.select((s) => s.programStartDayKey));
  final byDay = ref.watch(summariesByDayProvider);
  final today = ref.watch(logicalTodayProvider);
  final weekdays = program.keys.toSet();
  return (day) => planStatus(
    day,
    trainingWeekdays: weekdays,
    programStart: start,
    logged: byDay.containsKey(day),
    today: today,
  );
});
