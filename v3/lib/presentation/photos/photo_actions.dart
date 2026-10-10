import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../../data/database/app_database.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../settings/settings_widgets.dart';
import '../widgets/controls.dart';
import '../widgets/toast.dart';

const _maxSide = 2048.0;
const _quality = 85;

/// Camera or gallery, then stores the photo against [dayKey] (default:
/// today, by the "day starts at" rule).
Future<void> addProgressPhoto(BuildContext context, WidgetRef ref, {int? dayKey}) async {
  final source = await showModalBottomSheet<ImageSource>(
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
              child: Text('Progress photo', style: GtText.title),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.sm, 0, GtSpace.sm, GtSpace.md),
              child: Text('Kept inside GYMTRX only. It won’t appear in your gallery.', style: GtText.caption),
            ),
            SettingsRow(
              icon: GtIcons.camera,
              title: 'Take a photo',
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            SettingsRow(
              icon: GtIcons.images,
              title: 'Choose from gallery',
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    ),
  );
  if (source == null) return;

  final int day = dayKey ?? ref.read(logicalTodayProvider);
  final settings = ref.read(settingsProvider.notifier);
  // Remembered in case Android kills GYMTRX while the camera is open.
  settings.pendingPhotoDay = day;
  final XFile? picked;
  try {
    picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
      requestFullMetadata: false,
    );
  } on PlatformException catch (e) {
    settings.pendingPhotoDay = null;
    Toasts.show(e.code == 'no_available_camera' ? 'No camera found on this phone.' : 'Couldn’t open the camera.');
    return;
  }
  settings.pendingPhotoDay = null;
  if (picked == null) return;
  await ref.read(photoRepoProvider).add(day, picked.path);
  Haptics.medium();
  Toasts.show('Photo added');
}

/// Recovers a photo whose camera hand-off outlived the app process.
Future<void> recoverLostPhoto(WidgetRef ref) async {
  final settings = ref.read(settingsProvider.notifier);
  final day = settings.pendingPhotoDay;
  if (day == null) return;
  try {
    final lost = await ImagePicker().retrieveLostData();
    final file = lost.file;
    if (!lost.isEmpty && file != null) {
      await ref.read(photoRepoProvider).add(day, file.path);
      Toasts.show('Photo added');
    }
  } on Object {
    // Nothing to recover (or no picker in tests).
  }
  settings.pendingPhotoDay = null;
}

/// Deletes with an undo, and frees the file once undo has expired.
Future<void> deletePhotoWithUndo(WidgetRef ref, ProgressPhoto photo) async {
  final repo = ref.read(photoRepoProvider);
  await repo.remove(photo);
  Haptics.heavy();
  var undone = false;
  Toasts.show(
    'Photo deleted',
    actionLabel: 'Undo',
    onAction: () {
      undone = true;
      repo.restore(photo);
    },
  );
  Future.delayed(const Duration(seconds: 6), () {
    if (!undone) repo.purge(photo);
  });
}
