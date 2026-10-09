import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../calendar/entry_card.dart';
import '../log/log_actions.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/labels.dart';
import '../widgets/surface.dart';
import 'entry_body_map.dart';

/// Everything recorded for one day, read-only. Edit opens the log sheet.
class EntryDetailScreen extends ConsumerWidget {
  const EntryDetailScreen({super.key, required this.dayKey});

  final int dayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(entryProvider(dayKey));
    final entry = async.value;
    final today = ref.watch(todayProvider);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final weight = ref.watch(bodyWeightByDayProvider)[dayKey];
    final padding = MediaQuery.paddingOf(context);
    final reduced = GtMotion.reduced(context);

    Widget reveal(Widget child, int i) => reduced
        ? child
        : child
              .animate()
              .fadeIn(duration: 360.ms, delay: (60 * i).ms)
              .moveY(begin: 12, end: 0, duration: 480.ms, delay: (60 * i).ms, curve: GtMotion.emphasized);

    final sections = <Widget>[
      if (entry != null) ...[
        _GroupPills(groups: entry.groups),
        EntryBodyMap(groups: entry.groups),
        _Stats(entry: entry, weightKg: weight?.weightKg, unit: unit),
        if (entry.exercises.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.xxl, GtSpace.lg, 0),
            child: GtButton(
              label: 'Add exercises or a note',
              icon: GtIcons.add,
              kind: GtButtonKind.secondary,
              expand: true,
              onTap: () => openLogSheet(context, ref, dayKey: dayKey),
            ),
          )
        else ...[
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
          child: Text('Nothing logged on this day.', textAlign: TextAlign.center, style: GtText.body.colored(GtColors.text2)),
        ),
    ];

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _DetailBarDelegate(
              topPadding: padding.top,
              title: Fmt.weekdayDayMonth(dayKey),
              onEdit: entry == null ? null : () => openLogSheet(context, ref, dayKey: dayKey),
              onDelete: entry == null
                  ? null
                  : () {
                      final repo = ref.read(sessionRepoProvider);
                      Navigator.pop(context);
                      // Let the page slide away before its content disappears.
                      Future.delayed(const Duration(milliseconds: 280), () => deleteEntryWithUndo(repo, dayKey));
                    },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.sm, GtSpace.gutter, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Hero(
                    tag: 'entry-date-$dayKey',
                    child: Material(type: MaterialType.transparency, child: DateBlock(dayKey: dayKey, large: true)),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Fmt.relativeDay(dayKey, today), style: GtText.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          '${Fmt.monthName(DayKeys.month(dayKey))} ${DayKeys.year(dayKey)}',
                          style: GtText.label.colored(GtColors.text2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList.list(children: [for (var i = 0; i < sections.length; i++) reveal(sections[i], i)]),
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom + GtSpace.x4)),
        ],
      ),
    );
  }
}

class _DetailBarDelegate extends SliverPersistentHeaderDelegate {
  _DetailBarDelegate({required this.topPadding, required this.title, required this.onEdit, required this.onDelete});

  final double topPadding;
  final String title;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  double get minExtent => topPadding + 60;

  @override
  double get maxExtent => topPadding + 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedOpacity(
          duration: GtMotion.medium,
          opacity: overlapsContent ? 1 : 0,
          child: ClipRect(
            child: BackdropFilter.grouped(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: GtColors.bg.withValues(alpha: 0.72),
                  border: const Border(bottom: BorderSide(color: GtColors.hairline)),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: topPadding,
          left: GtSpace.md,
          right: GtSpace.md,
          height: 60,
          child: Row(
            children: [
              GtIconButton(icon: GtIcons.back, onTap: () => Navigator.maybePop(context), semanticLabel: 'Back'),
              Expanded(
                child: AnimatedOpacity(
                  duration: GtMotion.medium,
                  opacity: overlapsContent ? 1 : 0,
                  child: Text(title, textAlign: TextAlign.center, style: GtText.titleSmall),
                ),
              ),
              if (onEdit != null) ...[
                GtIconButton(icon: GtIcons.edit, onTap: onEdit, semanticLabel: 'Edit'),
                const SizedBox(width: GtSpace.sm),
                GtIconButton(icon: GtIcons.delete, onTap: onDelete, semanticLabel: 'Delete', iconColor: GtColors.danger),
              ] else
                const SizedBox(width: 40),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_DetailBarDelegate old) =>
      old.title != title || old.topPadding != topPadding || (old.onEdit == null) != (onEdit == null);
}

class _GroupPills extends StatelessWidget {
  const _GroupPills({required this.groups});

  final List<MuscleGroup> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xxl, GtSpace.gutter, 0),
      child: Wrap(
        spacing: GtSpace.sm,
        runSpacing: GtSpace.sm,
        children: [
          for (final g in groups)
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: ShapeDecoration(color: context.gt.accentMuted, shape: squircle(17)),
              child: Center(
                widthFactor: 1,
                child: Text(g.name, style: GtText.label.sized(14).weight(600).colored(context.accent)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.entry, required this.weightKg, required this.unit});

  final EntryDetail entry;
  final double? weightKg;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
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
            if (i > 0) const SizedBox(width: GtSpace.sm),
            Expanded(
              child: GtCard(
                padding: const EdgeInsets.symmetric(horizontal: GtSpace.md, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tiles[i].$1, style: GtText.monoTitle.sized(22), maxLines: 1),
                    const SizedBox(height: 2),
                    Text(tiles[i].$2, style: GtText.caption, maxLines: 1),
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

class _ExerciseBlock extends StatelessWidget {
  const _ExerciseBlock({required this.entry, required this.unit});

  final ExerciseEntry entry;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, 10),
      child: GtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.exercise.name, style: GtText.titleSmall.sized(16)),
            for (var i = 0; i < entry.sets.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? GtSpace.md : 6),
                child: Row(
                  children: [
                    SizedBox(width: 24, child: Text('${i + 1}', style: GtText.monoSmall.colored(GtColors.text3))),
                    Text(formatSet(entry.sets[i], entry.exercise.kind, unit), style: GtText.mono.sized(15)),
                  ],
                ),
              ),
            if ((entry.row.note ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: GtSpace.sm),
                child: Text(entry.row.note!, style: GtText.caption),
              ),
          ],
        ),
      ),
    );
  }
}
