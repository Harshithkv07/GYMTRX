import 'package:flutter/foundation.dart';

import '../core/utils/day_key.dart';
import '../data/database/app_database.dart';
import '../data/models/entry.dart';

/// Plain numbers. Nothing here judges: no streaks, no goals, no "missed".
@immutable
class OverviewStats {
  const OverviewStats({
    required this.thisMonth,
    required this.thisYear,
    required this.allTime,
    required this.perWeek12,
    required this.lastDayKey,
  });

  final int thisMonth;
  final int thisYear;
  final int allTime;

  /// Average sessions per week over the last 12 weeks.
  final double perWeek12;
  final int? lastDayKey;
}

OverviewStats overview(Iterable<int> dayKeys, int today) {
  final y = DayKeys.year(today), m = DayKeys.month(today);
  final from12w = DayKeys.addDays(today, -83);
  var month = 0, year = 0, all = 0, recent = 0;
  int? last;
  for (final d in dayKeys) {
    if (d > today) continue;
    all++;
    if (DayKeys.year(d) == y) {
      year++;
      if (DayKeys.month(d) == m) month++;
    }
    if (d >= from12w) recent++;
    if (last == null || d > last) last = d;
  }
  return OverviewStats(thisMonth: month, thisYear: year, allTime: all, perWeek12: recent / 12, lastDayKey: last);
}

@immutable
class GroupRecency {
  const GroupRecency({required this.group, required this.lastDayKey, required this.countInWindow});

  final MuscleGroup group;
  final int? lastDayKey;
  final int countInWindow;
}

/// When each muscle group was last trained and how often in the last
/// [window] days. Kept in chip order so the list stays put.
List<GroupRecency> groupRecency(
  List<EntrySummary> entries,
  List<MuscleGroup> groups,
  int today, {
  int window = 30,
}) {
  final from = DayKeys.addDays(today, -(window - 1));
  final last = <int, int>{};
  final counts = <int, int>{};
  for (final e in entries) {
    if (e.dayKey > today) continue;
    for (final g in e.groupIds) {
      if (e.dayKey > (last[g] ?? 0)) last[g] = e.dayKey;
      if (e.dayKey >= from) counts[g] = (counts[g] ?? 0) + 1;
    }
  }
  return [
    for (final g in groups)
      if (!g.hidden || last.containsKey(g.id))
        GroupRecency(group: g, lastDayKey: last[g.id], countInWindow: counts[g.id] ?? 0),
  ];
}

/// Sessions per calendar month, oldest first, ending with [today]'s month.
List<({YearMonth month, int count})> monthlyCounts(Iterable<int> dayKeys, int today, {int months = 12}) {
  final current = yearMonthOf(today);
  final counts = <YearMonth, int>{};
  for (final d in dayKeys) {
    final ym = yearMonthOf(d);
    counts[ym] = (counts[ym] ?? 0) + 1;
  }
  return [
    for (var i = months - 1; i >= 0; i--)
      (month: current.shift(-i), count: counts[current.shift(-i)] ?? 0),
  ];
}
