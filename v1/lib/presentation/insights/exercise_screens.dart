import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../log/log_actions.dart';
import '../widgets/large_title_header.dart';
import '../widgets/labels.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';
import 'charts.dart';

/// "Bench Press · 12× · last Fri 3 Oct", opening its full history.
class ExerciseStatRow extends StatelessWidget {
  const ExerciseStatRow({super.key, required this.stat, required this.today});

  final ExerciseStat stat;
  final int today;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ExerciseHistoryScreen(exercise: stat.exercise)),
      ),
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(stat.exercise.name, style: GtText.body.weight(500), maxLines: 1)),
            Text('${stat.count}×', style: GtText.mono.sized(13).colored(GtColors.text2)),
            SizedBox(
              width: 96,
              child: Text(Fmt.relativeDay(stat.lastDayKey, today), textAlign: TextAlign.end, style: GtText.caption),
            ),
            const SizedBox(width: GtSpace.sm),
            const Icon(GtIcons.chevronRight, size: 14, color: GtColors.text3),
          ],
        ),
      ),
    );
  }
}

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(exerciseStatsProvider).value ?? const <ExerciseStat>[];
    final today = ref.watch(todayProvider);
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty ? stats : stats.where((s) => s.exercise.name.toLowerCase().contains(q)).toList();
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(title: 'Exercises', topPadding: padding.top, showBack: true),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.sm, GtSpace.lg, GtSpace.lg),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: GtText.body,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(GtIcons.search, size: 18, color: GtColors.text2),
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: shown.length,
            itemBuilder: (context, i) => ExerciseStatRow(stat: shown[i], today: today),
          ),
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom + GtSpace.x4)),
        ],
      ),
    );
  }
}

/// Every day an exercise was logged, newest first, with a weight chart when
/// weights were recorded.
class ExerciseHistoryScreen extends ConsumerWidget {
  const ExerciseHistoryScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(exerciseHistoryProvider(exercise.id)).value ?? const <ExerciseHistoryItem>[];
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final today = ref.watch(todayProvider);
    final padding = MediaQuery.paddingOf(context);

    // Heaviest set per day, oldest first, for the chart.
    final points = <(int, double)>[
      for (final h in history.reversed)
        if (h.sets.map((s) => s.weightKg).nonNulls case final ws when ws.isNotEmpty)
          (h.dayKey, Units.toDisplay(ws.reduce((a, b) => a > b ? a : b), unit)),
    ];

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(title: exercise.name, topPadding: padding.top, showBack: true),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
              child: Text(
                history.isEmpty ? 'Not logged yet.' : '${Fmt.plural(history.length, 'time')} · since ${Fmt.dayMonthYear(history.last.dayKey)}',
                style: GtText.label.colored(GtColors.text2),
              ),
            ),
          ),
          if (points.length >= 2)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, GtSpace.lg),
                child: GtCard(
                  padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.lg, GtSpace.sm, GtSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HEAVIEST SET PER DAY', style: GtText.overline),
                      const SizedBox(height: GtSpace.lg),
                      WeightLine(points: points, unitLabel: unit.name),
                    ],
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
            sliver: SliverList.separated(
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final h = history[i];
                return GtCard(
                  onTap: () => openEntry(context, h.dayKey),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(Fmt.weekdayDayMonth(h.dayKey), style: GtText.titleSmall.sized(15)),
                          const Spacer(),
                          Text(Fmt.relativeDay(h.dayKey, today), style: GtText.caption),
                        ],
                      ),
                      if (h.sets.isNotEmpty) ...[
                        const SizedBox(height: GtSpace.sm),
                        Text(
                          h.sets.map((s) => formatSet(s, exercise.kind, unit)).join('   '),
                          style: GtText.mono.sized(14).colored(GtColors.text1),
                        ),
                      ],
                      if ((h.note ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(h.note!, style: GtText.caption),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom + GtSpace.x4)),
        ],
      ),
    );
  }
}
