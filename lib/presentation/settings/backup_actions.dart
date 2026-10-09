import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/services/backup_service.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/toast.dart';
import 'settings_widgets.dart';

enum _ExportTarget { folder, share }

/// Exports everything to one JSON file: saved to a folder or shared.
Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  final service = BackupService(ref.read(databaseProvider));
  final settings = ref.read(settingsProvider.notifier);
  final target = await showModalBottomSheet<_ExportTarget>(
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
              padding: const EdgeInsets.fromLTRB(GtSpace.sm, GtSpace.xs, GtSpace.sm, GtSpace.lg),
              child: Text('Export backup', style: GtText.title),
            ),
            SettingsRow(
              icon: GtIcons.folder,
              title: 'Save to a folder',
              subtitle: 'Downloads, Drive or any folder you pick',
              onTap: () => Navigator.pop(context, _ExportTarget.folder),
            ),
            SettingsRow(
              icon: GtIcons.share,
              title: 'Share',
              subtitle: 'Send it to Drive, email or a chat',
              onTap: () => Navigator.pop(context, _ExportTarget.share),
            ),
          ],
        ),
      ),
    ),
  );
  if (target == null) return;

  final json = await service.export(settings: settings.toJson());
  final name = 'gymtrx-backup-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
  final bytes = Uint8List.fromList(utf8.encode(json));

  try {
    switch (target) {
      case _ExportTarget.folder:
        final uri = await FilePicker.saveFile(fileName: name, bytes: bytes, mimeType: 'application/json');
        if (uri == null) return;
      case _ExportTarget.share:
        final file = File('${(await getTemporaryDirectory()).path}/$name');
        await file.writeAsBytes(bytes);
        final result = await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path, mimeType: 'application/json')], subject: 'GYMTRX backup'),
        );
        if (result.status == ShareResultStatus.dismissed) return;
    }
  } on Exception {
    Toasts.show("Couldn't export the backup.");
    return;
  }
  settings.markExported(DateTime.now());
  Haptics.medium();
  Toasts.show('Backup exported');
}

/// Picks a backup file, shows what's in it and, if confirmed, replaces all data.
Future<void> importBackup(BuildContext context, WidgetRef ref) async {
  final service = BackupService(ref.read(databaseProvider));
  final settings = ref.read(settingsProvider.notifier);

  final List<PlatformFile> files;
  try {
    files = await FilePicker.pickFiles(dialogTitle: 'Choose a GYMTRX backup');
  } on Exception {
    Toasts.show("Couldn't open the file picker.");
    return;
  }
  if (files.isEmpty) return;

  final BackupData data;
  try {
    final text = utf8.decode(await files.first.readAsBytes());
    data = await compute(BackupService.parse, text);
  } on FormatException catch (e) {
    Toasts.show(e.message);
    return;
  } on Exception {
    Toasts.show("Couldn't read that file.");
    return;
  }

  if (!context.mounted) return;
  final range = data.firstDay == null
      ? 'No entries'
      : '${Fmt.plural(data.entryCount, 'entry', 'entries')} · ${Fmt.dayMonthYear(data.firstDay!)} → ${Fmt.dayMonthYear(data.lastDay!)}';
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
            Text(range, style: GtText.body),
            const SizedBox(height: 4),
            Text(Fmt.plural(data.weighInCount, 'weigh-in'), style: GtText.body.colored(GtColors.text2)),
            const SizedBox(height: GtSpace.lg),
            Text(
              'Everything currently on this phone will be replaced by this backup.',
              style: GtText.caption,
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
  if (confirmed != true) return;

  try {
    await service.restore(data);
  } on Exception {
    Toasts.show("Couldn't restore that backup. Nothing was changed.");
    return;
  }
  settings.restore(data.settings);
  Haptics.medium();
  Toasts.show('Backup restored');
}
