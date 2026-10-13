import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../data/services/health_service.dart';
import '../../logic/features.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/health_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../health/health_connect_flow.dart';
import '../widgets/controls.dart';
import '../widgets/toast.dart';
import 'drive_actions.dart';
import 'settings_widgets.dart';

/// Settings → Health Connect.
class HealthSettingsGroup extends ConsumerWidget {
  const HealthSettingsGroup({super.key});

  /// Turning a part on asks Health Connect for whatever it still needs.
  Future<void> _toggle(WidgetRef ref, bool on, List<String> perms, String what, void Function(bool) apply) async {
    if (!on) {
      apply(false);
      return;
    }
    final hc = ref.read(healthServiceProvider);
    var granted = await hc.granted();
    final missing = [
      for (final p in perms)
        if (!granted.contains(p)) p,
    ];
    if (missing.isNotEmpty) {
      try {
        granted = await hc.request(missing);
      } on Object {
        granted = await hc.granted();
      }
    }
    if (!granted.contains(perms.first)) {
      Toasts.show('Allow $what for GYMTRX in Health Connect to use this.');
      return;
    }
    apply(true);
    ref.read(healthSyncProvider.notifier).syncAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    if (!s.healthConnected) {
      return SettingsGroup(
        title: 'Health Connect',
        footer: 'Steps on rest days, and with a watch, heart rate, calories and sleep. Nothing leaves your phone.',
        children: [
          SettingsRow(
            icon: GtIcons.health,
            title: 'Connect Health Connect',
            subtitle: 'You choose what’s shared',
            onTap: () => openHealthConnectFlow(context),
          ),
        ],
      );
    }

    final watch = s.healthWatch == true;
    return SettingsGroup(
      title: 'Health Connect',
      footer: watch
          ? 'Read from and written to Health Connect on this phone only. GYMTRX has no server.'
          : 'Only your step count is read. Nothing leaves your phone.',
      children: [
        SettingsRow(
          icon: watch ? GtIcons.watch : GtIcons.footprints,
          title: watch ? 'I wear a watch' : 'No watch: steps only',
          subtitle: watch ? 'Tap to change' : 'Got a watch now? Tap to add heart rate and more',
          onTap: () => openHealthConnectFlow(context),
        ),
        if (watch) ...[
          SettingsRow(
            icon: GtIcons.heart,
            title: 'Heart rate & calories',
            subtitle: 'For the time you were training',
            trailing: GtSwitch(
              value: s.healthHeart,
              onChanged: (v) => _toggle(
                ref,
                v,
                const [HealthPermissions.heartRate, HealthPermissions.calories, HealthPermissions.readWorkouts],
                'heart rate',
                notifier.setHealthHeart,
              ),
            ),
          ),
          SettingsRow(
            icon: GtIcons.sleep,
            title: 'Sleep',
            subtitle: 'How long you slept the night before',
            trailing: GtSwitch(
              value: s.healthSleep,
              onChanged: (v) => _toggle(ref, v, const [HealthPermissions.sleep], 'sleep', notifier.setHealthSleep),
            ),
          ),
          if (s.has(AppFeature.bodyWeight))
            SettingsRow(
              icon: GtIcons.weight,
              title: 'Weigh-ins from other apps',
              subtitle: 'Like a smart scale. Your own entries always win',
              trailing: GtSwitch(
                value: s.healthWeightsIn,
                onChanged: (v) =>
                    _toggle(ref, v, const [HealthPermissions.readWeight], 'weight', notifier.setHealthWeightsIn),
              ),
            ),
          SettingsRow(
            icon: GtIcons.share,
            title: 'Share sessions & weigh-ins',
            subtitle: 'Sessions with a start time, as strength training',
            trailing: GtSwitch(
              value: s.healthWrite,
              onChanged: (v) => _toggle(
                ref,
                v,
                const [HealthPermissions.writeWorkouts, HealthPermissions.writeWeight],
                'exercise',
                notifier.setHealthWrite,
              ),
            ),
          ),
        ],
        SettingsRow(
          icon: GtIcons.settings,
          title: 'Open Health Connect',
          subtitle: 'See or remove what GYMTRX can access',
          onTap: () => ref.read(healthServiceProvider).openSettings(),
        ),
        SettingsRow(
          icon: GtIcons.close,
          title: 'Disconnect',
          destructive: true,
          onTap: () async {
            await ref.read(healthSyncProvider.notifier).disconnect();
            notifier.disconnectHealth();
            Toasts.show('Disconnected. To remove access completely, use Open Health Connect.');
          },
        ),
      ],
    );
  }
}

/// Settings → Google Drive.
class DriveSettingsGroup extends ConsumerWidget {
  const DriveSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final busy = ref.watch(driveBusyProvider);
    final today = ref.watch(todayProvider);

    if (!driveConfigured) {
      return const SettingsGroup(
        title: 'Google Drive',
        children: [
          SettingsRow(
            icon: GtIcons.cloud,
            title: 'Google Drive backup',
            subtitle: 'Not set up in this copy of GYMTRX yet',
          ),
        ],
      );
    }

    final account = s.driveAccount;
    if (account == null) {
      return SettingsGroup(
        title: 'Google Drive',
        footer: 'Backups go to a hidden folder in your own Drive that only GYMTRX can see.',
        children: [
          SettingsRow(
            icon: GtIcons.google,
            title: 'Back up to Google Drive',
            subtitle: 'Sign in with Google',
            onTap: () => signInToDrive(context, ref),
          ),
          SettingsRow(
            icon: GtIcons.import,
            title: 'Restore from Drive',
            subtitle: 'From a backup made on another phone',
            onTap: () => restoreFromDrive(context, ref),
          ),
        ],
      );
    }

    final last = s.driveLastBackupAt;
    final status =
        s.driveLastError ??
        (last == null
            ? 'Not backed up yet'
            : 'Last backup ${Fmt.relativeDay(DayKeys.of(last), today).toLowerCase()}, ${Fmt.time(last)}');
    return SettingsGroup(
      title: 'Google Drive',
      footer: s.driveAuto
          ? 'Backs up by itself about once a day when you open GYMTRX, only if something changed. The last 7 backups are kept.'
          : 'Automatic backup is off. Use Back up now whenever you like.',
      children: [
        SettingsRow(icon: GtIcons.cloudCheck, title: 'Signed in', subtitle: account),
        SettingsRow(
          icon: GtIcons.cloud,
          title: 'Back up automatically',
          trailing: GtSwitch(value: s.driveAuto, onChanged: ref.read(settingsProvider.notifier).setDriveAuto),
        ),
        SettingsRow(
          icon: GtIcons.export,
          title: busy ? 'Backing up…' : 'Back up now',
          subtitle: status,
          destructive: s.driveLastError != null && !busy,
          trailing: busy
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : null,
          onTap: busy ? null : () => backUpToDrive(ref, interactive: true, force: true),
        ),
        SettingsRow(
          icon: GtIcons.import,
          title: 'Restore from Drive',
          subtitle: 'Replaces what is on this phone',
          onTap: busy ? null : () => restoreFromDrive(context, ref),
        ),
        SettingsRow(icon: GtIcons.signOut, title: 'Sign out', onTap: () => signOutOfDrive(ref)),
      ],
    );
  }
}

/// A small caption naming the app something came from, e.g. "from Samsung Health".
class HealthSourceText extends ConsumerWidget {
  const HealthSourceText(this.package, {super.key, this.prefix = 'from ', this.style});

  final String package;
  final String prefix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(healthAppNameProvider(package)).value ?? '…';
    return Text('$prefix$name', style: style ?? GtText.caption.colored(GtColors.text3));
  }
}
