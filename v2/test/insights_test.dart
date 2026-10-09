import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/data/database/app_database.dart';
import 'package:gymtrx/data/models/entry.dart';
import 'package:gymtrx/logic/insights.dart';

EntrySummary _e(int day, List<int> groups) =>
    EntrySummary(sessionId: day, dayKey: day, groupIds: groups, exerciseCount: 0, hasNote: false);

MuscleGroup _g(int id, String name, {bool hidden = false}) =>
    MuscleGroup(id: id, name: name, slug: null, sortOrder: id, hidden: hidden, isCustom: false);

void main() {
  const today = 20261008;

  test('overview counts month, year, all time and a 12-week average', () {
    final days = [20261008, 20261003, 20260928, 20260715, 20251231, 20261020];
    final s = overview(days, today);
    expect(s.thisMonth, 2);
    expect(s.thisYear, 4);
    expect(s.allTime, 5, reason: 'future days are ignored');
    expect(s.perWeek12, closeTo(3 / 12, 1e-9), reason: "15 Jul is outside the 84-day window");
    expect(s.lastDayKey, 20261008);
  });

  test('overview of nothing', () {
    final s = overview(const [], today);
    expect(s.allTime, 0);
    expect(s.lastDayKey, isNull);
  });

  test('group recency stays in chip order and counts the window', () {
    final groups = [_g(1, 'Chest'), _g(2, 'Legs'), _g(3, 'Calves', hidden: true), _g(4, 'Traps', hidden: true)];
    final entries = [
      _e(20261006, [1]),
      _e(20260920, [1, 2]),
      _e(20260801, [3]),
    ];
    final r = groupRecency(entries, groups, today);
    expect(r.map((x) => x.group.name), ['Chest', 'Legs', 'Calves'], reason: 'hidden groups appear only if ever trained');
    expect(r[0].lastDayKey, 20261006);
    expect(r[0].countInWindow, 2);
    expect(r[1].countInWindow, 1);
    expect(r[2].countInWindow, 0);
  });

  test('monthly counts end at the current month', () {
    final m = monthlyCounts([20261001, 20261005, 20260930, 20251015], today, months: 3);
    expect(m.map((x) => (x.month.month, x.count)), [(8, 0), (9, 1), (10, 2)]);
  });
}
