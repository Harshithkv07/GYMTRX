import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../../data/database/app_database.dart';
import '../../data/models/guide.dart';
import '../../logic/guide_mapping.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/guide_providers.dart';
import '../body_map/body_map.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/toast.dart';

/// How to do [exercise]: pictures, muscles and steps from the exercise guide.
/// An exercise that isn't linked to the guide yet offers the closest matches.
Future<void> showExerciseGuide(BuildContext context, Exercise exercise) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: GtColors.s1,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.88,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    builder: (context, scroll) => _GuideSheet(exerciseId: exercise.id, scroll: scroll),
  ),
);

/// A guide entry on its own (from the guide browser), with an optional action.
Future<void> showGuideEntry(BuildContext context, GuideExercise guide, {Widget? action}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: GtColors.s1,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.88,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    builder: (context, scroll) => ListView(
      controller: scroll,
      padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.paddingOf(context).bottom + GtSpace.lg),
      children: [
        const SheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xs, GtSpace.gutter, 0),
          child: Text(guide.name, style: GtText.title),
        ),
        GuideBody(guide: guide),
        if (action != null)
          Padding(padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, 0), child: action),
      ],
    ),
  ),
);

class _GuideSheet extends ConsumerWidget {
  const _GuideSheet({required this.exerciseId, required this.scroll});

  final int exerciseId;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(exercisesByIdProvider)[exerciseId];
    final catalog = ref.watch(guideCatalogProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;
    if (exercise == null) return const SizedBox.shrink();
    final guide = catalog.value?[exercise.guideId];

    return ListView(
      controller: scroll,
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottom + GtSpace.lg),
      children: [
        const SheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xs, GtSpace.gutter, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exercise.name, style: GtText.title),
              if (guide != null && guide.name.toLowerCase() != exercise.name.toLowerCase())
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('Guide: ${guide.name}', style: GtText.caption),
                ),
            ],
          ),
        ),
        switch (catalog) {
          AsyncData() when guide != null => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GuideBody(guide: guide),
              Center(
                child: TextButton(
                  onPressed: () => ref.read(libraryRepoProvider).linkGuide(exercise.id, null),
                  child: Text('Not the right exercise? Change it', style: GtText.label.colored(GtColors.text2)),
                ),
              ),
            ],
          ),
          AsyncData(:final value) => _FindInGuide(exercise: exercise, catalog: value),
          AsyncError() => _Offline(onRetry: () => ref.invalidate(guideCatalogProvider)),
          _ => const Padding(
            padding: EdgeInsets.all(GtSpace.x4),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        },
      ],
    );
  }
}

/// Pictures, muscles, equipment and steps for one guide entry.
class GuideBody extends StatelessWidget {
  const GuideBody({super.key, required this.guide});

  final GuideExercise guide;

  @override
  Widget build(BuildContext context) {
    String names(List<String> muscles) => muscles.map((m) => m[0].toUpperCase() + m.substring(1)).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (guide.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.lg, GtSpace.lg, 0),
            child: _Frames(paths: guide.images),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.lg, GtSpace.gutter, 0),
          child: Wrap(
            spacing: GtSpace.sm,
            runSpacing: GtSpace.sm,
            children: [
              if (guide.equipment case final eq?) _Pill(guideEquipmentLabel(eq)),
              if (guide.level case final l?) _Pill(l[0].toUpperCase() + l.substring(1)),
              if (guide.mechanic case final m?) _Pill(m[0].toUpperCase() + m.substring(1)),
            ],
          ),
        ),
        if (guide.primaryMuscles.isNotEmpty) ...[
          const SectionHeader('Muscles'),
          Center(child: BodyMap(strength: guideBodyMap(guide), height: 190)),
          Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.lg, GtSpace.gutter, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MAIN', style: GtText.overline.colored(context.accent)),
                      const SizedBox(height: 2),
                      Text(names(guide.primaryMuscles), style: GtText.body),
                    ],
                  ),
                ),
                if (guide.secondaryMuscles.isNotEmpty) ...[
                  const SizedBox(width: GtSpace.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ALSO', style: GtText.overline.colored(GtColors.text3)),
                        const SizedBox(height: 2),
                        Text(names(guide.secondaryMuscles), style: GtText.body.colored(GtColors.text2)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (guide.instructions.isNotEmpty) ...[
          const SectionHeader('How to'),
          for (var i = 0; i < guide.instructions.length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 24, child: Text('${i + 1}', style: GtText.mono.colored(context.accent))),
                  Expanded(child: Text(guide.instructions[i], style: GtText.body)),
                ],
              ),
            ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.md, GtSpace.gutter, 0),
          child: GtButton(
            label: 'Watch form on YouTube',
            icon: GtIcons.play,
            kind: GtButtonKind.secondary,
            expand: true,
            onTap: () async {
              final uri = Uri.https('www.youtube.com', '/results', {'search_query': '${guide.name} proper form'});
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                Toasts.show('Couldn’t open YouTube.');
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.md, GtSpace.gutter, GtSpace.md),
          child: Text(
            'From the free exercise database (public domain).',
            textAlign: TextAlign.center,
            style: GtText.caption.colored(GtColors.text3),
          ),
        ),
      ],
    );
  }
}

/// Start and end position, crossfading like a two-frame animation.
class _Frames extends ConsumerStatefulWidget {
  const _Frames({required this.paths});

  final List<String> paths;

  @override
  ConsumerState<_Frames> createState() => _FramesState();
}

class _FramesState extends ConsumerState<_Frames> {
  var _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.paths.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
        if (mounted) setState(() => _i = (_i + 1) % widget.paths.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final files = [for (final p in widget.paths) ref.watch(guideImageProvider(p))];
    final ready = files.every((f) => f.hasValue);
    final current = files[_i].value;
    // The guide's pictures are all 3:2.
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.circular(GtRadius.lg),
        child: ColoredBox(
          // The guide's pictures are on white.
          color: Colors.white,
          child: !ready
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : current == null
              ? Center(
                  child: Text(
                    'Pictures need the internet the first time.',
                    style: GtText.caption.colored(Colors.black54),
                  ),
                )
              : AnimatedSwitcher(
                  duration: GtMotion.of(context, const Duration(milliseconds: 500)),
                  child: Image.file(current, key: ValueKey(_i), fit: BoxFit.cover, gaplessPlayback: true),
                ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(color: GtColors.s2, shape: squircle(9)),
      child: Text(text, style: GtText.label.colored(GtColors.text2)),
    );
  }
}

/// Links an exercise to a guide entry: closest names first, or search.
class _FindInGuide extends ConsumerStatefulWidget {
  const _FindInGuide({required this.exercise, required this.catalog});

  final Exercise exercise;
  final Map<String, GuideExercise> catalog;

  @override
  ConsumerState<_FindInGuide> createState() => _FindInGuideState();
}

class _FindInGuideState extends ConsumerState<_FindInGuide> {
  late String _query = widget.exercise.name;

  @override
  Widget build(BuildContext context) {
    final matches = guideMatches(_query, widget.catalog.values, limit: 12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.md, GtSpace.gutter, GtSpace.md),
          child: Text(
            'This exercise isn’t linked to the guide yet. Pick the one that matches and it’ll open straight away next time.',
            style: GtText.body.colored(GtColors.text2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          child: TextFormField(
            initialValue: _query,
            onChanged: (v) => setState(() => _query = v),
            style: GtText.body,
            decoration: const InputDecoration(
              hintText: 'Search the guide',
              prefixIcon: Icon(GtIcons.search, size: 18, color: GtColors.text2),
            ),
          ),
        ),
        const SizedBox(height: GtSpace.sm),
        if (matches.isEmpty)
          Padding(
            padding: const EdgeInsets.all(GtSpace.xl),
            child: Text('Nothing like that in the guide.', textAlign: TextAlign.center, style: GtText.caption),
          ),
        for (final g in matches)
          Pressable(
            onTap: () {
              Haptics.selection();
              ref.read(libraryRepoProvider).linkGuide(widget.exercise.id, g.id);
            },
            scale: 0.98,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter, vertical: GtSpace.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name, style: GtText.body),
                        Text(
                          [...g.primaryMuscles, if (g.equipment case final eq?) guideEquipmentLabel(eq)].join(' · '),
                          style: GtText.caption,
                        ),
                      ],
                    ),
                  ),
                  Icon(GtIcons.link, size: 16, color: context.accent),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Offline extends StatelessWidget {
  const _Offline({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GtSpace.xl),
      child: Column(
        children: [
          const Icon(GtIcons.globe, size: 28, color: GtColors.text2),
          const SizedBox(height: GtSpace.md),
          Text('Connect once to load the guide', style: GtText.titleSmall),
          const SizedBox(height: GtSpace.xs),
          Text(
            'It downloads the first time you open it, then works offline.',
            textAlign: TextAlign.center,
            style: GtText.caption,
          ),
          const SizedBox(height: GtSpace.lg),
          GtButton(label: 'Try again', kind: GtButtonKind.secondary, onTap: onRetry),
        ],
      ),
    );
  }
}
