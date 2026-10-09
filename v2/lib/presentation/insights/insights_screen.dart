import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/models/entry.dart';
import '../../logic/insights.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/navigation_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../art/dot_charts.dart';
import '../log/log_actions.dart';
import '../log/weigh_in_sheet.dart';
import '../settings/settings_screen.dart';
import '../shell/nav_bar.dart';
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

/// Neutral numbers about what was logged. No streaks, no targets.
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
    final days = {for (final e in summaries) e.dayKey};
    final stats = overview(days, today);
    final thisYear = DayKeys.year(today);
    final minYear = days.isEmpty ? thisYear : math.min(thisYear, DayKeys.year(days.reduce(math.min)));
    final year = _year ?? thisYear;
    final padding = MediaQuery.paddingOf(context);
    final monthly = monthlyCounts(days, today);

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: LargeTitleHeader(
            title: 'Insights',
            subtitle: 'Plain numbers',
            topPadding: padding.top,
            colors: context.c,
            trailing: CircleButton(
              icon: GtIcons.settings,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
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
                  ref.read(shellTabProvider.notifier).show(1);
                },
              ),
            ),
            SectionHeader('Muscle groups', trailing: Text('Last 30 days', style: context.tx.captionFaint)),
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
                padding: const EdgeInsets.fromLTRB(GtSpace.md, GtSpace.sm, GtSpace.md, GtSpace.md),
                child: DotColumns(
                  values: [for (final m in monthly) m.count],
                  labels: [for (final m in monthly) Fmt.monthShort(m.month.month)[0]],
                  highlight: monthly.length - 1,
                  rows: 12,
                  minScale: 8,
                  height: 132,
                  tooltipOf: (i) => '${Fmt.monthShort(monthly[i].month.month)} ${monthly[i].month.year} · ${monthly[i].count}',
                ),
              ),
            ),
            const SectionHeader('Body weight'),
            const Padding(padding: EdgeInsets.symmetric(horizontal: GtSpace.lg), child: _BodyWeightCard()),
            const SectionHeader('Exercises'),
            const Padding(padding: EdgeInsets.symmetric(horizontal: GtSpace.lg), child: _ExercisesPreview()),
            SizedBox(height: padding.bottom + GtNavBar.height + 52),
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
    final c = context.c;
    Widget figure(int value, String label) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RollingNumber(value, style: GtText.dotFigure(38).colored(c.text1)),
          ),
          const SizedBox(height: 4),
          Text(label, style: GtText.caption.colored(c.text2)),
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
          Divider(color: c.hairline),
          const SizedBox(height: GtSpace.md),
          _Line(
            label: 'Per week',
            value: '${Fmt.number(stats.perWeek12, maxDecimals: 1)} · last 12 weeks',
          ),
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
        Text(label, style: context.tx.labelSecondary),
        const SizedBox(width: GtSpace.lg),
        Expanded(child: Text(value, textAlign: TextAlign.end, style: GtText.label)),
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
    final c = context.c;
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
            Text('No weigh-ins yet.', style: GtText.body.colored(c.text2)),
            const SizedBox(height: GtSpace.lg),
            GtButton(label: 'Add weigh-in', icon: GtIcons.add, kind: GtButtonKind.secondary, onTap: add, height: 46),
          ],
        ),
      );
    }

    final from = _range.days == null ? 0 : DayKeys.addDays(today, -_range.days!);
    final inRange = [for (final w in weights) if (w.dayKey >= from) w];
    final latest = weights.last;
    final first = inRange.isEmpty ? null : inRange.first;
    final delta = first == null || first.dayKey == latest.dayKey ? null : latest.weightKg - first.weightKg;

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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              GtText.figures(Units.format(latest.weightKg, unit, withUnit: false, maxDecimals: 1)),
                              style: GtText.dotFigure(40).colored(c.text1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(unit.name, style: GtText.label.sized(15).colored(c.text2)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      delta == null
                          ? Fmt.dayMonthYear(latest.dayKey)
                          : '${delta >= 0 ? '+' : '−'}${Units.format(delta.abs(), unit, maxDecimals: 1)} since ${Fmt.dayMonth(first!.dayKey)}',
                      style: GtText.caption.colored(c.text2),
                    ),
                  ],
                ),
              ),
              Pressable(
                onTap: add,
                scale: 0.9,
                semanticLabel: 'Add weigh-in',
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: ShapeDecoration(color: c.ink, shape: const CircleBorder()),
                  child: Icon(GtIcons.add, size: 16, color: c.accentOnInk),
                ),
              ),
            ],
          ),
          const SizedBox(height: GtSpace.xl),
          WeightLine(
            points: [for (final w in inRange) (w.dayKey, Units.toDisplay(w.weightKg, unit))],
            unitLabel: unit.name,
          ),
          const SizedBox(height: GtSpace.md),
          Padding(
            padding: const EdgeInsets.only(right: GtSpace.sm),
            child: GtSegmented<_Range>(
              values: _Range.values,
              selected: _range,
              labelOf: (r) => r.label,
              onChanged: (r) => setState(() => _range = r),
              height: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExercisesPreview extends ConsumerWidget {
  const _ExercisesPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final stats = ref.watch(exerciseStatsProvider).value ?? const <ExerciseStat>[];
    final today = ref.watch(todayProvider);
    if (stats.isEmpty) {
      return GtCard(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: Text(
          'Exercises you log will show up here, with every time you did them.',
          style: GtText.body.colored(c.text2),
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
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ExerciseListScreen())),
              scale: 0.98,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.sm),
                child: Row(
                  children: [
                    Text('All ${stats.length} exercises', style: GtText.label.weight(600)),
                    const Spacer(),
                    Icon(GtIcons.chevronRight, size: 14, color: c.text2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
