import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/core/utils/day_key.dart';
import 'package:gymtrx/logic/reminder_planner.dart';
import 'package:gymtrx/logic/streaks.dart';
import 'package:gymtrx/logic/trends.dart';

void main() {
  group('moving average', () {
    test('averages the trailing 7 calendar days, inclusive', () {
      final avg = movingAverage([(20261001, 80), (20261004, 78), (20261007, 76), (20261008, 75)]);
      expect(avg[0].$2, 80);
      expect(avg[1].$2, 79);
      expect(avg[2].$2, closeTo(78, 1e-9), reason: '1 Oct is exactly 6 days back, still in');
      expect(avg[3].$2, closeTo((78 + 76 + 75) / 3, 1e-9), reason: '1 Oct is 7 days back, out');
    });

    test('empty and single', () {
      expect(movingAverage(const []), isEmpty);
      expect(movingAverage(const [(20261001, 70.0)]), [(20261001, 70.0)]);
    });
  });

  group('body-weight goal', () {
    test('losing', () {
      final p = bodyWeightGoal(startKg: 80, targetKg: 75, currentKg: 78);
      expect(p.losing, isTrue);
      expect(p.toGoKg, closeTo(3, 1e-9));
      expect(p.fraction, closeTo(0.4, 1e-9));
      expect(p.achieved, isFalse);
    });

    test('gaining and reached', () {
      final p = bodyWeightGoal(startKg: 60, targetKg: 65, currentKg: 65.2);
      expect(p.losing, isFalse);
      expect(p.achieved, isTrue);
      expect(p.fraction, 1);
      expect(p.toGoKg, 0);
    });

    test('moving the wrong way clamps at zero', () {
      expect(bodyWeightGoal(startKg: 80, targetKg: 75, currentKg: 82).fraction, 0);
    });
  });

  group('reminder planner', () {
    // Thursday 8 Oct 2026, 10:00. Week starts Monday 5 Oct.
    final now = DateTime(2026, 10, 8, 10);
    const prefs = (inactive: true, inactiveDays: 3, streak: true, streakOffset: 0, minutes: 18 * 60, since: null);

    StreakStats stats({int run = 2, int count = 1, int goal = 3}) => StreakStats(
      current: run + (count >= goal ? 1 : 0),
      best: run + 1,
      completedRun: run,
      thisWeekCount: count,
      thisWeekGoal: goal,
      weekStartKey: 20261005,
    );

    List<PlannedReminder> plan({
      ReminderPrefs p = prefs,
      int? last = 20261007,
      StreakStats? streak,
      DateTime? at,
    }) => planReminders(now: at ?? now, prefs: p, lastSessionDay: last, streak: streak ?? stats(), goalFor: (_) => 3);

    test('inactivity nudges at N, 2N and 3N days at the chosen time', () {
      final r = plan().where((x) => ReminderIds.inactive.contains(x.id)).toList();
      expect([for (final x in r) x.at], [
        DateTime(2026, 10, 10, 18),
        DateTime(2026, 10, 13, 18),
        DateTime(2026, 10, 16, 18),
      ]);
      expect(r.first.title, 'It’s been 3 days');
    });

    test('past nudges are dropped, so a long gap goes quiet', () {
      final r = plan(last: 20260901).where((x) => ReminderIds.inactive.contains(x.id));
      expect(r, isEmpty);
    });

    test('switching reminders on restarts the inactivity count', () {
      const p = (inactive: true, inactiveDays: 3, streak: false, streakOffset: 0, minutes: 18 * 60, since: 20261008);
      final r = plan(p: p, last: 20260901);
      expect(r.first.at, DateTime(2026, 10, 11, 18));
    });

    test('streak at risk on the last day of a short week', () {
      final r = plan().firstWhere((x) => x.id == ReminderIds.streakThisWeek);
      expect(r.at, DateTime(2026, 10, 11, 18));
      expect(r.title, 'Your 2-week streak is at risk');
      expect(r.body, '2 more sessions this week keeps it going.');
    });

    test('the day before, when asked', () {
      const p = (inactive: false, inactiveDays: 3, streak: true, streakOffset: 1, minutes: 18 * 60, since: null);
      expect(plan(p: p).single.at, DateTime(2026, 10, 10, 18));
    });

    test('no warning without a streak to lose', () {
      expect(plan(streak: stats(run: 0)).where((x) => x.id == ReminderIds.streakThisWeek), isEmpty);
    });

    test('a met week queues next week instead', () {
      final r = plan(streak: stats(count: 3));
      expect(r.where((x) => x.id == ReminderIds.streakThisWeek), isEmpty);
      final next = r.firstWhere((x) => x.id == ReminderIds.streakNextWeek);
      expect(next.at, DateTime(2026, 10, 18, 18));
      expect(next.title, 'Your 3-week streak is at risk');
    });

    test('everything off plans nothing', () {
      const p = (inactive: false, inactiveDays: 3, streak: false, streakOffset: 0, minutes: 18 * 60, since: null);
      expect(plan(p: p), isEmpty);
    });

    test('ids stay inside the managed set', () {
      for (final r in plan()) {
        expect(ReminderIds.managed, contains(r.id));
      }
    });
  });

  test('weekStartOf', () {
    expect(DayKeys.weekStartOf(20261008, DateTime.monday), 20261005);
    expect(DayKeys.weekStartOf(20261005, DateTime.monday), 20261005);
    expect(DayKeys.weekStartOf(20261011, DateTime.monday), 20261005);
    expect(DayKeys.weekStartOf(20261008, DateTime.sunday), 20261004);
    expect(DayKeys.weekStartOf(20261004, DateTime.sunday), 20261004);
    expect(DayKeys.weekStartOf(20270101, DateTime.monday), 20261228, reason: 'across a year boundary');
  });
}
