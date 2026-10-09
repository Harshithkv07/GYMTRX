import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../art/dot_body.dart';
import '../art/dot_text.dart';
import '../art/mist_background.dart';
import '../body_map/muscle_regions.dart';
import '../log/log_actions.dart';
import '../widgets/cardio_pill.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/labels.dart';
import '../widgets/surface.dart';

/// Everything recorded for one day, read-only: the trained muscles lit on a
/// large dot body, then the numbers, exercises and note. Edit opens the log
/// sheet.
class EntryDetailScreen extends ConsumerWidget {
  const EntryDetailScreen({super.key, required this.dayKey, this.heroTag});

  final int dayKey;

  /// The thumbnail this page grew out of, if it was opened from a card.
  final String? heroTag;

  static const _bodyHeight = 300.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(entryProvider(dayKey));
    final entry = async.value;
    final today = ref.watch(todayProvider);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final weight = ref.watch(bodyWeightByDayProvider)[dayKey];
    final padding = MediaQuery.paddingOf(context);
    final reduced = GtMotion.reduced(context);
    final groups = entry?.groups ?? const <MuscleGroup>[];
    final strength = regionsForGroups(groups);

    Widget reveal(Widget child, int i) => reduced
        ? child
        : child
              .animate()
              .fadeIn(duration: 360.ms, delay: (120 + 60 * i).ms)
              .moveY(begin: 12, end: 0, duration: 480.ms, delay: (120 + 60 * i).ms, curve: GtMotion.emphasized);

    final sections = <Widget>[
      if (entry != null) ...[
        _Stats(entry: entry, weightKg: weight?.weightKg, unit: unit),
        if (entry.exercises.isNotEmpty) ...[
          const SectionHeader('Exercises'),
          for (final e in entry.exercises) _ExerciseBlock(entry: e, unit: unit),
        ],
        if ((entry.session.note ?? '').isNotEmpty) ...[
          const SectionHeader('Note'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
            child: GtCard(child: Text(entry.session.note!, style: GtText.body)),
          ),
        ],
      ] else if (async.hasValue)
        Padding(
          padding: const EdgeInsets.all(GtSpace.x4),
          child: Text('Nothing logged on this day.', textAlign: TextAlign.center, style: GtText.body.colored(c.text2)),
        ),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: MistBackground()),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: padding.top + 64 + _bodyHeight + 12,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // A soft pool of accent light behind the figure.
                      Positioned(
                        bottom: 0,
                        width: _bodyHeight * 1.4,
                        height: _bodyHeight * 1.1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [c.accent.withValues(alpha: c.isDark ? 0.10 : 0.22), c.accent.withValues(alpha: 0)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        child: heroTag == null
                            ? DotBody(strength: strength, height: _bodyHeight, spacing: 3.3)
                            : Hero(
                                tag: heroTag!,
                                flightShuttleBuilder: (_, _, _, _, _) => FittedBox(
                                  child: DotBody(
                                    strength: strength,
                                    height: _bodyHeight,
                                    spacing: 3.3,
                                    reveal: false,
                                    glow: false,
                                  ),
                                ),
                                child: DotBody(strength: strength, height: _bodyHeight, spacing: 3.3),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.md, GtSpace.gutter, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Fmt.fullDate(dayKey)} · ${Fmt.relativeDay(dayKey, today)}'.toUpperCase(),
                        style: context.tx.tag,
                      ),
                      const SizedBox(height: GtSpace.sm),
                      DotText(
                        _title(groups),
                        style: GtText.dot(_titleSize(groups), weight: 400, height: 1.08).colored(c.text1),
                        delay: const Duration(milliseconds: 200),
                      ),
                      if (includesCardio(groups) && strength.isNotEmpty) ...[
                        const SizedBox(height: GtSpace.md),
                        const CardioPill(),
                      ],
                    ],
                  ),
                ),
              ),
              SliverList.list(children: [for (var i = 0; i < sections.length; i++) reveal(sections[i], i)]),
              SliverToBoxAdapter(child: SizedBox(height: padding.bottom + 110)),
            ],
          ),
          // Floating controls over the art, as in the reference.
          Positioned(
            top: padding.top + 6,
            left: GtSpace.lg,
            right: GtSpace.lg,
            child: Row(
              children: [
                CircleButton(icon: GtIcons.back, onTap: () => Navigator.maybePop(context), semanticLabel: 'Back'),
                const Spacer(),
                if (entry != null) ...[
                  CircleButton(
                    icon: GtIcons.edit,
                    onTap: () => openLogSheet(context, ref, dayKey: dayKey),
                    semanticLabel: 'Edit',
                  ),
                  const SizedBox(width: GtSpace.sm),
                  CircleButton(
                    icon: GtIcons.delete,
                    iconColor: c.danger,
                    semanticLabel: 'Delete',
                    onTap: () {
                      final repo = ref.read(sessionRepoProvider);
                      Navigator.pop(context);
                      // Let the page slide away before its content disappears.
                      Future.delayed(const Duration(milliseconds: 280), () => deleteEntryWithUndo(repo, dayKey));
                    },
                  ),
                ],
              ],
            ),
          ),
          if (entry != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(GtSpace.gutter, 30, GtSpace.gutter, padding.bottom + GtSpace.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.bg.withValues(alpha: 0), c.bg.withValues(alpha: 0.95)],
                    stops: const [0, 0.5],
                  ),
                ),
                child: GtButton(
                  label: entry.exercises.isEmpty ? 'Add exercises or a note' : 'Edit entry',
                  icon: entry.exercises.isEmpty ? GtIcons.add : null,
                  expand: true,
                  onTap: () => openLogSheet(context, ref, dayKey: dayKey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// "CHEST + TRICEPS"; wraps onto a second line when long.
  static String _title(List<MuscleGroup> groups) =>
      groups.isEmpty ? 'LOGGED' : groups.map((g) => g.name.toUpperCase()).join(' + ');

  static double _titleSize(List<MuscleGroup> groups) {
    final length = _title(groups).length;
    if (length <= 10) return 46;
    if (length <= 20) return 38;
    return 30;
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.entry, required this.weightKg, required this.unit});

  final EntryDetail entry;
  final double? weightKg;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final sets = entry.exercises.fold(0, (n, e) => n + e.sets.length);
    final tiles = <(String, String)>[
      if (entry.exercises.isNotEmpty) ('${entry.exercises.length}', entry.exercises.length == 1 ? 'exercise' : 'exercises'),
      if (sets > 0) ('$sets', sets == 1 ? 'set' : 'sets'),
      if (entry.session.durationMin != null) ('${entry.session.durationMin}', 'min'),
      if (weightKg != null) (Units.format(weightKg!, unit, withUnit: false, maxDecimals: 1), '${unit.name} body'),
    ];
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.xxl, GtSpace.lg, 0),
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: GtCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(GtText.figures(tiles[i].$1), style: GtText.dotFigure(28).colored(c.text1), maxLines: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(tiles[i].$2, style: GtText.caption.colored(c.text2), maxLines: 1),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseBlock extends ConsumerWidget {
  const _ExerciseBlock({required this.entry, required this.unit});

  final ExerciseEntry entry;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final group = ref.watch(groupsByIdProvider)[entry.exercise.groupId];
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, 10),
      child: GtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group != null) ...[
              Text(group.name.toUpperCase(), style: context.tx.tag),
              const SizedBox(height: 3),
            ],
            Text(entry.exercise.name, style: GtText.titleSmall.sized(16)),
            for (var i = 0; i < entry.sets.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? GtSpace.md : 6),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: ShapeDecoration(color: c.surface2, shape: const CircleBorder()),
                      child: Text('${i + 1}', style: GtText.monoSmall.colored(c.text2)),
                    ),
                    Text(formatSet(entry.sets[i], entry.exercise.kind, unit), style: GtText.mono.sized(15)),
                  ],
                ),
              ),
            if ((entry.row.note ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: GtSpace.sm),
                child: Text(entry.row.note!, style: GtText.caption.colored(c.text2)),
              ),
          ],
        ),
      ),
    );
  }
}
