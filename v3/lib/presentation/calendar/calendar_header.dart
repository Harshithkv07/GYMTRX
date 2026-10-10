import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../widgets/pressable.dart';
import '../widgets/rolling_number.dart';
import '../widgets/surface.dart';

/// Large "October 2026 / 7 sessions" title that collapses into a compact
/// title inside a frosted bar as the calendar scrolls.
class CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  CalendarHeaderDelegate({
    required this.topPadding,
    required this.month,
    required this.count,
    required this.isCurrentMonth,
    required this.accent,
    required this.onToday,
    required this.onSettings,
  });

  static const _bar = 56.0;
  static const _large = 100.0;

  final double topPadding;
  final YearMonth month;
  final int count;
  final bool isCurrentMonth;
  final Color accent;
  final VoidCallback onToday;
  final VoidCallback onSettings;

  @override
  double get minExtent => topPadding + _bar;

  @override
  double get maxExtent => topPadding + _bar + _large;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final compactTitle = '${Fmt.monthName(month.month)} ${month.year}';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Frosted bar fades in as the header collapses.
        if (t > 0)
          Opacity(
            opacity: t,
            child: ClipRect(
              child: BackdropFilter.grouped(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: GtColors.bg.withValues(alpha: 0.72),
                    border: const Border(bottom: BorderSide(color: GtColors.hairline)),
                  ),
                ),
              ),
            ),
          ),
        // Faint accent glow behind the title.
        Positioned(
          left: -120,
          top: -160,
          width: 380,
          height: 380,
          child: IgnorePointer(
            child: Opacity(
              opacity: 1 - t,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [accent.withValues(alpha: 0.10), accent.withValues(alpha: 0)]),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: topPadding,
          left: GtSpace.gutter,
          right: GtSpace.md,
          height: _bar,
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Opacity(
                      opacity: (1 - t * 2).clamp(0.0, 1.0),
                      child: Text('GYMTRX', style: GtText.overline.sized(12).colored(GtColors.text1)),
                    ),
                    Opacity(
                      opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
                      child: Text(compactTitle, style: GtText.titleSmall),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: GtMotion.medium,
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(a), child: child),
                ),
                child: isCurrentMonth ? const SizedBox.shrink() : _TodayPill(onTap: onToday),
              ),
              const SizedBox(width: GtSpace.xs),
              GtIconButton(
                icon: GtIcons.settings,
                onTap: onSettings,
                color: Colors.transparent,
                iconSize: 22,
                semanticLabel: 'Settings',
              ),
            ],
          ),
        ),
        Positioned(
          left: GtSpace.gutter,
          right: GtSpace.gutter,
          bottom: 14,
          child: IgnorePointer(
            ignoring: t > 0.5,
            child: Opacity(
              opacity: (1 - t * 1.6).clamp(0.0, 1.0),
              child: _LargeTitle(month: month, count: count),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(CalendarHeaderDelegate old) =>
      old.month != month ||
      old.count != count ||
      old.topPadding != topPadding ||
      old.isCurrentMonth != isCurrentMonth ||
      old.accent != accent;
}

class _LargeTitle extends StatelessWidget {
  const _LargeTitle({required this.month, required this.count});

  final YearMonth month;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: GtMotion.of(context, const Duration(milliseconds: 380)),
                switchInCurve: GtMotion.emphasized,
                switchOutCurve: GtMotion.accelerate,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.bottomLeft,
                  children: [...previous, ?current],
                ),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(a),
                    child: child,
                  ),
                ),
                child: Text(
                  Fmt.monthName(month.month),
                  key: ValueKey(month),
                  style: GtText.display,
                  maxLines: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${month.year}', style: GtText.monoTitle.colored(GtColors.text2)),
            ),
          ],
        ),
        const SizedBox(height: GtSpace.sm),
        Row(
          children: [
            RollingNumber(count, style: GtText.mono.sized(15).colored(GtColors.text2)),
            Text(count == 1 ? ' session' : ' sessions', style: GtText.body.colored(GtColors.text2)),
          ],
        ),
      ],
    );
  }
}

class _TodayPill extends StatelessWidget {
  const _TodayPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.md),
        alignment: Alignment.center,
        decoration: ShapeDecoration(color: GtColors.s2, shape: squircle(16)),
        child: Text('This month', style: GtText.label),
      ),
    );
  }
}
