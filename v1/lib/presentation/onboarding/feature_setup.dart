import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/services/notification_service.dart';
import '../../logic/features.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../health/health_connect_flow.dart';
import '../settings/drive_actions.dart';
import '../widgets/explainer_sheet.dart';
import '../widgets/toast.dart';

/// Finishes turning on a feature that needs a permission or a sign-in. Each
/// step explains itself first, and every step can be skipped.
Future<void> setUpFeature(BuildContext context, WidgetRef ref, AppFeature f) async {
  final s = ref.read(settingsProvider);
  switch (f) {
    case AppFeature.reminders:
      if (!s.remindInactive && !s.remindStreak) await setUpReminders(context, ref);
    case AppFeature.health:
      if (!s.healthConnected) await openHealthConnectFlow(context);
    case AppFeature.drive:
      if (!await isSignedInToDrive(ref)) {
        if (context.mounted) await signInToDrive(context, ref);
      }
    default:
      break;
  }
}

/// Explains the reminders, asks Android for notifications, then turns on the
/// nudge (and the streak warning when streaks are on). True if turned on.
Future<bool> setUpReminders(BuildContext context, WidgetRef ref) async {
  final s = ref.read(settingsProvider);
  final streak = s.has(AppFeature.streak);
  final go = await showExplainerSheet(
    context,
    icon: GtIcons.bell,
    title: 'Reminders',
    body: 'GYMTRX can send a short note when it’s been a while. Android will ask you to allow notifications next.',
    points: [
      'A nudge after ${Fmt.plural(s.inactiveDays, 'day')} without a session, at most three times.',
      if (streak) 'A heads-up near the end of a week that’s still short of your goal.',
      'Around ${Fmt.timeOfDay(s.reminderMinutes)}. Change the time in Settings → Reminders.',
    ],
    action: 'Turn on reminders',
  );
  if (!go) return false;
  return enableReminders(ref);
}

/// Asks Android for notifications, then turns on the nudge (and the streak
/// warning when streaks are on). True if turned on.
Future<bool> enableReminders(WidgetRef ref) async {
  if (!await NotificationService.instance.requestPermission()) {
    Toasts.show('Notifications are off for GYMTRX. You can allow them in Android settings.');
    return false;
  }
  final today = ref.read(logicalTodayProvider);
  final notifier = ref.read(settingsProvider.notifier);
  notifier.setRemindInactive(true, today: today);
  if (ref.read(settingsProvider).has(AppFeature.streak)) notifier.setRemindStreak(true, today: today);
  Haptics.medium();
  return true;
}
