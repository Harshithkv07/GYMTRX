import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/config.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/services/backup_service.dart';
import '../../data/services/drive_backup_service.dart';
import '../../logic/drive_plan.dart';
import '../../logic/features.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/controls.dart';
import '../widgets/explainer_sheet.dart';
import '../widgets/gt_button.dart';
import '../widgets/toast.dart';
import 'settings_widgets.dart';

export '../../core/config.dart' show driveConfigured;

/// True while a Drive backup or restore is running.
class DriveBusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool v) => state = v;
}

final driveBusyProvider = NotifierProvider<DriveBusyNotifier, bool>(DriveBusyNotifier.new);

Future<bool> isSignedInToDrive(WidgetRef ref) async => ref.read(settingsProvider).driveAccount != null;

/// Signs in with Google and runs the first backup. With [explain], says
/// first what GYMTRX will (and won't) be able to see. True if signed in.
Future<bool> signInToDrive(BuildContext context, WidgetRef ref, {bool explain = true}) async {
  if (!driveConfigured) {
    Toasts.show('Drive backup isn’t set up in this copy of GYMTRX.');
    return false;
  }
  if (explain) {
    final go = await showExplainerSheet(
      context,
      icon: GtIcons.google,
      title: 'Back up to Google Drive',
      body: 'Sign in with your Google account. Google will ask you to let GYMTRX use its own folder in your Drive.',
      points: const [
        'Backups go to a hidden folder in your Drive that only GYMTRX can see.',
        'GYMTRX can’t see any of your other files.',
        'It backs up by itself about once a day when you open the app.',
      ],
      action: 'Sign in with Google',
    );
    if (!go) return false;
  }
  final String email;
  try {
    email = await DriveBackupService.instance.signIn();
  } on DriveBackupException catch (e) {
    Toasts.show(e.message);
    return false;
  }
  ref.read(settingsProvider.notifier)
    ..setDriveAccount(email)
    ..setFeature(AppFeature.drive, true);
  Haptics.medium();
  Toasts.show('Signed in as $email');
  await backUpToDrive(ref, interactive: true, force: true);
  return true;
}

Future<void> signOutOfDrive(WidgetRef ref) async {
  try {
    await DriveBackupService.instance.signOut();
  } on Object {
    // Signed out locally either way.
  }
  ref.read(settingsProvider.notifier).setDriveAccount(null);
  Toasts.show('Signed out of Google Drive');
}

/// Uploads a backup unless nothing changed since the last one ([force]
/// uploads anyway). Errors are kept for the Settings row; with
/// [interactive] they're also shown.
Future<bool> backUpToDrive(WidgetRef ref, {bool interactive = false, bool force = false}) async {
  final s = ref.read(settingsProvider);
  if (s.driveAccount == null || ref.read(driveBusyProvider)) return false;
  final busy = ref.read(driveBusyProvider.notifier)..set(true);
  final notifier = ref.read(settingsProvider.notifier);
  try {
    final db = ref.read(databaseProvider);
    final json = await BackupService(db).export(settings: notifier.toJson());
    final hash = backupFingerprint(json);
    if (!force && hash == s.driveLastHash) return false;
    if (interactive) Toasts.show('Backing up to Drive…', duration: const Duration(seconds: 30));
    await DriveBackupService.instance.backUp(
      db: db,
      photos: ref.read(photoStoreProvider),
      backupJson: json,
      interactive: interactive,
    );
    notifier.markDriveBackup(DateTime.now(), hash);
    if (interactive) Toasts.show('Backed up to Google Drive');
    return true;
  } on DriveBackupException catch (e) {
    notifier.setDriveError(e.message);
    if (interactive) Toasts.show(e.message);
    return false;
  } finally {
    busy.set(false);
  }
}

/// Called when the app opens or comes back: backs up quietly if it's been
/// most of a day and something changed.
Future<void> maybeAutoBackup(WidgetRef ref) async {
  final s = ref.read(settingsProvider);
  if (!driveConfigured || !s.has(AppFeature.drive) || !s.driveAuto || s.driveAccount == null) return;
  final last = s.driveLastBackupAt;
  if (last != null && DateTime.now().difference(last) < const Duration(hours: 20)) return;
  await backUpToDrive(ref);
}

/// Picks a backup from Drive and, once confirmed, replaces everything with
/// it. Signs in first if needed. True if restored.
Future<bool> restoreFromDrive(BuildContext context, WidgetRef ref) async {
  if (ref.read(settingsProvider).driveAccount == null) {
    final go = await showExplainerSheet(
      context,
      icon: GtIcons.google,
      title: 'Restore from Google Drive',
      body: 'Sign in with the Google account your GYMTRX backups are in.',
      action: 'Sign in with Google',
    );
    if (!go) return false;
    try {
      final email = await DriveBackupService.instance.signIn();
      ref.read(settingsProvider.notifier).setDriveAccount(email);
    } on DriveBackupException catch (e) {
      Toasts.show(e.message);
      return false;
    }
  }

  final List<DriveSnapshot> snapshots;
  try {
    Toasts.show('Looking for backups…', duration: const Duration(seconds: 20));
    snapshots = await DriveBackupService.instance.snapshots();
    Toasts.hide();
  } on DriveBackupException catch (e) {
    Toasts.show(e.message);
    return false;
  }
  if (!context.mounted) return false;
  if (snapshots.isEmpty) {
    Toasts.show('No GYMTRX backups in this Google account yet.');
    return false;
  }

  final picked = await showModalBottomSheet<DriveSnapshot>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
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
              padding: const EdgeInsets.fromLTRB(GtSpace.sm, GtSpace.xs, GtSpace.sm, GtSpace.md),
              child: Text('Choose a backup', style: GtText.title),
            ),
            for (final s in snapshots)
              SettingsRow(
                icon: GtIcons.cloudCheck,
                title: Fmt.dateTime(s.createdAt),
                subtitle: [
                  if (s.entries case final n?) Fmt.plural(n, 'entry', 'entries'),
                  if (s.photos case final n? when n > 0) Fmt.plural(n, 'photo'),
                ].join(' · '),
                onTap: () => Navigator.pop(context, s),
              ),
          ],
        ),
      ),
    ),
  );
  if (picked == null || !context.mounted) return false;

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: GtSpace.xs),
            Text('Replace everything?', style: GtText.title),
            const SizedBox(height: GtSpace.md),
            Text(
              'Everything currently on this phone will be replaced by the backup from ${Fmt.dateTime(picked.createdAt)}.',
              style: GtText.body.colored(GtColors.text2),
            ),
            const SizedBox(height: GtSpace.xxl),
            GtButton(
              label: 'Replace with backup',
              kind: GtButtonKind.danger,
              expand: true,
              onTap: () => Navigator.pop(context, true),
            ),
            const SizedBox(height: GtSpace.sm),
            GtButton(label: 'Cancel', kind: GtButtonKind.ghost, expand: true, onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    ),
  );
  if (confirmed != true) return false;

  final busy = ref.read(driveBusyProvider.notifier)..set(true);
  try {
    Toasts.show('Restoring…', duration: const Duration(minutes: 2));
    final tmp = await getTemporaryDirectory();
    final data = await DriveBackupService.instance.download(picked, stagingDir: '${tmp.path}/drive-photos');
    await BackupService(ref.read(databaseProvider), photos: ref.read(photoStoreProvider)).restore(data);
    ref.read(settingsProvider.notifier).restore(data.settings);
    Haptics.medium();
    Toasts.show('Backup restored');
    return true;
  } on DriveBackupException catch (e) {
    Toasts.show(e.message);
  } on FormatException catch (e) {
    Toasts.show(e.message);
  } on Exception {
    Toasts.show("Couldn't restore that backup. Nothing was changed.");
  } finally {
    busy.set(false);
  }
  return false;
}
