import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/health_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../settings/connection_settings.dart';
import '../widgets/controls.dart';
import '../widgets/surface.dart';

/// Entry detail → Health: the watch's heart rate and calories for the
/// session, plus the day's steps and the night before's sleep. Shows only
/// what Health Connect actually has.
class EntryHealthSection extends ConsumerStatefulWidget {
  const EntryHealthSection({super.key, required this.entry});

  final EntryDetail entry;

  @override
  ConsumerState<EntryHealthSection> createState() => _EntryHealthSectionState();
}

class _EntryHealthSectionState extends ConsumerState<EntryHealthSection> {
  @override
  void initState() {
    super.initState();
    // Fresh numbers whenever a day is opened (the watch may have synced since).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(healthSyncProvider.notifier).refreshDay(widget.entry.dayKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    if (!s.healthOn) return const SizedBox.shrink();
    final day = widget.entry.dayKey;
    final daily = ref.watch(dailyHealthProvider).value ?? const <int, DailyHealthData>{};
    final steps = daily[day]?.steps;
    final sleep = s.watchHealth && s.healthSleep ? daily[day]?.sleepMin : null;
    final stats = s.watchHealth && s.healthHeart
        ? ref.watch(sessionHealthProvider(widget.entry.session.id)).value
        : null;
    final hasStats = stats != null && (stats.avgHr != null || stats.activeKcal != null);
    if (!hasStats && steps == null && (sleep ?? 0) == 0) return const SizedBox.shrink();

    final window = stats == null ? null : (start: stats.startAt, end: stats.endAt);
    final series = window == null || stats?.avgHr == null
        ? const <(DateTime, int)>[]
        : ref.watch(heartRateProvider(window)).value ?? const <(DateTime, int)>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Health'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          child: GtCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasStats) ...[
                  Row(
                    children: [
                      if (stats.avgHr != null) Expanded(child: _Figure('AVG HR', '${stats.avgHr}', 'bpm')),
                      if (stats.maxHr != null) Expanded(child: _Figure('PEAK', '${stats.maxHr}', 'bpm')),
                      if (stats.activeKcal != null) Expanded(child: _Figure('ACTIVE', '${stats.activeKcal}', 'kcal')),
                    ],
                  ),
                  if (series.length >= 3) ...[const SizedBox(height: GtSpace.lg), HeartRateLine(samples: series)],
                  const SizedBox(height: GtSpace.md),
                  Row(
                    children: [
                      const Icon(GtIcons.time, size: 13, color: GtColors.text3),
                      const SizedBox(width: 6),
                      if (stats.source case final src?) ...[
                        HealthSourceText(src, prefix: ''),
                        Text(' · ', style: GtText.caption.colored(GtColors.text3)),
                      ] else
                        Text('Your start time · ', style: GtText.caption.colored(GtColors.text3)),
                      Text(
                        '${Fmt.time(stats.startAt)}–${Fmt.time(stats.endAt)}',
                        style: GtText.caption.colored(GtColors.text3),
                      ),
                    ],
                  ),
                ],
                if (steps != null || (sleep ?? 0) > 0) ...[
                  if (hasStats)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: GtSpace.md),
                      child: Divider(height: 1),
                    ),
                  Row(
                    children: [
                      if (steps != null) ...[
                        const Icon(GtIcons.footprints, size: 16, color: GtColors.text2),
                        const SizedBox(width: GtSpace.sm),
                        Text('${Fmt.thousands(steps)} steps', style: GtText.label),
                        const SizedBox(width: GtSpace.xl),
                      ],
                      if ((sleep ?? 0) > 0) ...[
                        const Icon(GtIcons.sleep, size: 16, color: GtColors.text2),
                        const SizedBox(width: GtSpace.sm),
                        Text('Slept ${Fmt.duration(sleep!)}', style: GtText.label),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!hasStats && s.watchHealth && s.healthHeart && widget.entry.session.startedAt == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.gutter + 4, GtSpace.sm, GtSpace.gutter, 0),
            child: Text(
              'No watch workout found for ${DayKeys.day(day)} ${Fmt.monthShort(DayKeys.month(day))}. '
              'Add a start time when editing to see heart rate.',
              style: GtText.caption,
            ),
          ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value, this.unit);

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GtText.overline.colored(GtColors.text3)),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: value,
            style: GtText.monoTitle.sized(22),
            children: [TextSpan(text: ' $unit', style: GtText.caption)],
          ),
        ),
      ],
    );
  }
}

/// Heart rate over the session, thinned to at most ~120 points.
class HeartRateLine extends StatelessWidget {
  const HeartRateLine({super.key, required this.samples});

  final List<(DateTime, int)> samples;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    final step = (samples.length / 120).ceil().clamp(1, 1 << 20);
    final pts = [for (var i = 0; i < samples.length; i += step) samples[i]];
    final t0 = pts.first.$1;
    double x(DateTime t) => t.difference(t0).inSeconds / 60;
    final bpm = [for (final p in pts) p.$2];
    final lo = bpm.reduce((a, b) => a < b ? a : b).toDouble();
    final hi = bpm.reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 110,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: x(pts.last.$1).clamp(1, double.infinity),
          minY: lo - 8,
          maxY: hi + 8,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => GtColors.s3,
              tooltipBorderRadius: BorderRadius.circular(GtRadius.sm),
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${s.y.round()} bpm\n',
                    GtText.label,
                    children: [TextSpan(text: Fmt.time(pts[s.spotIndex].$1), style: GtText.caption)],
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (final p in pts) FlSpot(x(p.$1), p.$2.toDouble())],
              isCurved: true,
              preventCurveOverShooting: true,
              color: accent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
