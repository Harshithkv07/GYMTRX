import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../logic/providers/progress_providers.dart';
import '../../logic/streaks.dart';
import '../widgets/pressable.dart';
import '../widgets/progress_ring.dart';
import '../widgets/rolling_number.dart';
import '../widgets/surface.dart';
import 'goal_sheets.dart';

/// The flame, the streak in weeks, and this week's sessions against the goal.
class StreakHero extends ConsumerWidget {
  const StreakHero({super.key, this.onShare});

  /// Shares the streak as an image; null hides the button.
  final void Function(StreakStats stats)? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(streakProvider);
    final lit = s.current > 0;
    final met = s.thisWeekMet;
    final lastDay = Fmt.weekdayLong(DayKeys.addDays(s.weekStartKey == 0 ? 20240101 : s.weekStartKey, 6));

    final status = switch ((met, s.completedRun > 0)) {
      (true, _) => 'Week done. Your streak is safe.',
      (false, true) => '${Fmt.plural(s.remaining, 'more session')} by $lastDay keeps it going.',
      (false, false) => 'Train ${Fmt.plural(s.thisWeekGoal, 'time')} this week to start a streak.',
    };

    return GtCard(
      padding: const EdgeInsets.fromLTRB(GtSpace.xl, GtSpace.xl, GtSpace.xl, GtSpace.lg),
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
                      children: [
                        _Flame(lit: lit),
                        const SizedBox(width: GtSpace.sm),
                        RollingNumber(
                          s.current,
                          style: GtText.monoDisplay.sized(48).colored(lit ? GtColors.text1 : GtColors.text3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('week streak', style: GtText.label.colored(GtColors.text2)),
                    const SizedBox(height: GtSpace.md),
                    Row(
                      children: [
                        const Icon(GtIcons.medal, size: 14, color: GtColors.gold),
                        const SizedBox(width: 6),
                        Text('Best ${Fmt.plural(s.best, 'week')}', style: GtText.caption),
                      ],
                    ),
                  ],
                ),
              ),
              Pressable(
                onTap: () => editWeeklyGoal(context, ref),
                scale: 0.95,
                semanticLabel: '${s.thisWeekCount} of ${s.thisWeekGoal} sessions this week. Change weekly goal',
                child: Column(
                  children: [
                    ProgressRing(
                      value: s.thisWeekCount / s.thisWeekGoal,
                      segments: s.thisWeekGoal,
                      color: met ? GtColors.gold : context.accent,
                      size: 88,
                      stroke: 8,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '${s.thisWeekCount}', style: GtText.monoTitle.sized(22)),
                            TextSpan(text: '/${s.thisWeekGoal}', style: GtText.mono.colored(GtColors.text2)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: GtSpace.sm),
                    Text('THIS WEEK', style: GtText.overline.sized(10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GtSpace.lg),
          const Divider(),
          const SizedBox(height: GtSpace.md),
          Row(
            children: [
              Expanded(
                child: Text(status, style: GtText.label.colored(met ? GtColors.gold : GtColors.text1)),
              ),
              if (onShare != null && s.current > 0)
                Pressable(
                  onTap: () => onShare!(s),
                  scale: 0.9,
                  semanticLabel: 'Share streak',
                  child: const Padding(
                    padding: EdgeInsets.all(GtSpace.xs),
                    child: Icon(GtIcons.share, size: 18, color: GtColors.text2),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Flame extends StatelessWidget {
  const _Flame({required this.lit});

  final bool lit;

  @override
  Widget build(BuildContext context) {
    final icon = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: lit
            ? RadialGradient(colors: [GtColors.flame.withValues(alpha: 0.35), GtColors.flame.withValues(alpha: 0)])
            : null,
      ),
      child: Icon(GtIcons.flame, size: 30, color: lit ? GtColors.flame : GtColors.s3),
    );
    if (!lit || GtMotion.reduced(context)) return icon;
    return icon
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.94, end: 1.06, duration: 1100.ms, curve: Curves.easeInOut);
  }
}
