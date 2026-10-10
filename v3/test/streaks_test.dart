import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/logic/program_plan.dart';
import 'package:gymtrx/logic/streaks.dart';

void main() {
  // Weeks starting Monday: 21–27 Sep, 28 Sep–4 Oct, 5–11 Oct 2026.
  const today = 20261008; // Thursday
  int goal3(int _) => 3;

  StreakStats streak(List<int> days, {int Function(int)? goalFor, int weekStart = DateTime.monday, int t = today}) =>
      weeklyStreak(days, today: t, weekStart: weekStart, goalFor: goalFor ?? goal3);

  test('nothing logged', () {
    final s = streak(const []);
    expect(s.current, 0);
    expect(s.best, 0);
    expect(s.thisWeekCount, 0);
    expect(s.remaining, 3);
  });

  test('an unfinished current week never breaks the streak', () {
    final s = streak([20260921, 20260923, 20260925, 20260928, 20260930, 20261002, 20261006]);
    expect(s.completedRun, 2);
    expect(s.current, 2);
    expect(s.thisWeekCount, 1);
    expect(s.thisWeekMet, isFalse);
  });

  test('meeting the goal this week adds it', () {
    final s = streak([20260928, 20260930, 20261002, 20261005, 20261006, 20261007]);
    expect(s.current, 2);
    expect(s.thisWeekMet, isTrue);
  });

  test('a short week breaks it, and best remembers longer runs', () {
    final s = streak([
      20260907, 20260908, 20260909, // met
      20260914, 20260915, 20260916, // met
      20260921, // short
      20260928, 20260929, 20260930, // met
    ]);
    expect(s.current, 1);
    expect(s.best, 2);
  });

  test('the week start setting re-buckets sessions', () {
    // Sun 4 Oct belongs to last week for Monday starts, this week for Sunday starts.
    final days = [20260928, 20261001, 20261004];
    expect(streak(days).completedRun, 1);
    expect(streak(days, weekStart: DateTime.sunday).completedRun, 0);
    expect(streak(days, weekStart: DateTime.sunday).thisWeekCount, 1);
  });

  test('future days are ignored', () {
    expect(streak([20261009, 20261010, 20261011]).thisWeekCount, 0);
  });

  test('goal history: raising the goal later keeps earlier weeks', () {
    final lookup = goalLookup([(20260921, 2), (20261005, 4)], 3);
    expect(lookup(20260914), 2, reason: 'before the first entry, the first goal applies');
    expect(lookup(20260928), 2);
    expect(lookup(20261005), 4);
    final s = streak([20260921, 20260922, 20260928, 20260929, 20261005], goalFor: lookup);
    expect(s.completedRun, 2);
    expect(s.thisWeekGoal, 4);
    expect(goalLookup(const [], 3)(20261005), 3);
    expect(goalLookup(const [(20261005, 0)], 3)(20261005), 1, reason: 'never below 1');
  });

  test('the logical day decides which week it is', () {
    // Monday 5 Oct at 01:00 with a 4 AM day start is still Sunday 4 Oct.
    final s = streak([20260928, 20260930, 20261002], t: 20261004);
    expect(s.weekStartKey, 20260928);
    expect(s.thisWeekMet, isTrue);
  });

  test('month count and milestones', () {
    expect(monthCount([20261001, 20261008, 20261009, 20260930], today), 2);
    expect([for (var w = 1; w <= 80; w++) if (isStreakMilestone(w)) w], [4, 8, 12, 26, 52, 78]);
  });

  group('program plan', () {
    const weekdays = {1, 3, 5}; // Mon, Wed, Fri
    PlanStatus plan(int day, {bool logged = false, int? start = 20260928}) =>
        planStatus(day, trainingWeekdays: weekdays, programStart: start, logged: logged, today: today);

    test('missed, done, planned and none', () {
      expect(plan(20261005), PlanStatus.missed, reason: 'Mon, past, nothing logged');
      expect(plan(20261005, logged: true), PlanStatus.done);
      expect(plan(20261006), PlanStatus.none, reason: 'Tuesday is a rest day');
      expect(plan(20261009), PlanStatus.planned, reason: 'Friday is still to come');
    });

    test('today is never missed', () {
      expect(planStatus(20261007, trainingWeekdays: weekdays, programStart: 20260928, logged: false, today: 20261007),
          PlanStatus.planned);
    });

    test('nothing before the program started, and nothing without one', () {
      expect(plan(20260928), PlanStatus.missed, reason: 'the start day itself counts');
      expect(plan(20260925), PlanStatus.none);
      expect(plan(20261005, start: null), PlanStatus.none);
    });
  });
}
