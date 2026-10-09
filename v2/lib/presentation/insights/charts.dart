import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';

/// A smooth weight line over a dotted grid. Points are
/// (dayKey, value-in-display-units).
class WeightLine extends StatelessWidget {
  const WeightLine({super.key, required this.points, required this.unitLabel});

  final List<(int dayKey, double value)> points;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final line = c.isDark ? c.accent : c.text1;
    if (points.isEmpty) return const SizedBox(height: 160);
    final first = points.first.$1;
    double x(int dayKey) => DayKeys.daysBetween(first, dayKey).toDouble();
    final values = points.map((p) => p.$2);
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
            getDrawingHorizontalLine: (_) => FlLine(color: c.dotOff, strokeWidth: 1.4, dashArray: const [1, 4]),
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
                        child: Text(Fmt.number(value, maxDecimals: 1), style: GtText.monoSmall.colored(c.text3)),
                      ),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => c.ink,
              tooltipBorderRadius: BorderRadius.circular(GtRadius.sm),
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${Fmt.number(s.y, maxDecimals: 1)} $unitLabel\n',
                    GtText.label.colored(c.onInk),
                    children: [
                      TextSpan(
                        text: Fmt.dayMonthYear(points[s.spotIndex].$1),
                        style: GtText.caption.colored(c.onInk.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
              ],
            ),
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  FlLine(color: c.hairlineStrong, strokeWidth: 1),
                  FlDotData(
                    getDotPainter: (_, _, _, _) =>
                        FlDotCirclePainter(radius: 5, color: c.accent, strokeWidth: 3, strokeColor: c.surface),
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
              color: line,
              barWidth: 2.2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: points.length < 24,
                getDotPainter: (spot, _, _, i) => FlDotCirclePainter(
                  radius: i == points.length - 1 ? 4.5 : 2.4,
                  color: i == points.length - 1 ? c.accent : line,
                  strokeWidth: i == points.length - 1 ? 2.5 : 0,
                  strokeColor: c.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.accent.withValues(alpha: 0.28), c.accent.withValues(alpha: 0)],
                ),
              ),
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
