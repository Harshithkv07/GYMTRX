import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/insights.dart';
import '../../logic/trends.dart';
import '../../logic/features.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/navigation_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../log/log_actions.dart';
import '../log/weigh_in_sheet.dart';
import '../settings/connection_settings.dart';
import '../settings/settings_screen.dart';
import '../shell/glass_nav_bar.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/large_title_header.dart';
import '../widgets/pressable.dart';
import '../widgets/rolling_number.dart';
import '../widgets/surface.dart';
import 'charts.dart';
import 'exercise_screens.dart';
import 'muscle_card.dart';
import 'year_view.dart';

/// Counts, the year view, muscle recency, body weight and exercise history.
/// Streaks, goals and records live on the Progress tab.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int? _year;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final summaries = ref.watch(summariesProvider).value ?? const <EntrySummary>[];
    final groups = ref.watch(groupsProvider).value ?? const [];
    final weekStart = ref.watch(settingsProvider.select((s) => s.weekStart));
    final showWeight = ref.watch(settingsProvider.select((s) => s.has(AppFeature.bodyWeight)));
    final days = {for (final e in summaries) e.dayKey};
    final stats = overview(days, today);
    final thisYear = DayKeys.year(today);
    final minYear = days.isEmpty ? thisYear : math.min(thisYear, DayKeys.year(days.reduce(math.min)));
    final year = _year ?? thisYear;
    final padding = MediaQuery.paddingOf(context);

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: LargeTitleHeader(
            title: 'Insights',
            topPadding: padding.top,
            trailing: GtIconButton(
              icon: GtIcons.settings,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
              color: Colors.transparent,
              iconSize: 22,
              semanticLabel: 'Settings',
            ),
          ),
        ),
        SliverList.list(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.sm, GtSpace.lg, 0),
              child: _OverviewCard(stats: stats, today: today),
            ),
            const SectionHeader('Year'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
              child: YearView(
                year: year,
                minYear: minYear,
                today: today,
                weekStart: weekStart,
                days: days,
                onYearChanged: (y) => setState(() => _year = y),
                onMonthTap: (m) {
                  ref.read(calendarJumpProvider.notifier).request(m);
                  ref.read(shellTabProvider.notifier).show(ShellTab.calendar);
                },
              ),
            ),
            SectionHeader(
              'Muscle groups',
              trailing: Text('LAST 30 DAYS', style: GtText.overline.colored(GtColors.text3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
              child: MuscleCard(
                recency: groupRecency(summaries, groups, today),
                today: today,
                summaries: summaries,
                groups: ref.watch(groupsByIdProvider),
              ),
            ),
            const SectionHeader('Sessions per month'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
              child: GtCard(
                padding: const EdgeInsets.fromLTRB(GtSpace.md, GtSpace.xl, GtSpace.md, GtSpace.sm),
                child: MonthlyBars(data: monthlyCounts(days, today)),
              ),
            ),
            if (showWeight) ...[
              const SectionHeader('Body weight'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: GtSpace.lg),
                child: _BodyWeightCard(),
              ),
            ],
            const SectionHeader('Exercises'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: GtSpace.lg),
              child: _ExercisesPreview(),
            ),
            SizedBox(height: padding.bottom + GlassNavBar.height + 48),
          ],
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.stats, required this.today});

  final OverviewStats stats;
  final int today;

  @override
  Widget build(BuildContext context) {
    Widget figure(int value, String label) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RollingNumber(value, style: GtText.monoDisplay.sized(36)),
          const SizedBox(height: 4),
          Text(label, style: GtText.caption),
        ],
      ),
    );

    return GtCard(
      padding: const EdgeInsets.all(GtSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              figure(stats.thisMonth, 'This month'),
              figure(stats.thisYear, 'This year'),
              figure(stats.allTime, 'All time'),
            ],
          ),
          const SizedBox(height: GtSpace.lg),
          const Divider(),
          const SizedBox(height: GtSpace.md),
          _Line(label: 'Per week', value: '${Fmt.number(stats.perWeek12, maxDecimals: 1)} · last 12 weeks'),
          const SizedBox(height: GtSpace.sm),
          _Line(
            label: 'Last session',
            value: stats.lastDayKey == null
                ? '–'
                : '${Fmt.weekdayDayMonth(stats.lastDayKey!)} · ${Fmt.relativeDay(stats.lastDayKey!, today)}',
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GtText.label.colored(GtColors.text2)),
        const SizedBox(width: GtSpace.lg),
        Expanded(
          child: Text(value, textAlign: TextAlign.end, style: GtText.label),
        ),
      ],
    );
  }
}

enum _Range {
  m1('1M', 30),
  m3('3M', 91),
  y1('1Y', 365),
  all('All', null);

  const _Range(this.label, this.days);

  final String label;
  final int? days;
}

class _BodyWeightCard extends ConsumerStatefulWidget {
  const _BodyWeightCard();

  @override
  ConsumerState<_BodyWeightCard> createState() => _BodyWeightCardState();
}

class _BodyWeightCardState extends ConsumerState<_BodyWeightCard> {
  _Range _range = _Range.m3;

  @override
  Widget build(BuildContext context) {
    final weights = ref.watch(bodyWeightsProvider).value ?? const [];
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final today = ref.watch(todayProvider);
    void add() => showWeighInSheet(context, ref, dayKey: logicalToday(ref));

    if (weights.isEmpty) {
      return GtCard(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('No weigh-ins yet.', style: GtText.body.colored(GtColors.text2)),
            const SizedBox(height: GtSpace.lg),
            GtButton(label: 'Add weigh-in', icon: GtIcons.add, kind: GtButtonKind.secondary, onTap: add, height: 44),
          ],
        ),
      );
    }

    final from = _range.days == null ? 0 : DayKeys.addDays(today, -_range.days!);
    final inRange = [
      for (final w in weights)
        if (w.dayKey >= from) w,
    ];
    final latest = weights.last;
    final first = inRange.isEmpty ? null : inRange.first;
    final delta = first == null || first.dayKey == latest.dayKey ? null : latest.weightKg - first.weightKg;
    // Averaged over every weigh-in, then cut to the range, so the first days
    // in view still average a full week.
    final trend = [
      for (final p in movingAverage([for (final w in weights) (w.dayKey, Units.toDisplay(w.weightKg, unit))]))
        if (p.$1 >= from) p,
    ];
    final goal = (ref.watch(goalsProvider).value ?? const <Goal>[])
        .where((g) => g.kind == GoalKind.bodyWeight)
        .firstOrNull;
    final toGo = goal == null ? null : (goal.targetKg - latest.weightKg).abs();

    return GtCard(
      padding: const EdgeInsets.fromLTRB(GtSpace.xl, GtSpace.xl, GtSpace.md, GtSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: Units.format(latest.weightKg, unit, withUnit: false, maxDecimals: 1),
                            style: GtText.figure.sized(38),
                          ),
                          TextSpan(text: ' ${unit.name}', style: GtText.label.sized(15).colored(GtColors.text2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      delta == null
                          ? Fmt.dayMonthYear(latest.dayKey)
                          : '${delta >= 0 ? '+' : '−'}${Units.format(delta.abs(), unit, maxDecimals: 1)} since ${Fmt.dayMonth(first!.dayKey)}',
                      style: GtText.caption,
                    ),
                    if (latest.source case final src?) ...[const SizedBox(height: 2), HealthSourceText(src)],
                    if (goal != null && toGo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        toGo < 0.05
                            ? 'At your goal of ${Units.format(goal.targetKg, unit, maxDecimals: 1)}'
                            : '${Units.format(toGo, unit, maxDecimals: 1)} to your goal',
                        style: GtText.caption.colored(GtColors.gold),
                      ),
                    ],
                  ],
                ),
              ),
              Pressable(
                onTap: add,
                scale: 0.9,
                semanticLabel: 'Add weigh-in',
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(color: context.gt.accentMuted, shape: squircle(18)),
                  child: Icon(GtIcons.add, size: 16, color: context.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: GtSpace.xl),
          WeightLine(
            points: [for (final w in inRange) (w.dayKey, Units.toDisplay(w.weightKg, unit))],
            unitLabel: unit.name,
            trend: trend,
            goal: goal == null ? null : Units.toDisplay(goal.targetKg, unit),
          ),
          if (inRange.length >= 2)
            Padding(
              padding: const EdgeInsets.only(top: GtSpace.sm),
              child: Row(
                children: [
                  const _DashKey(),
                  const SizedBox(width: 6),
                  Text('7-day average', style: GtText.caption),
                ],
              ),
            ),
          const SizedBox(height: GtSpace.md),
          Padding(
            padding: const EdgeInsets.only(right: GtSpace.sm),
            child: GtSegmented<_Range>(
              values: _Range.values,
              selected: _range,
              labelOf: (r) => r.label,
              onChanged: (r) => setState(() => _range = r),
              height: 34,
            ),
          ),
        ],
      ),
    );
  }
}

/// Legend swatch for the dashed average line.
class _DashKey extends StatelessWidget {
  const _DashKey();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++)
          Container(width: 4, height: 1.5, margin: const EdgeInsets.only(right: 2), color: GtColors.text2),
      ],
    );
  }
}

class _ExercisesPreview extends ConsumerWidget {
  const _ExercisesPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(exerciseStatsProvider).value ?? const <ExerciseStat>[];
    final today = ref.watch(todayProvider);
    if (stats.isEmpty) {
      return GtCard(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: Text(
          'Exercises you log will show up here, with every time you did them.',
          style: GtText.body.colored(GtColors.text2),
        ),
      );
    }
    final top = stats.take(5).toList();
    return GtCard(
      padding: const EdgeInsets.symmetric(vertical: GtSpace.sm),
      child: Column(
        children: [
          for (final s in top) ExerciseStatRow(stat: s, today: today),
          if (stats.length > top.length)
            Pressable(
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ExerciseListScreen())),
              scale: 0.98,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.sm),
                child: Row(
                  children: [
                    Text('All ${stats.length} exercises', style: GtText.label.weight(600).colored(context.accent)),
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
