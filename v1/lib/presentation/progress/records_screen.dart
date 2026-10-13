import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/progress_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../../logic/records.dart';
import '../log/log_actions.dart';
import '../widgets/controls.dart';
import '../widgets/large_title_header.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';
import 'pr_format.dart';

/// One day's record for one exercise: trophy, name, the set, the gain.
class PrDayRow extends ConsumerWidget {
  const PrDayRow({super.key, required this.record, this.onShare});

  final PrDayRecord record;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final today = ref.watch(todayProvider);
    final exercise = ref.watch(exercisesByIdProvider)[record.exerciseId];
    final rows = ref.watch(setRecordByIdProvider);
    final hit = record.headline;
    final row = rows[hit.setId];

    return Pressable(
      onTap: () => openEntry(context, record.dayKey),
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.sm, GtSpace.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(color: GtColors.goldMuted, shape: squircle(GtRadius.sm)),
              child: const Icon(GtIcons.trophy, size: 18, color: GtColors.gold),
            ),
            const SizedBox(width: GtSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise?.name ?? 'Exercise',
                    style: GtText.body.weight(500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: formatPrValue(hit, row, unit), style: GtText.label.colored(GtColors.text1)),
                        TextSpan(
                          text: '  ${formatPrGain(hit, row, unit)}',
                          style: GtText.label.weight(600).colored(GtColors.gold),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: GtSpace.sm),
            Text(Fmt.relativeDay(record.dayKey, today), style: GtText.caption),
            if (onShare != null)
              Pressable(
                onTap: onShare,
                scale: 0.9,
                semanticLabel: 'Share record',
                child: const Padding(
                  padding: EdgeInsets.all(GtSpace.sm),
                  child: Icon(GtIcons.share, size: 16, color: GtColors.text2),
                ),
              )
            else
              const SizedBox(width: GtSpace.sm),
          ],
        ),
      ),
    );
  }
}

/// Every record, newest first, plus the current bests for each exercise.
class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key, this.onShare});

  final void Function(BuildContext context, PrDayRecord record)? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(prIndexProvider);
    final recent = index.recent(limit: 200);
    final exercises = ref.watch(exercisesByIdProvider);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final padding = MediaQuery.paddingOf(context);
    final bests = [
      for (final MapEntry(key: id, value: m) in index.bests.entries)
        if (exercises[id] case final ex?) (ex, m),
    ]..sort((a, b) => a.$1.name.compareTo(b.$1.name));

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(title: 'Records', topPadding: padding.top, showBack: true),
          ),
          SliverList.list(
            children: [
              const SectionHeader('Recent'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
                child: recent.isEmpty
                    ? GtCard(
                        padding: const EdgeInsets.all(GtSpace.xl),
                        child: Text(
                          'Beat a previous best and it lands here, with a trophy on the set.',
                          style: GtText.body.colored(GtColors.text2),
                        ),
                      )
                    : GtCard(
                        padding: const EdgeInsets.symmetric(vertical: GtSpace.xs),
                        child: Column(
                          children: [
                            for (var i = 0; i < recent.length; i++) ...[
                              if (i > 0) const Divider(indent: GtSpace.lg + 40 + GtSpace.md),
                              PrDayRow(
                                record: recent[i],
                                onShare: onShare == null ? null : () => onShare!(context, recent[i]),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
              if (bests.isNotEmpty) ...[
                const SectionHeader('Best ever'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
                  child: GtCard(
                    padding: const EdgeInsets.symmetric(vertical: GtSpace.sm),
                    child: Column(
                      children: [for (final (ex, m) in bests) _BestRow(exercise: ex, bests: m, unit: unit)],
                    ),
                  ),
                ),
              ],
              SizedBox(height: padding.bottom + GtSpace.x4),
            ],
          ),
        ],
      ),
    );
  }
}

class _BestRow extends StatelessWidget {
  const _BestRow({required this.exercise, required this.bests, required this.unit});

  final Exercise exercise;
  final Map<PrMetric, PrBest> bests;
  final WeightUnit unit;

  String _value(PrMetric m, double v) => switch (m) {
    PrMetric.heaviest => Units.format(v, unit),
    PrMetric.e1rm => '1RM ~${Units.format(v, unit, maxDecimals: 1)}',
    PrMetric.reps => Fmt.plural(v.round(), 'rep'),
    PrMetric.distance => '${Fmt.number(v)} km',
    PrMetric.duration =>
      exercise.kind == ExerciseKind.cardio ? Fmt.duration((v / 60).round()) : Fmt.clock(v.round()),
  };

  @override
  Widget build(BuildContext context) {
    final parts = [for (final m in PrMetric.values) if (bests[m] case final b?) _value(m, b.value)];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: GtSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(exercise.name, style: GtText.label.colored(GtColors.text1))),
          const SizedBox(width: GtSpace.md),
          Flexible(
            child: Text(parts.join(' · '), textAlign: TextAlign.end, style: GtText.monoSmall.sized(12).colored(GtColors.text2)),
          ),
        ],
      ),
    );
  }
}

/// The latest few records on the Progress tab.
class RecentRecordsCard extends ConsumerWidget {
  const RecentRecordsCard({super.key, this.onShare, this.onShareFromList});

  final void Function(PrDayRecord record)? onShare;
  final void Function(BuildContext context, PrDayRecord record)? onShareFromList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(prIndexProvider);
    final recent = index.recent(limit: 4);
    if (recent.isEmpty) {
      return GtCard(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: Row(
          children: [
            const Icon(GtIcons.trophy, size: 22, color: GtColors.s3),
            const SizedBox(width: GtSpace.md),
            Expanded(
              child: Text(
                'Log weights and reps. Beat a previous best and it shows up here.',
                style: GtText.body.colored(GtColors.text2),
              ),
            ),
          ],
        ),
      );
    }
    return GtCard(
      padding: const EdgeInsets.symmetric(vertical: GtSpace.xs),
      child: Column(
        children: [
          for (var i = 0; i < recent.length; i++) ...[
            if (i > 0) const Divider(indent: GtSpace.lg + 40 + GtSpace.md),
            PrDayRow(record: recent[i], onShare: onShare == null ? null : () => onShare!(recent[i])),
          ],
          Pressable(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => RecordsScreen(onShare: onShareFromList)),
            ),
            scale: 0.98,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.md),
              child: Row(
                children: [
                  Text(
                    'All ${Fmt.plural(index.recent(limit: 1000).length, 'record')}',
                    style: GtText.label.weight(600).colored(context.accent),
                  ),
                  const Spacer(),
                  Icon(GtIcons.chevronRight, size: 14, color: context.accent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
