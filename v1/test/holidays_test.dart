import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/logic/features.dart';
import 'package:gymtrx/logic/program_plan.dart';
import 'package:gymtrx/logic/providers/reminder_sync_provider.dart';
import 'package:gymtrx/logic/providers/settings_provider.dart';
import 'package:gymtrx/logic/reminder_planner.dart';
import 'package:gymtrx/logic/streaks.dart';

void main() {
  group('program days', () {
    // Monday and Thursday are training days; the program started long ago.
    PlanStatus status(int day, {bool logged = false, bool holiday = false}) => planStatus(
      day,
      trainingWeekdays: const {1, 4},
      programStart: 20260101,
      logged: logged,
      today: 20261009,
      isHoliday: holiday,
    );

    test('a holiday training day is never missed', () {
      expect(status(20261005), PlanStatus.missed, reason: 'an ordinary Monday');
      expect(status(20261005, holiday: true), PlanStatus.holiday);
      expect(status(20261012, holiday: true), PlanStatus.holiday, reason: 'upcoming too');
    });

    test('logging on a holiday still counts as done', () {
      expect(status(20261005, logged: true, holiday: true), PlanStatus.done);
    });

    test('a holiday on a rest day changes nothing', () {
      expect(status(20261006, holiday: true), PlanStatus.none);
    });
  });

  group('reminders around holidays', () {
    // Thursday 8 Oct 2026, 10:00. Week starts Monday 5 Oct.
    final now = DateTime(2026, 10, 8, 10);
    const prefs = (inactive: true, inactiveDays: 3, streak: true, streakOffset: 0, minutes: 18 * 60, since: null);
    const streak = StreakStats(
      current: 2,
      best: 3,
      completedRun: 2,
      thisWeekCount: 1,
      thisWeekGoal: 3,
      weekStartKey: 20261005,
    );

    List<PlannedReminder> plan(Set<int> holidays) => planReminders(
      now: now,
      prefs: prefs,
      lastSessionDay: 20261007,
      streak: streak,
      goalFor: (_) => 3,
      isHoliday: holidays.contains,
    );

    test('a nudge that lands on a holiday moves to the next ordinary day', () {
      final first = plan({20261010, 20261011}).firstWhere((r) => r.id == ReminderIds.inactive.first);
      expect(first.at, DateTime(2026, 10, 12, 18));
    });

    test('the streak warning moves earlier in the week, past holidays', () {
      final warn = plan({20261011, 20261010}).firstWhere((r) => r.id == ReminderIds.streakThisWeek);
      expect(warn.at, DateTime(2026, 10, 9, 18), reason: 'Sunday and Saturday are holidays: Friday instead');
    });

    test('no holidays, no change', () {
      final warn = plan({}).firstWhere((r) => r.id == ReminderIds.streakThisWeek);
      expect(warn.at, DateTime(2026, 10, 11, 18));
    });
  });

  group('feature switches', () {
    const on = AppSettings(remindInactive: true, remindStreak: true);

    test('reminders off plans nothing, whatever was set before', () {
      final p = reminderPrefsOf(on.copyWith(features: {...AppFeature.values}..remove(AppFeature.reminders)));
      expect((p.inactive, p.streak), (false, false));
    });

    test('no streak warning without the weekly streak', () {
      final p = reminderPrefsOf(on.copyWith(features: {AppFeature.reminders}));
      expect((p.inactive, p.streak), (true, false));
    });

    test('everything on: both', () {
      final p = reminderPrefsOf(on);
      expect((p.inactive, p.streak), (true, true));
    });
  });
}
