import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/units.dart';
import '../../data/services/lock_service.dart';
import '../../data/services/notification_service.dart';
import '../../logic/features.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/navigation_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../progress/goal_sheets.dart';
import '../onboarding/features_screen.dart';
import '../progress/program_editor.dart';
import '../widgets/controls.dart';
import '../widgets/large_title_header.dart';
import '../widgets/option_sheet.dart';
import '../widgets/pressable.dart';
import '../widgets/toast.dart';
import 'backup_actions.dart';
import 'connection_settings.dart';
import 'holiday_settings.dart';
import 'library_screens.dart';
import 'settings_widgets.dart';

final _packageInfoProvider = FutureProvider((ref) => PackageInfo.fromPlatform());
final _notificationsOnProvider = FutureProvider.autoDispose((ref) => NotificationService.instance.areEnabled());

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static String hourLabel(int h) => h == 0 ? 'Midnight' : '$h AM';

  Future<void> _toggleLock(WidgetRef ref, bool enable) async {
    final notifier = ref.read(settingsProvider.notifier);
    if (!enable) {
      notifier.setLockEnabled(false);
      return;
    }
    if (!await LockService.isAvailable()) {
      Toasts.show('Set up a screen lock on your phone first.');
      return;
    }
    // Prove it works before turning it on, so nobody locks themselves out.
    if (await LockService.authenticate(reason: 'Turn on app lock')) {
      notifier.setLockEnabled(true);
      Haptics.medium();
    }
  }

  /// Turning a reminder on asks for Android's notification permission first.
  Future<void> _toggleReminder(WidgetRef ref, bool enable, void Function(bool v, {required int today}) apply) async {
    final today = ref.read(logicalTodayProvider);
    if (!enable) {
      apply(false, today: today);
      return;
    }
    if (!await NotificationService.instance.requestPermission()) {
      Toasts.show('Allow notifications for GYMTRX in Android settings to get reminders.');
      return;
    }
    apply(true, today: today);
    Haptics.medium();
    ref.invalidate(_notificationsOnProvider);
  }

  Future<void> _pickReminderTime(BuildContext context, WidgetRef ref, int current) async {
    final picked = await showOptionSheet<int>(
      context,
      title: 'Reminder time',
      caption: 'Reminders arrive around this time.',
      options: [for (var m = 6 * 60; m <= 22 * 60 + 30; m += 30) m],
      labelOf: Fmt.timeOfDay,
      selected: current,
    );
    if (picked != null) ref.read(settingsProvider.notifier).setReminderMinutes(picked);
  }

  Future<void> _pickInactiveDays(BuildContext context, WidgetRef ref, int current) async {
    final picked = await showOptionSheet<int>(
      context,
      title: 'Nudge after',
      caption: 'Days without a session before the first nudge. At most three nudges, then quiet.',
      options: const [2, 3, 4, 5, 6, 7],
      labelOf: (n) => Fmt.plural(n, 'day'),
      selected: current,
    );
    if (picked != null) ref.read(settingsProvider.notifier).setInactiveDays(picked);
  }

  /// ISO weekday of the week's last day, or the day before it.
  static int _warnWeekday(int weekStart, int offset) => (weekStart + 5 - offset) % 7 + 1;

  Future<void> _pickStreakDay(BuildContext context, WidgetRef ref, int weekStart, int current) async {
    final picked = await showOptionSheet<int>(
      context,
      title: 'Warn on',
      caption: 'The day you hear about a week that’s still short of your goal.',
      options: const [0, 1],
      labelOf: (o) => Fmt.isoWeekdayName(_warnWeekday(weekStart, o)),
      selected: current,
    );
    if (picked != null) ref.read(settingsProvider.notifier).setStreakRemindOffset(picked);
  }

  Future<void> _pickDayStart(BuildContext context, WidgetRef ref, int current) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, GtSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.sm, GtSpace.xs, GtSpace.sm, GtSpace.xs),
                child: Text('Day starts at', style: GtText.title),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.sm, 0, GtSpace.sm, GtSpace.md),
                child: Text('Anything logged before this time counts toward the previous day.', style: GtText.caption),
              ),
              for (final h in [0, 1, 2, 3, 4, 5, 6])
                Pressable(
                  onTap: () => Navigator.pop(context, h),
                  haptic: PressHaptic.selection,
                  scale: 0.98,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: GtSpace.sm),
                    child: Row(
                      children: [
                        Expanded(child: Text(hourLabel(h), style: GtText.body)),
                        if (h == current) Icon(GtIcons.check, size: 18, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) ref.read(settingsProvider.notifier).setDayStartHour(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final groups = ref.watch(groupsProvider).value ?? const [];
    final exercises = ref.watch(exercisesProvider).value ?? const [];
    final today = ref.watch(todayProvider);
    final version = ref.watch(_packageInfoProvider).value?.version;
    final padding = MediaQuery.paddingOf(context);
    final lastExport = s.lastExportAt;
    bool on(AppFeature f) => s.has(f);

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(title: 'Settings', topPadding: padding.top, showBack: true),
          ),
          SliverList.list(
            children: [
              SettingsGroup(
                title: 'Your GYMTRX',
                children: [
                  SettingsRow(
                    icon: GtIcons.features,
                    title: 'Features',
                    subtitle: s.features.isEmpty
                        ? 'Just logging'
                        : '${s.features.length} of ${AppFeature.values.length} turned on',
                    onTap: () => openFeaturesScreen(context),
                  ),
                  SettingsRow(
                    icon: GtIcons.lightbulb,
                    title: 'Take the tour',
                    subtitle: 'Where everything is',
                    onTap: () {
                      // Back to the calendar; the shell starts the tour once this flag drops.
                      ref.read(shellTabProvider.notifier).show(ShellTab.calendar);
                      Navigator.of(context).popUntil((r) => r.isFirst);
                      notifier.setTourSeen(false);
                    },
                  ),
                ],
              ),
              SettingsGroup(
                title: 'Accent',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GtSpace.md, GtSpace.lg, GtSpace.md, GtSpace.md),
                    child: Column(
                      children: [
                        AccentPicker(selected: s.accent, onChanged: notifier.setAccent),
                        const SizedBox(height: GtSpace.md),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: Text(
                            '${s.accent.label} · ${s.accent.pack.label} pack',
                            key: ValueKey(s.accent),
                            style: GtText.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SettingsGroup(
                title: 'Logging',
                footer: 'The week start also decides how streak weeks are counted.',
                children: [
                  SettingsRow(
                    icon: GtIcons.ruler,
                    title: 'Units',
                    trailing: SizedBox(
                      width: 116,
                      child: GtSegmented<WeightUnit>(
                        values: WeightUnit.values,
                        selected: s.unit,
                        labelOf: (u) => u.name,
                        onChanged: notifier.setUnit,
                        height: 34,
                      ),
                    ),
                  ),
                  SettingsRow(
                    icon: GtIcons.calendar,
                    title: 'Week starts on',
                    trailing: SizedBox(
                      width: 132,
                      child: GtSegmented<int>(
                        values: const [DateTime.monday, DateTime.sunday],
                        selected: s.weekStart,
                        labelOf: (d) => d == DateTime.monday ? 'Mon' : 'Sun',
                        onChanged: notifier.setWeekStart,
                        height: 34,
                      ),
                    ),
                  ),
                  SettingsRow(
                    icon: GtIcons.night,
                    title: 'Day starts at',
                    subtitle: 'For late-night logging',
                    trailing: Text(hourLabel(s.dayStartHour), style: GtText.label.colored(GtColors.text2)),
                    onTap: () => _pickDayStart(context, ref, s.dayStartHour),
                  ),
                  SettingsRow(
                    icon: GtIcons.haptics,
                    title: 'Haptics',
                    trailing: GtSwitch(value: s.haptics, onChanged: notifier.setHaptics),
                  ),
                ],
              ),
              if (on(AppFeature.streak) || on(AppFeature.goals) || on(AppFeature.program))
                SettingsGroup(
                  title: 'Goals & program',
                  children: [
                    if (on(AppFeature.streak))
                      SettingsRow(
                        icon: GtIcons.flame,
                        title: 'Weekly goal',
                        subtitle: 'Keeps the streak going',
                        trailing: Text(
                          Fmt.plural(s.weeklyGoal, 'session'),
                          style: GtText.label.colored(GtColors.text2),
                        ),
                        onTap: () => editWeeklyGoal(context, ref),
                      ),
                    if (on(AppFeature.goals))
                      SettingsRow(
                        icon: GtIcons.target,
                        title: 'Monthly goal',
                        trailing: Text(
                          s.monthlyGoal == 0 ? 'Off' : Fmt.plural(s.monthlyGoal, 'session'),
                          style: GtText.label.colored(GtColors.text2),
                        ),
                        onTap: () => editMonthlyGoal(context, ref),
                      ),
                    if (on(AppFeature.program))
                      SettingsRow(
                        icon: GtIcons.program,
                        title: 'Weekly program',
                        subtitle: 'Planned days, missed days',
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute<void>(builder: (_) => const ProgramEditorScreen())),
                      ),
                    if (on(AppFeature.program))
                      SettingsRow(
                        icon: GtIcons.holiday,
                        title: 'Holidays',
                        subtitle: s.holidayCalendarIds.isEmpty
                            ? 'Off · never count a holiday as missed'
                            : 'From ${Fmt.plural(s.holidayCalendarIds.length, 'calendar')} on this phone',
                        onTap: () => openHolidaySetup(context, ref),
                      ),
                  ],
                ),
              if (on(AppFeature.reminders))
                SettingsGroup(
                  title: 'Reminders',
                  footer: s.remindInactive || s.remindStreak
                      ? 'Reminders arrive around the time you pick. If they don’t show up, '
                            'let GYMTRX run in the background in Android’s battery settings.'
                      : null,
                  children: [
                    SettingsRow(
                      icon: GtIcons.bell,
                      title: 'Nudge when I’m away',
                      subtitle: 'After a few days without a session',
                      trailing: GtSwitch(
                        value: s.remindInactive,
                        onChanged: (v) => _toggleReminder(ref, v, notifier.setRemindInactive),
                      ),
                    ),
                    if (s.remindInactive)
                      SettingsRow(
                        icon: GtIcons.calendar,
                        title: 'Nudge after',
                        trailing: Text(Fmt.plural(s.inactiveDays, 'day'), style: GtText.label.colored(GtColors.text2)),
                        onTap: () => _pickInactiveDays(context, ref, s.inactiveDays),
                      ),
                    if (on(AppFeature.streak))
                      SettingsRow(
                        icon: GtIcons.flame,
                        title: 'Streak at risk',
                        subtitle: 'When the week is short of your goal',
                        trailing: GtSwitch(
                          value: s.remindStreak,
                          onChanged: (v) => _toggleReminder(ref, v, notifier.setRemindStreak),
                        ),
                      ),
                    if (on(AppFeature.streak) && s.remindStreak)
                      SettingsRow(
                        icon: GtIcons.calendar,
                        title: 'Warn on',
                        trailing: Text(
                          Fmt.isoWeekdayName(_warnWeekday(s.weekStart, s.streakRemindOffset)),
                          style: GtText.label.colored(GtColors.text2),
                        ),
                        onTap: () => _pickStreakDay(context, ref, s.weekStart, s.streakRemindOffset),
                      ),
                    if (s.remindInactive || s.remindStreak) ...[
                      SettingsRow(
                        icon: GtIcons.clock,
                        title: 'Time',
                        trailing: Text(Fmt.timeOfDay(s.reminderMinutes), style: GtText.label.colored(GtColors.text2)),
                        onTap: () => _pickReminderTime(context, ref, s.reminderMinutes),
                      ),
                      if (ref.watch(_notificationsOnProvider).value == false)
                        SettingsRow(
                          icon: GtIcons.bellOff,
                          title: 'Notifications are off',
                          subtitle: 'Tap to allow them for GYMTRX',
                          destructive: true,
                          onTap: () async {
                            await NotificationService.instance.requestPermission();
                            ref.invalidate(_notificationsOnProvider);
                          },
                        )
                      else
                        SettingsRow(
                          icon: GtIcons.bell,
                          title: 'Send a test reminder',
                          onTap: () {
                            Haptics.light();
                            NotificationService.instance.showTest();
                          },
                        ),
                    ],
                  ],
                ),
              if (on(AppFeature.health)) const HealthSettingsGroup(),
              SettingsGroup(
                title: 'Privacy',
                footer: s.lockEnabled ? 'While locked, GYMTRX also hides its content in recent apps.' : null,
                children: [
                  SettingsRow(
                    icon: GtIcons.lock,
                    title: 'App lock',
                    subtitle: 'Fingerprint, face or PIN',
                    trailing: GtSwitch(value: s.lockEnabled, onChanged: (v) => _toggleLock(ref, v)),
                  ),
                  if (s.lockEnabled)
                    SettingsRow(
                      icon: GtIcons.clock,
                      title: 'Lock after',
                      trailing: SizedBox(
                        width: 168,
                        child: GtSegmented<int>(
                          values: const [0, 60, 300],
                          selected: s.lockAfterSec,
                          labelOf: (v) => switch (v) {
                            0 => 'Now',
                            60 => '1 min',
                            _ => '5 min',
                          },
                          onChanged: notifier.setLockAfter,
                          height: 34,
                        ),
                      ),
                    ),
                ],
              ),
              SettingsGroup(
                title: 'Library',
                children: [
                  SettingsRow(
                    icon: GtIcons.library,
                    title: 'Muscle groups',
                    subtitle: '${groups.where((g) => !g.hidden).length} shown when logging',
                    onTap: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute<void>(builder: (_) => const GroupsLibraryScreen())),
                  ),
                  SettingsRow(
                    icon: GtIcons.exercise,
                    title: 'Exercises',
                    subtitle: '${exercises.where((e) => !e.hidden).length} in your library',
                    onTap: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute<void>(builder: (_) => const ExercisesLibraryScreen())),
                  ),
                ],
              ),
              if (on(AppFeature.drive)) const DriveSettingsGroup(),
              SettingsGroup(
                title: 'Your data',
                footer: on(AppFeature.drive) && s.driveAccount != null
                    ? 'Your log is on this phone and in your Google Drive. Export a file any time as well.'
                    : 'Your log stays on this phone. If Google backup is on, Android also backs it up automatically.',
                children: [
                  SettingsRow(
                    icon: GtIcons.export,
                    title: 'Export backup',
                    subtitle: lastExport == null
                        ? 'Never exported'
                        : 'Last exported ${Fmt.relativeDay(DayKeys.of(lastExport), today).toLowerCase()}',
                    onTap: () => exportBackup(context, ref),
                  ),
                  SettingsRow(
                    icon: GtIcons.import,
                    title: 'Import backup',
                    subtitle: 'Replaces what is on this phone',
                    onTap: () => importBackup(context, ref),
                  ),
                ],
              ),
              SettingsGroup(
                title: 'About',
                children: [
                  SettingsRow(
                    icon: GtIcons.info,
                    title: 'GYMTRX',
                    subtitle: version == null ? null : 'Version $version',
                  ),
                  SettingsRow(
                    icon: GtIcons.note,
                    title: 'Licences',
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'GYMTRX',
                      applicationVersion: version,
                      useRootNavigator: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: padding.bottom + GtSpace.x4),
            ],
          ),
        ],
      ),
    );
  }
}
