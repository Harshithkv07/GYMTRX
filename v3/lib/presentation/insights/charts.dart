import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';

/// Sessions per month for the last 12 months; the current month in accent.
class MonthlyBars extends StatelessWidget {
  const MonthlyBars({super.key, required this.data});

  final List<({YearMonth month, int count})> data;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    final maxY = data.fold(0, (m, d) => d.count > m ? d.count : m).toDouble();
    return SizedBox(
      height: 168,
      child: BarChart(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        BarChartData(
          maxY: maxY < 4 ? 4 : maxY * 1.2,
          alignment: BarChartAlignment.spaceBetween,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final m = data[value.toInt()].month;
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(Fmt.monthShort(m.month)[0], style: GtText.monoSmall.colored(GtColors.text3)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => GtColors.s3,
              tooltipBorderRadius: BorderRadius.circular(GtRadius.sm),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              getTooltipItem: (group, _, rod, _) {
                final m = data[group.x].month;
                return BarTooltipItem(
                  '${Fmt.monthShort(m.month)} ${m.year}\n',
                  GtText.caption,
                  children: [TextSpan(text: Fmt.plural(rod.toY.toInt(), 'session'), style: GtText.label)],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].count.toDouble(),
                    width: 14,
                    color: i == data.length - 1 ? accent : GtColors.s3,
                    borderRadius: BorderRadius.circular(5),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY < 4 ? 4 : maxY * 1.2,
                      color: GtColors.s2.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// A smooth weight line. Points are (dayKey, value-in-display-units).
/// Optionally a dashed [trend] line over the same days, a [goal] level and
/// gold dots on [highlightDays].
class WeightLine extends StatelessWidget {
  const WeightLine({
    super.key,
    required this.points,
    required this.unitLabel,
    this.trend,
    this.goal,
    this.highlightDays = const {},
  });

  final List<(int dayKey, double value)> points;
  final String unitLabel;
  final List<(int dayKey, double value)>? trend;
  final double? goal;
  final Set<int> highlightDays;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    if (points.isEmpty) return const SizedBox(height: 160);
    final first = points.first.$1;
    double x(int dayKey) => DayKeys.daysBetween(first, dayKey).toDouble();
    final trendPoints = points.length < 2 ? null : trend;
    final values = [...points.map((p) => p.$2), ...?trendPoints?.map((p) => p.$2), ?goal];
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    final pad = ((hi - lo) * 0.25).clamp(0.5, 10.0);

    return SizedBox(
      height: 160,
      child: LineChart(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        LineChartData(
          minY: lo - pad,
          maxY: hi + pad,
          minX: 0,
          maxX: points.length == 1 ? 1 : x(points.last.$1),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: _niceInterval(hi - lo + pad * 2),
            getDrawingHorizontalLine: (_) => const FlLine(color: GtColors.hairline, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            bottomTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: _niceInterval(hi - lo + pad * 2),
                // Skip the axis ends; they crowd the round-number labels.
                getTitlesWidget: (value, meta) => value == meta.min || value == meta.max
                    ? const SizedBox.shrink()
                    : SideTitleWidget(
                        meta: meta,
                        child: Text(Fmt.number(value, maxDecimals: 1), style: GtText.monoSmall.colored(GtColors.text3)),
                      ),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => GtColors.s3,
              tooltipBorderRadius: BorderRadius.circular(GtRadius.sm),
              getTooltipItems: (spots) => [
                for (final s in spots)
                  s.barIndex == 0
                      ? LineTooltipItem(
                          '${Fmt.number(s.y, maxDecimals: 1)} $unitLabel\n',
                          GtText.label,
                          children: [TextSpan(text: Fmt.dayMonthYear(points[s.spotIndex].$1), style: GtText.caption)],
                        )
                      : LineTooltipItem('7-day avg ${Fmt.number(s.y, maxDecimals: 1)}', GtText.caption),
              ],
            ),
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes)
                bar.dashArray != null
                    ? const TouchedSpotIndicatorData(FlLine(color: Colors.transparent), FlDotData(show: false))
                    : TouchedSpotIndicatorData(
                        const FlLine(color: GtColors.hairlineStrong, strokeWidth: 1),
                        FlDotData(
                          getDotPainter: (_, _, _, _) =>
                              FlDotCirclePainter(radius: 5, color: accent, strokeWidth: 3, strokeColor: GtColors.bg),
                        ),
                      ),
            ],
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (goal != null)
                HorizontalLine(
                  y: goal!,
                  color: GtColors.gold.withValues(alpha: 0.7),
                  strokeWidth: 1.2,
                  dashArray: const [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 2, bottom: 2),
                    style: GtText.monoSmall.sized(10).colored(GtColors.gold),
                    labelResolver: (l) => 'GOAL ${Fmt.number(l.y, maxDecimals: 1)}',
                  ),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (final p in points) FlSpot(points.length == 1 ? 0.5 : x(p.$1), p.$2)],
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              color: accent,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: points.length < 24 || highlightDays.isNotEmpty,
                checkToShowDot: (spot, _) =>
                    points.length < 24 ||
                    (spot.x.round() >= 0 && highlightDays.contains(DayKeys.addDays(first, spot.x.round()))),
                getDotPainter: (spot, _, _, _) {
                  final day = points.length == 1 ? first : DayKeys.addDays(first, spot.x.round());
                  return highlightDays.contains(day)
                      ? FlDotCirclePainter(radius: 4, color: GtColors.gold, strokeWidth: 2, strokeColor: GtColors.s1)
                      : FlDotCirclePainter(radius: 2.5, color: accent, strokeWidth: 0, strokeColor: accent);
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0)],
                ),
              ),
            ),
            if (trendPoints != null)
              LineChartBarData(
                spots: [for (final p in trendPoints) FlSpot(x(p.$1), p.$2)],
                isCurved: true,
                curveSmoothness: 0.35,
                preventCurveOverShooting: true,
                color: GtColors.text2,
                barWidth: 1.5,
                dashArray: const [4, 3],
                dotData: const FlDotData(show: false),
              ),
          ],
        ),
      ),
    );
  }

  static double _niceInterval(double range) {
    if (range <= 3) return 1;
    if (range <= 8) return 2;
    if (range <= 20) return 5;
    return 10;
  }
}
