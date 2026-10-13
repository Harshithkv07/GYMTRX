import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/utils/day_key.dart';

/// The weekly streak: consecutive weeks that met the weekly session goal.
@immutable
class StreakStats {
  const StreakStats({
    required this.current,
    required this.best,
    required this.completedRun,
    required this.thisWeekCount,
    required this.thisWeekGoal,
    required this.weekStartKey,
  });

  static const empty = StreakStats(
    current: 0,
    best: 0,
    completedRun: 0,
    thisWeekCount: 0,
    thisWeekGoal: 1,
    weekStartKey: 0,
  );

  /// Weeks in a row, counting this week once its goal is met.
  final int current;
  final int best;

  /// Met weeks in a row before this one: what's at stake this week.
  final int completedRun;
  final int thisWeekCount;
  final int thisWeekGoal;

  /// First day of the current week.
  final int weekStartKey;

  bool get thisWeekMet => thisWeekCount >= thisWeekGoal;

  /// Sessions still needed this week.
  int get remaining => math.max(0, thisWeekGoal - thisWeekCount);
}

/// Resolves the weekly goal that applied to a week from the goal history.
/// Weeks before the first entry use the first goal ever set.
int Function(int weekKey) goalLookup(List<(int, int)> log, int fallback) {
  final sorted = [...log]..sort((a, b) => a.$1.compareTo(b.$1));
  return (week) {
    var goal = sorted.isEmpty ? fallback : sorted.first.$2;
    for (final (from, g) in sorted) {
      if (from > week) break;
      goal = g;
    }
    return math.max(1, goal);
  };
}

/// [today] is the logical day; sessions after it are ignored. The current
/// week only adds to the streak once met and never breaks it while it's
/// still running.
StreakStats weeklyStreak(
  Iterable<int> dayKeys, {
  required int today,
  required int weekStart,
  required int Function(int weekKey) goalFor,
}) {
  final counts = <int, int>{};
  int? earliest;
  for (final d in dayKeys) {
    if (d > today) continue;
    final w = DayKeys.weekStartOf(d, weekStart);
    counts[w] = (counts[w] ?? 0) + 1;
    if (earliest == null || w < earliest) earliest = w;
  }
  final cw = DayKeys.weekStartOf(today, weekStart);
  bool met(int w) => (counts[w] ?? 0) >= goalFor(w);

  var run = 0;
  for (var w = DayKeys.addDays(cw, -7); counts.containsKey(w) && met(w); w = DayKeys.addDays(w, -7)) {
    run++;
  }
  final current = run + (met(cw) ? 1 : 0);

  var best = current, streak = 0;
  if (earliest != null) {
    for (var w = earliest; w <= cw; w = DayKeys.addDays(w, 7)) {
      if (met(w)) {
        streak++;
        best = math.max(best, streak);
      } else if (w != cw) {
        streak = 0;
      }
    }
  }

  return StreakStats(
    current: current,
    best: best,
    completedRun: run,
    thisWeekCount: counts[cw] ?? 0,
    thisWeekGoal: goalFor(cw),
    weekStartKey: cw,
  );
}

/// Sessions logged in [today]'s month up to and including today.
int monthCount(Iterable<int> dayKeys, int today) {
  final y = DayKeys.year(today), m = DayKeys.month(today);
  var n = 0;
  for (final d in dayKeys) {
    if (d <= today && DayKeys.year(d) == y && DayKeys.month(d) == m) n++;
  }
  return n;
}

/// Streak lengths worth celebrating: 4, 8, 12, 26 and 52 weeks, then every
/// half year.
bool isStreakMilestone(int weeks) =>
    const {4, 8, 12, 26, 52}.contains(weeks) || (weeks > 52 && (weeks - 52) % 26 == 0);
