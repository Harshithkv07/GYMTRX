import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../logic/features.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/large_title_header.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';
import 'photo_actions.dart';

/// A rounded thumbnail, decoded small.
class PhotoThumb extends ConsumerWidget {
  const PhotoThumb({super.key, required this.photo, this.width = 76, this.height = 100, this.onTap});

  final ProgressPhoto photo;
  final double width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(photoRepoProvider).fileOf(photo);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Pressable(
      onTap: onTap,
      scale: 0.95,
      semanticLabel: 'Photo from ${Fmt.dayMonthYear(photo.dayKey)}',
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.circular(GtRadius.md),
        child: SizedBox(
          width: width,
          height: height,
          child: Image.file(
            file,
            fit: BoxFit.cover,
            cacheWidth: (width * dpr).round(),
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: GtColors.s2,
              child: Center(child: Icon(GtIcons.images, size: 18, color: GtColors.text3)),
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontal row of photos with an add tile at the start.
class PhotoStrip extends ConsumerWidget {
  const PhotoStrip({super.key, required this.photos, this.dayKey, this.showDates = true});

  final List<ProgressPhoto> photos;

  /// Day new photos are added to; null = today.
  final int? dayKey;
  final bool showDates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: showDates ? 122 : 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
        itemCount: photos.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: GtSpace.sm),
        itemBuilder: (context, i) {
          if (i == 0) return _AddTile(onTap: () => addProgressPhoto(context, ref, dayKey: dayKey));
          final p = photos[i - 1];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoThumb(photo: p, onTap: () => openPhotoViewer(context, photos, i - 1)),
              if (showDates) ...[
                const SizedBox(height: 4),
                Text(Fmt.dayMonth(p.dayKey), style: GtText.monoSmall.colored(GtColors.text3)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        semanticLabel: 'Add progress photo',
        child: Container(
          width: 76,
          height: 100,
          decoration: ShapeDecoration(
            color: context.gt.accentMuted,
            shape: squircle(GtRadius.md, side: BorderSide(color: context.gt.accentSoft)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(GtIcons.camera, size: 22, color: context.accent),
              const SizedBox(height: 6),
              Text('ADD', style: GtText.overline.colored(context.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Photos on the Progress tab: the latest few, the gallery and Compare.
class ProgressPhotosCard extends ConsumerWidget {
  const ProgressPhotosCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider).value ?? const <ProgressPhoto>[];
    if (photos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
        child: GtCard(
          padding: const EdgeInsets.all(GtSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('See the change', style: GtText.titleSmall),
              const SizedBox(height: GtSpace.xs),
              Text(
                'Take a photo every few weeks in the same spot and light, then compare any two side by side.',
                style: GtText.body.colored(GtColors.text2),
              ),
              const SizedBox(height: GtSpace.lg),
              GtButton(
                label: 'Add first photo',
                icon: GtIcons.camera,
                kind: GtButtonKind.secondary,
                height: 44,
                onTap: () => addProgressPhoto(context, ref),
              ),
            ],
          ),
        ),
      );
    }
    return PhotoStrip(photos: photos.take(12).toList());
  }
}

void openPhotoGallery(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PhotoGalleryScreen()));

void openPhotoCompare(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PhotoCompareScreen()));

/// Every photo, grouped by month.
class PhotoGalleryScreen extends ConsumerWidget {
  const PhotoGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider).value ?? const <ProgressPhoto>[];
    final padding = MediaQuery.paddingOf(context);
    final months = <YearMonth, List<int>>{};
    for (var i = 0; i < photos.length; i++) {
      months.putIfAbsent(yearMonthOf(photos[i].dayKey), () => []).add(i);
    }

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(
              title: 'Photos',
              topPadding: padding.top,
              showBack: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (photos.length >= 2)
                    GtIconButton(
                      icon: GtIcons.compare,
                      onTap: () => openPhotoCompare(context),
                      color: Colors.transparent,
                      semanticLabel: 'Compare',
                    ),
                  GtIconButton(
                    icon: GtIcons.camera,
                    onTap: () => addProgressPhoto(context, ref),
                    color: Colors.transparent,
                    semanticLabel: 'Add photo',
                  ),
                ],
              ),
            ),
          ),
          if (photos.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(GtSpace.x4),
                child: Text('No photos yet.', textAlign: TextAlign.center, style: GtText.body.colored(GtColors.text2)),
              ),
            ),
          for (final MapEntry(key: m, value: indexes) in months.entries) ...[
            SliverToBoxAdapter(child: SectionHeader('${Fmt.monthName(m.month)} ${m.year}')),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: GtSpace.sm,
                  crossAxisSpacing: GtSpace.sm,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: indexes.length,
                itemBuilder: (context, j) => LayoutBuilder(
                  builder: (context, c) => PhotoThumb(
                    photo: photos[indexes[j]],
                    width: c.maxWidth,
                    height: c.maxHeight,
                    onTap: () => openPhotoViewer(context, photos, indexes[j]),
                  ),
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom + GtSpace.x4)),
        ],
      ),
    );
  }
}

void openPhotoViewer(BuildContext context, List<ProgressPhoto> photos, int index) =>
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        transitionDuration: GtMotion.of(context, GtMotion.medium),
        reverseTransitionDuration: GtMotion.of(context, GtMotion.fast),
        pageBuilder: (_, _, _) => _PhotoViewer(photos: photos, initial: index),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );

/// Full-screen, swipeable, pinch to zoom.
class _PhotoViewer extends ConsumerStatefulWidget {
  const _PhotoViewer({required this.photos, required this.initial});

  final List<ProgressPhoto> photos;
  final int initial;

  @override
  ConsumerState<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends ConsumerState<_PhotoViewer> {
  late final _pages = PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(photoRepoProvider);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final weights = ref.watch(bodyWeightByDayProvider);
    final padding = MediaQuery.paddingOf(context);
    final photo = widget.photos[_index];
    final w = weights[photo.dayKey];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              maxScale: 4,
              child: Center(child: Image.file(repo.fileOf(widget.photos[i]), fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            top: padding.top + GtSpace.sm,
            left: GtSpace.md,
            right: GtSpace.md,
            child: Row(
              children: [
                GtIconButton(
                  icon: GtIcons.close,
                  onTap: () => Navigator.pop(context),
                  color: Colors.black45,
                  semanticLabel: 'Close',
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(Fmt.weekdayDayMonth(photo.dayKey), style: GtText.titleSmall),
                      if (w != null) Text(Units.format(w.weightKg, unit, maxDecimals: 1), style: GtText.caption),
                    ],
                  ),
                ),
                GtIconButton(
                  icon: GtIcons.delete,
                  iconColor: GtColors.danger,
                  color: Colors.black45,
                  semanticLabel: 'Delete photo',
                  onTap: () {
                    Navigator.pop(context);
                    deletePhotoWithUndo(ref, photo);
                  },
                ),
              ],
            ),
          ),
          if (widget.photos.length >= 2)
            Positioned(
              left: 0,
              right: 0,
              bottom: padding.bottom + GtSpace.xl,
              child: Center(
                child: GtButton(
                  label: 'Compare',
                  icon: GtIcons.compare,
                  kind: GtButtonKind.secondary,
                  height: 44,
                  onTap: () => Navigator.of(
                    context,
                  ).pushReplacement(MaterialPageRoute<void>(builder: (_) => PhotoCompareScreen(initialAfter: photo))),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _CompareMode { sideBySide, slider }

/// Two photos, before and after: side by side, or one wiped over the other.
class PhotoCompareScreen extends ConsumerStatefulWidget {
  const PhotoCompareScreen({super.key, this.initialAfter});

  final ProgressPhoto? initialAfter;

  @override
  ConsumerState<PhotoCompareScreen> createState() => _PhotoCompareScreenState();
}

class _PhotoCompareScreenState extends ConsumerState<PhotoCompareScreen> {
  ProgressPhoto? _before;
  ProgressPhoto? _after;
  var _mode = _CompareMode.sideBySide;
  double _split = 0.5;

  Future<void> _choose(bool before, List<ProgressPhoto> photos) async {
    final picked = await showModalBottomSheet<ProgressPhoto>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            children: [
              const SheetHandle(),
              Padding(
                padding: const EdgeInsets.all(GtSpace.md),
                child: Text(before ? 'Before' : 'After', style: GtText.title),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(GtSpace.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: GtSpace.sm,
                    crossAxisSpacing: GtSpace.sm,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, i) => LayoutBuilder(
                    builder: (context, c) => PhotoThumb(
                      photo: photos[i],
                      width: c.maxWidth,
                      height: c.maxHeight,
                      onTap: () => Navigator.pop(context, photos[i]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => before ? _before = picked : _after = picked);
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(photosProvider).value ?? const <ProgressPhoto>[];
    final repo = ref.watch(photoRepoProvider);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final weights = ref.watch(settingsProvider.select((s) => s.has(AppFeature.bodyWeight)))
        ? ref.watch(bodyWeightsProvider).value ?? const <BodyWeight>[]
        : const <BodyWeight>[];
    final padding = MediaQuery.paddingOf(context);
    if (photos.length < 2) {
      return Scaffold(
        backgroundColor: GtColors.bg,
        body: Center(child: Text('Add at least two photos to compare.', style: GtText.body.colored(GtColors.text2))),
      );
    }
    final after = _after ?? widget.initialAfter ?? photos.first;
    final before = _before ?? photos.last;

    String caption(ProgressPhoto p) {
      final w = weights.where((x) => x.dayKey <= p.dayKey).lastOrNull;
      final days = DayKeys.daysBetween(before.dayKey, after.dayKey).abs();
      return [
        Fmt.dayMonthYear(p.dayKey),
        if (w != null) Units.format(w.weightKg, unit, maxDecimals: 1),
        if (identical(p, after) && days > 0) '+${Fmt.plural(days, 'day')}',
      ].join(' · ');
    }

    Widget image(ProgressPhoto p) => Image.file(repo.fileOf(p), fit: BoxFit.cover);

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: Column(
        children: [
          SizedBox(height: padding.top),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GtSpace.md, vertical: GtSpace.sm),
            child: Row(
              children: [
                GtIconButton(icon: GtIcons.back, onTap: () => Navigator.pop(context), semanticLabel: 'Back'),
                const SizedBox(width: GtSpace.md),
                Expanded(child: Text('Compare', style: GtText.title)),
                SizedBox(
                  width: 170,
                  child: GtSegmented<_CompareMode>(
                    values: _CompareMode.values,
                    selected: _mode,
                    labelOf: (m) => m == _CompareMode.sideBySide ? 'Side by side' : 'Slider',
                    onChanged: (m) => setState(() => _mode = m),
                    height: 34,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
              child: _mode == _CompareMode.sideBySide
                  ? Row(
                      children: [
                        for (final (label, p, isBefore) in [('BEFORE', before, true), ('AFTER', after, false)]) ...[
                          if (!isBefore) const SizedBox(width: GtSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Pressable(
                                    onTap: () => _choose(isBefore, photos),
                                    scale: 0.98,
                                    child: ClipRSuperellipse(
                                      borderRadius: BorderRadius.circular(GtRadius.lg),
                                      child: SizedBox.expand(child: image(p)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: GtSpace.sm),
                                Text(label, style: GtText.overline),
                                Text(caption(p), style: GtText.caption, maxLines: 2),
                              ],
                            ),
                          ),
                        ],
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, c) => GestureDetector(
                              onHorizontalDragUpdate: (d) =>
                                  setState(() => _split = (_split + d.delta.dx / c.maxWidth).clamp(0.0, 1.0)),
                              child: ClipRSuperellipse(
                                borderRadius: BorderRadius.circular(GtRadius.lg),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    image(after),
                                    ClipRect(clipper: _LeftClipper(_split), child: image(before)),
                                    Positioned(
                                      left: c.maxWidth * _split - 1,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(width: 2, color: Colors.white),
                                    ),
                                    Positioned(
                                      left: c.maxWidth * _split - 18,
                                      top: c.maxHeight / 2 - 18,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: const Icon(GtIcons.compare, size: 18, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: GtSpace.sm),
                        Row(
                          children: [
                            Expanded(
                              child: Pressable(
                                onTap: () => _choose(true, photos),
                                child: Text('BEFORE · ${caption(before)}', style: GtText.caption, maxLines: 2),
                              ),
                            ),
                            const SizedBox(width: GtSpace.md),
                            Expanded(
                              child: Pressable(
                                onTap: () => _choose(false, photos),
                                child: Text(
                                  'AFTER · ${caption(after)}',
                                  textAlign: TextAlign.end,
                                  style: GtText.caption,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, padding.bottom + GtSpace.md),
            child: Text('Tap a photo to change it.', textAlign: TextAlign.center, style: GtText.caption),
          ),
        ],
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  _LeftClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftClipper old) => old.fraction != fraction;
}
