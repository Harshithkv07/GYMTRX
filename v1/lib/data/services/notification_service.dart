import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../logic/reminder_planner.dart';

/// Local reminders. Every call swallows plugin errors: a reminder that can't
/// be scheduled must never break logging (and tests have no plugin at all).
class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _icon = 'ic_stat_gymtrx';
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Inactivity and streak-at-risk reminders',
      category: AndroidNotificationCategory.reminder,
      icon: _icon,
    ),
  );

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// [onTap] runs when a reminder is tapped while the app is alive.
  Future<void> init({required VoidCallback onTap}) async {
    if (_ready) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(android: AndroidInitializationSettings(_icon)),
        onDidReceiveNotificationResponse: (_) => onTap(),
      );
      _ready = true;
    } on Object catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
  }

  /// True when this launch came from tapping a reminder.
  Future<bool> launchedFromReminder() async {
    if (!_ready) return false;
    try {
      return (await _plugin.getNotificationAppLaunchDetails())?.didNotificationLaunchApp ?? false;
    } on Object {
      return false;
    }
  }

  /// Asks for Android 13+'s notification permission. True when granted.
  Future<bool> requestPermission() async {
    try {
      return await _android?.requestNotificationsPermission() ?? false;
    } on Object {
      return false;
    }
  }

  Future<bool> areEnabled() async {
    try {
      return await _android?.areNotificationsEnabled() ?? false;
    } on Object {
      return false;
    }
  }

  /// Cancels every reminder GYMTRX owns and schedules [wanted]. Times are
  /// absolute instants (UTC), so no timezone database is needed; inexact
  /// delivery needs no exact-alarm permission.
  Future<void> sync(List<PlannedReminder> wanted) async {
    if (!_ready) return;
    try {
      for (final id in ReminderIds.managed) {
        await _plugin.cancel(id: id);
      }
      final now = DateTime.now();
      for (final r in wanted) {
        if (!r.at.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: r.id,
          scheduledDate: tz.TZDateTime.from(r.at, tz.UTC),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: r.title,
          body: r.body,
          payload: 'log',
        );
      }
    } on Object catch (e) {
      debugPrint('Reminder sync failed: $e');
    }
  }

  /// A reminder right now, to check they get through.
  Future<void> showTest() async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id: ReminderIds.test,
        title: 'Reminders are on',
        body: 'This is how GYMTRX will nudge you.',
        notificationDetails: _details,
        payload: 'log',
      );
    } on Object catch (e) {
      debugPrint('Test notification failed: $e');
    }
  }
}
