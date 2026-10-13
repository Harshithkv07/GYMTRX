import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/notification_service.dart';
import '../features.dart';
import '../reminder_planner.dart';
import 'data_providers.dart';
import 'holiday_providers.dart';
import 'progress_providers.dart';
import 'settings_provider.dart';

/// What to plan, given the settings: nothing when the Reminders feature is
/// off, and no streak warning without the Weekly streak feature.
ReminderPrefs reminderPrefsOf(AppSettings s) => (
  inactive: s.has(AppFeature.reminders) && s.remindInactive,
  inactiveDays: s.inactiveDays,
  streak: s.has(AppFeature.reminders) && s.has(AppFeature.streak) && s.remindStreak,
  streakOffset: s.streakRemindOffset,
  minutes: s.reminderMinutes,
  since: s.remindersSince,
);

/// Keeps scheduled reminders in step with the log: every session, setting
/// change or new day re-plans them. Watch this provider once (the shell
/// does) to start it.
final reminderSyncProvider = Provider<void>((ref) {
  Timer? debounce;
  ref.onDispose(() => debounce?.cancel());

  void schedule() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 800), () {
      final entries = ref.read(summariesProvider).value;
      if (entries == null) return;
      final s = ref.read(settingsProvider);
      final planned = planReminders(
        now: DateTime.now(),
        prefs: reminderPrefsOf(s),
        // Newest first.
        lastSessionDay: entries.isEmpty ? null : entries.first.dayKey,
        streak: ref.read(streakProvider),
        goalFor: ref.read(weeklyGoalForProvider),
        isHoliday: ref.read(holidayMapProvider).containsKey,
      );
      NotificationService.instance.sync(planned);
    });
  }

  ref.listen(summariesProvider, (_, _) => schedule(), fireImmediately: true);
  ref.listen(streakProvider, (_, _) => schedule());
  ref.listen(logicalTodayProvider, (_, _) => schedule());
  ref.listen(holidayMapProvider, (_, _) => schedule());
  ref.listen(
    settingsProvider.select(
      (s) => (
        s.remindInactive,
        s.inactiveDays,
        s.remindStreak,
        s.streakRemindOffset,
        s.reminderMinutes,
        s.remindersSince,
        s.features,
      ),
    ),
    (_, _) => schedule(),
  );
});
