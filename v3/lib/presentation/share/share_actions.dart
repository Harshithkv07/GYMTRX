// Share-as-image (trial). Everything for it lives in this folder; the call
// sites are the day page's share button, the record rows and the streak hero.
// To remove the feature, delete presentation/share/ and those call sites
// (search for "share/").
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/haptics.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/progress_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../../logic/records.dart';
import '../../logic/streaks.dart';
import '../progress/pr_format.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/toast.dart';
import 'share_cards.dart';

Future<void> shareDay(BuildContext context, WidgetRef ref, int dayKey) async {
  final entry = await ref.read(sessionRepoProvider).loadEntry(dayKey);
  if (entry == null || !context.mounted) return;
  final prs = ref.read(prIndexProvider);
  await _preview(
    context,
    title: 'Share this day',
    card: DayShareCard(
      entry: entry,
      unit: ref.read(settingsProvider).unit,
      prSetIds: {for (final e in entry.exercises) for (final s in e.sets) if (prs.isPrSet(s.id)) s.id},
    ),
    fileName: 'gymtrx-$dayKey',
  );
}

Future<void> sharePr(BuildContext context, WidgetRef ref, PrDayRecord record) {
  final hit = record.headline;
  final row = ref.read(setRecordByIdProvider)[hit.setId];
  final unit = ref.read(settingsProvider).unit;
  return _preview(
    context,
    title: 'Share record',
    card: PrShareCard(
      exercise: ref.read(exercisesByIdProvider)[record.exerciseId]?.name ?? 'Exercise',
      value: formatPrValue(hit, row, unit),
      gain: formatPrGain(hit, row, unit),
      metric: hit.metric.label.toLowerCase(),
      dayKey: record.dayKey,
    ),
    fileName: 'gymtrx-pr-${record.dayKey}',
  );
}

Future<void> shareStreak(BuildContext context, WidgetRef ref, StreakStats stats) {
  final today = ref.read(logicalTodayProvider);
  final year = DayKeys.year(today);
  final sessions = (ref.read(summariesProvider).value ?? const []).where((e) => DayKeys.year(e.dayKey) == year && e.dayKey <= today).length;
  return _preview(
    context,
    title: 'Share streak',
    card: StreakShareCard(
      weeks: stats.current,
      best: stats.best,
      goal: stats.thisWeekGoal,
      sessions: sessions,
    ),
    fileName: 'gymtrx-streak-${stats.current}',
  );
}

Future<void> _preview(BuildContext context, {required String title, required Widget card, required String fileName}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _SharePreview(title: title, card: card, fileName: fileName),
  );
}

class _SharePreview extends StatefulWidget {
  const _SharePreview({required this.title, required this.card, required this.fileName});

  final String title;
  final Widget card;
  final String fileName;

  @override
  State<_SharePreview> createState() => _SharePreviewState();
}

class _SharePreviewState extends State<_SharePreview> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final file = File('${(await getTemporaryDirectory()).path}/${widget.fileName}.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      Haptics.medium();
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'image/png')]));
      if (mounted) Navigator.pop(context);
    } on Exception {
      Toasts.show('Couldn’t share the image.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxCardWidth = media.size.width - GtSpace.gutter * 2;
    final scale = (maxCardWidth / ShareFrame.size.width).clamp(0.5, 1.0);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: GtSpace.xs),
            Text(widget.title, style: GtText.title),
            const SizedBox(height: GtSpace.lg),
            Center(
              child: SizedBox(
                width: ShareFrame.size.width * scale,
                height: ShareFrame.size.height * scale,
                child: FittedBox(
                  child: ClipRSuperellipse(
                    borderRadius: BorderRadius.circular(GtRadius.lg),
                    child: RepaintBoundary(
                      key: _boundary,
                      // Captured as drawn: no entrance animations, fixed text size.
                      child: MediaQuery(
                        data: media.copyWith(disableAnimations: true, textScaler: TextScaler.noScaling),
                        child: widget.card,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: GtSpace.xl),
            GtButton(
              label: _busy ? 'Preparing…' : 'Share image',
              icon: GtIcons.share,
              expand: true,
              haptic: PressHaptic.none,
              onTap: _busy ? null : _share,
            ),
          ],
        ),
      ),
    );
  }
}
