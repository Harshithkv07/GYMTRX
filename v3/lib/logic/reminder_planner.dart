import 'package:flutter/foundation.dart';

import '../core/utils/day_key.dart';
import 'streaks.dart';

/// Notification ids owned by the reminder sync. Each sync cancels all of
/// them and schedules what's wanted now.
abstract final class ReminderIds {
  static const inactive = [1001, 1002, 1003];
  static const streakThisWeek = 2001;
  static const streakNextWeek = 2002;
  static const test = 9001;

  static const managed = [...inactive, streakThisWeek, streakNextWeek];
}

@immutable
class PlannedReminder {
  const PlannedReminder({required this.id, required this.at, required this.title, required this.body});

  final int id;
  final DateTime at;
  final String title;
  final String body;

  @override
  String toString() => 'PlannedReminder($id, $at, $title)';
}

typedef ReminderPrefs = ({
  bool inactive,
  int inactiveDays,
  bool streak,
  int streakOffset,
  int minutes,
  int? since,
});

/// Inactivity nudges come N, 2N and 3N days after the last session (or after
/// reminders were switched on, whichever is later), then stop. The streak
/// warning comes near the end of a week that's still short of its goal while
/// a streak is running; once this week is met, next week's is queued.
List<PlannedReminder> planReminders({
  required DateTime now,
  required ReminderPrefs prefs,
  required int? lastSessionDay,
  required StreakStats streak,
  required int Function(int weekKey) goalFor,
}) {
  final out = <PlannedReminder>[];
  final earliest = now.add(const Duration(minutes: 1));

  DateTime at(int day) =>
      DateTime(DayKeys.year(day), DayKeys.month(day), DayKeys.day(day), prefs.minutes ~/ 60, prefs.minutes % 60);

  void add(int id, DateTime when, String title, String body) {
    if (when.isAfter(earliest)) out.add(PlannedReminder(id: id, at: when, title: title, body: body));
  }

  if (prefs.inactive && prefs.inactiveDays > 0) {
    final candidates = [?lastSessionDay, ?prefs.since];
    if (candidates.isNotEmpty) {
      final base = candidates.reduce((a, b) => a > b ? a : b);
      for (var k = 1; k <= ReminderIds.inactive.length; k++) {
        final days = k * prefs.inactiveDays;
        add(
          ReminderIds.inactive[k - 1],
          at(DayKeys.addDays(base, days)),
          'It’s been $days days',
          'A short session still counts. Log it when you’re done.',
        );
      }
    }
  }

  if (prefs.streak && streak.weekStartKey != 0) {
    final lastDayOffset = 6 - prefs.streakOffset.clamp(0, 6);
    final cw = streak.weekStartKey;
    if (!streak.thisWeekMet && streak.completedRun > 0) {
      final left = streak.remaining;
      add(
        ReminderIds.streakThisWeek,
        at(DayKeys.addDays(cw, lastDayOffset)),
        'Your ${streak.completedRun}-week streak is at risk',
        '$left more ${left == 1 ? 'session' : 'sessions'} this week keeps it going.',
      );
    }
    if (streak.thisWeekMet) {
      final next = DayKeys.addDays(cw, 7);
      final goal = goalFor(next);
      add(
        ReminderIds.streakNextWeek,
        at(DayKeys.addDays(next, lastDayOffset)),
        'Your ${streak.current}-week streak is at risk',
        '$goal more ${goal == 1 ? 'session' : 'sessions'} this week keeps it going.',
      );
    }
  }
  return out;
}
