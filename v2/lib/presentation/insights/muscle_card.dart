import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/insights.dart';
import '../art/dot_body.dart';
import '../body_map/muscle_regions.dart';
import '../widgets/cardio_pill.dart';
import '../widgets/surface.dart';

/// Last 30 days on the dot body, plus when each muscle group was last
/// trained. Purely informational: equal styling whether it was yesterday or
/// months ago.
class MuscleCard extends StatefulWidget {
  const MuscleCard({
    super.key,
    required this.recency,
    required this.today,
    required this.summaries,
    required this.groups,
  });

  final List<GroupRecency> recency;
  final int today;
  final List<EntrySummary> summaries;
  final Map<int, MuscleGroup> groups;

  @override
  State<MuscleCard> createState() => _MuscleCardState();
}

class _MuscleCardState extends State<MuscleCard> {
  String? _region;

  /// "Legs · 12 days ago" for the groups that train the tapped region.
  String _caption() {
    final region = _region;
    if (region == null) return 'Tap a muscle to see when it was last trained';
    final matching = [
      for (final r in widget.recency)
        if ((groupRegions[r.group.slug] ?? const []).contains(region)) r,
    ];
    if (matching.isEmpty) return 'Not linked to a muscle group';
    return matching
        .map((r) => '${r.group.name} · ${r.lastDayKey == null ? 'not logged yet' : Fmt.relativeDay(r.lastDayKey!, widget.today).toLowerCase()}')
        .join('   ');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final heat = regionHeat(widget.summaries, widget.groups, widget.today);
    final cardio = widget.recency.where((r) => r.group.slug == 'cardio').firstOrNull;
    final maxCount = widget.recency.fold(0, (m, r) => r.countInWindow > m ? r.countInWindow : m);

    return GtCard(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.xxl, GtSpace.lg, GtSpace.md),
      child: Column(
        children: [
          DotBody(strength: heat, height: 270, spacing: 3.1, onRegionTap: (r) => setState(() => _region = r)),
          const SizedBox(height: GtSpace.lg),
          AnimatedSwitcher(
            duration: GtMotion.of(context, GtMotion.medium),
            child: Text(
              _caption(),
              key: ValueKey(_region),
              textAlign: TextAlign.center,
              style: GtText.caption.colored(_region == null ? c.text3 : c.text1),
            ),
          ),
          if (cardio != null && cardio.countInWindow > 0) ...[
            const SizedBox(height: GtSpace.md),
            CardioPill(label: 'Cardio · ${cardio.countInWindow}×'),
          ],
          const SizedBox(height: GtSpace.lg),
          Divider(color: c.hairline),
          const SizedBox(height: GtSpace.xs),
          for (final r in widget.recency)
            _RecencyRow(recency: r, today: widget.today, fraction: maxCount == 0 ? 0 : r.countInWindow / maxCount),
        ],
      ),
    );
  }
}

class _RecencyRow extends StatelessWidget {
  const _RecencyRow({required this.recency, required this.today, required this.fraction});

  final GroupRecency recency;
  final int today;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final last = recency.lastDayKey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(width: 88, child: Text(recency.group.name, style: GtText.label.sized(14), maxLines: 1)),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: fraction),
              duration: GtMotion.of(context, const Duration(milliseconds: 700)),
              curve: GtMotion.emphasized,
              builder: (context, f, _) => SizedBox(
                height: 8,
                child: CustomPaint(painter: _DotBarPainter(fraction: f, on: c.text1, off: c.dotOff)),
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              recency.countInWindow == 0 ? '' : '${recency.countInWindow}×',
              textAlign: TextAlign.end,
              style: GtText.mono.sized(13),
            ),
          ),
          SizedBox(
            width: 88,
            child: Text(
              last == null ? '–' : Fmt.relativeDay(last, today),
              textAlign: TextAlign.end,
              style: GtText.caption.colored(c.text2),
            ),
          ),
        ],
      ),
    );
  }
}

/// A progress bar made of dots: lit up to [fraction], faint after.
class _DotBarPainter extends CustomPainter {
  _DotBarPainter({required this.fraction, required this.on, required this.off});

  final double fraction;
  final Color on;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    const pitch = 6.0;
    final n = (size.width / pitch).floor();
    final lit = (n * fraction).round();
    final y = size.height / 2;
    final onPts = Float32List(lit * 2), offPts = Float32List((n - lit) * 2);
    for (var i = 0; i < n; i++) {
      final x = pitch * (i + 0.5);
      if (i < lit) {
        onPts[i * 2] = x;
        onPts[i * 2 + 1] = y;
      } else {
        offPts[(i - lit) * 2] = x;
        offPts[(i - lit) * 2 + 1] = y;
      }
    }
    final paint = Paint()..strokeCap = StrokeCap.round;
    canvas.drawRawPoints(ui.PointMode.points, offPts, paint..strokeWidth = 3..color = off);
    canvas.drawRawPoints(ui.PointMode.points, onPts, paint..strokeWidth = 4.4..color = on);
  }

  @override
  bool shouldRepaint(_DotBarPainter old) => old.fraction != fraction || old.on != on || old.off != off;
}
