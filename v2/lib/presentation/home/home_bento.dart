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
import '../../logic/insights.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../art/dot_charts.dart';
import '../log/log_actions.dart';
import '../log/weigh_in_sheet.dart';
import '../widgets/rolling_number.dart';
import '../widgets/surface.dart';

/// Three cards of plain numbers, laid out like the stat bento in the
/// reference: sessions (month or year) on the left; rhythm and body weight
/// stacked on the right.
class HomeBento extends ConsumerWidget {
  const HomeBento({super.key, required this.yearView});

  final bool yearView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Large system text gets taller cards rather than clipped numbers.
    final k = 1 + (MediaQuery.textScalerOf(context).scale(1) - 1) * 0.7;
    final small = 124.0 * k;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
      child: SizedBox(
        height: small * 2 + 12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 11, child: _SessionsCard(yearView: yearView)),
            const SizedBox(width: 12),
            Expanded(
              flex: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(child: _RhythmCard()),
                  SizedBox(height: 12),
                  Expanded(child: _WeightCard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionsCard extends ConsumerWidget {
  const _SessionsCard({required this.yearView});

  final bool yearView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final today = ref.watch(todayProvider);
    final weekStart = ref.watch(settingsProvider.select((s) => s.weekStart));
    final days = ref.watch(summariesByDayProvider).keys.toSet();
    final ym = yearMonthOf(today);

    final values = <int>[], labels = <String>[], tips = <String>[];
    int? highlight;
    if (yearView) {
      for (var m = 1; m <= 12; m++) {
        final n = days.where((d) => DayKeys.year(d) == ym.year && DayKeys.month(d) == m).length;
        values.add(n);
        labels.add(Fmt.monthShort(m)[0]);
        tips.add('${Fmt.monthShort(m)} · $n');
      }
      highlight = ym.month - 1;
    } else {
      var ws = DayKeys.weekStartOf(ym.startKey, weekStart);
      while (ws <= ym.endKey) {
        final from = math.max(ws, ym.startKey), to = math.min(DayKeys.addDays(ws, 6), ym.endKey);
        var n = 0;
        for (var d = from; d <= to; d = DayKeys.addDays(d, 1)) {
          if (days.contains(d)) n++;
        }
        if (today >= ws && today <= DayKeys.addDays(ws, 6)) highlight = values.length;
        values.add(n);
        labels.add('${DayKeys.day(from)}');
        tips.add('${Fmt.dayMonth(from)} · $n');
        ws = DayKeys.addDays(ws, 7);
      }
    }
    final total = values.fold(0, (a, b) => a + b);
    final period = yearView ? '${ym.year}' : Fmt.monthName(ym.month);

    return GtCard(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.lg, GtSpace.lg, GtSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RollingNumber(total, style: GtText.dotFigure(46).colored(c.text1)),
          ),
          const SizedBox(height: 4),
          Text(
            '${total == 1 ? 'session' : 'sessions'} in $period',
            style: GtText.caption.colored(c.text2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          DotColumns(
            key: ValueKey(yearView),
            values: values,
            labels: labels,
            highlight: highlight,
            rows: yearView ? 10 : 7,
            minScale: yearView ? 8 : 7,
            height: 96,
            tooltipOf: (i) => tips[i],
          ),
        ],
      ),
    );
  }
}

class _RhythmCard extends ConsumerWidget {
  const _RhythmCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final today = ref.watch(todayProvider);
    final days = ref.watch(summariesByDayProvider).keys.toSet();
    final stats = overview(days, today);
    final last28 = [for (var i = 27; i >= 0; i--) days.contains(DayKeys.addDays(today, -i))];

    return GtCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              GtText.figures(Fmt.number(stats.perWeek12, maxDecimals: 1)),
              style: GtText.dotFigure(30).colored(c.text1),
            ),
          ),
          const SizedBox(height: 2),
          Text('per week · 12 wks', style: GtText.caption.colored(c.text2), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          DotTimeline(days: last28),
        ],
      ),
    );
  }
}

class _WeightCard extends ConsumerWidget {
  const _WeightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final weights = ref.watch(bodyWeightsProvider).value ?? const [];
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    void add() => showWeighInSheet(context, ref, dayKey: logicalToday(ref));

    if (weights.isEmpty) {
      return GtCard(
        onTap: add,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(GtIcons.weight, size: 20, color: c.text2),
            const Spacer(),
            Text('Body weight', style: GtText.label.weight(600)),
            const SizedBox(height: 2),
            Text('Add a weigh-in', style: GtText.caption.colored(c.text2)),
          ],
        ),
      );
    }

    final latest = weights.last;
    final previous = weights.length > 1 ? weights[weights.length - 2] : null;
    final delta = previous == null ? null : latest.weightKg - previous.weightKg;
    final recent = weights.skip(math.max(0, weights.length - 12)).map((w) => Units.toDisplay(w.weightKg, unit)).toList();

    return GtCard(
      onTap: add,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  GtText.figures(Units.format(latest.weightKg, unit, withUnit: false, maxDecimals: 1)),
                  style: GtText.dotFigure(30).colored(c.text1),
                ),
                const SizedBox(width: 4),
                Text(unit.name, style: GtText.label.colored(c.text2)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            delta == null
                ? Fmt.dayMonth(latest.dayKey)
                : '${delta >= 0 ? '+' : '−'}${Units.format(delta.abs(), unit, maxDecimals: 1)} since ${Fmt.dayMonth(previous!.dayKey)}',
            style: GtText.caption.colored(c.text2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          DotSparkline(values: recent, height: 26),
        ],
      ),
    );
  }
}
