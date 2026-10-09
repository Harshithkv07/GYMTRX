import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/accents.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/units.dart';
import '../../data/services/lock_service.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/controls.dart';
import '../widgets/large_title_header.dart';
import '../widgets/pressable.dart';
import '../widgets/toast.dart';
import 'backup_actions.dart';
import 'library_screens.dart';
import 'settings_widgets.dart';

final _packageInfoProvider = FutureProvider((ref) => PackageInfo.fromPlatform());

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
                child: Text(
                  'Anything logged before this time counts toward the previous day.',
                  style: GtText.caption,
                ),
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
                title: 'Accent',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GtSpace.md, GtSpace.lg, GtSpace.md, GtSpace.md),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (final a in GtAccent.values)
                              AccentSwatch(
                                color: a.color,
                                label: a.label,
                                selected: a == s.accent,
                                onTap: () => notifier.setAccent(a),
                              ),
                          ],
                        ),
                        const SizedBox(height: GtSpace.md),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: Text(s.accent.label, key: ValueKey(s.accent), style: GtText.caption),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SettingsGroup(
                title: 'Logging',
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
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GroupsLibraryScreen())),
                  ),
                  SettingsRow(
                    icon: GtIcons.exercise,
                    title: 'Exercises',
                    subtitle: '${exercises.where((e) => !e.hidden).length} in your library',
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ExercisesLibraryScreen())),
                  ),
                ],
              ),
              SettingsGroup(
                title: 'Your data',
                footer:
                    'Everything stays on this phone. If Google backup is on, Android also backs it up automatically.',
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
                  SettingsRow(icon: GtIcons.info, title: 'GYMTRX', subtitle: version == null ? null : 'Version $version'),
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
