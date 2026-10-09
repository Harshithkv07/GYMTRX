import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/insights.dart';
import '../body_map/body_map.dart';
import '../body_map/muscle_regions.dart';
import '../entry/entry_body_map.dart';
import '../widgets/surface.dart';

/// Last 30 days on the body, plus when each muscle group was last trained.
/// Purely informational: equal styling whether it was yesterday or months ago.
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
    final heat = regionHeat(widget.summaries, widget.groups, widget.today);
    final cardio = widget.recency.where((r) => r.group.slug == 'cardio').firstOrNull;
    final maxCount = widget.recency.fold(0, (m, r) => r.countInWindow > m ? r.countInWindow : m);

    return GtCard(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.xxl, GtSpace.lg, GtSpace.md),
      child: Column(
        children: [
          BodyMap(strength: heat, height: 260, onRegionTap: (r) => setState(() => _region = r)),
          const SizedBox(height: GtSpace.lg),
          AnimatedSwitcher(
            duration: GtMotion.of(context, GtMotion.medium),
            child: Text(
              _caption(),
              key: ValueKey(_region),
              textAlign: TextAlign.center,
              style: GtText.caption.colored(_region == null ? GtColors.text3 : GtColors.text1),
            ),
          ),
          if (cardio != null && cardio.countInWindow > 0) ...[
            const SizedBox(height: GtSpace.md),
            CardioPill(label: 'Cardio · ${cardio.countInWindow}×'),
          ],
          const SizedBox(height: GtSpace.lg),
          const Divider(),
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
    final last = recency.lastDayKey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(width: 92, child: Text(recency.group.name, style: GtText.label.sized(14), maxLines: 1)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) => Stack(
                children: [
                  Container(height: 6, decoration: ShapeDecoration(color: GtColors.s3, shape: squircle(3))),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: fraction),
                    duration: GtMotion.of(context, const Duration(milliseconds: 700)),
                    curve: GtMotion.emphasized,
                    builder: (context, f, _) => Container(
                      height: 6,
                      width: c.maxWidth * f,
                      decoration: ShapeDecoration(color: context.accent, shape: squircle(3)),
                    ),
                  ),
                ],
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
            width: 92,
            child: Text(
              last == null ? '–' : Fmt.relativeDay(last, today),
              textAlign: TextAlign.end,
              style: GtText.caption,
            ),
          ),
        ],
      ),
    );
  }
}
