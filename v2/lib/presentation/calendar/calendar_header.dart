import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../widgets/pressable.dart';
import '../widgets/rolling_number.dart';
import '../widgets/surface.dart';

/// A dot-matrix "OCTOBER / 2026 · 7 sessions" title that collapses into a
/// compact title inside a frosted bar as the calendar scrolls.
class CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  CalendarHeaderDelegate({
    required this.topPadding,
    required this.month,
    required this.count,
    required this.isCurrentMonth,
    required this.colors,
    required this.onToday,
    required this.onSettings,
  });

  static const _bar = 60.0;
  static const _large = 104.0;

  final double topPadding;
  final YearMonth month;
  final int count;
  final bool isCurrentMonth;
  final GtColors colors;
  final VoidCallback onToday;
  final VoidCallback onSettings;

  @override
  double get minExtent => topPadding + _bar;

  @override
  double get maxExtent => topPadding + _bar + _large;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final c = colors;
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final compactTitle = '${Fmt.monthName(month.month)} ${month.year}';

    return Stack(
      fit: StackFit.expand,
      children: [
        if (t > 0)
          Opacity(
            opacity: t,
            child: ClipRect(
              child: BackdropFilter.grouped(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.bg.withValues(alpha: 0.78),
                    border: Border(bottom: BorderSide(color: c.hairline)),
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
                      child: Text('CALENDAR', style: GtText.overline.colored(c.text2)),
                    ),
                    Opacity(
                      opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
                      child: Text(compactTitle, style: GtText.titleSmall.colored(c.text1)),
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
              const SizedBox(width: GtSpace.sm),
              CircleButton(icon: GtIcons.settings, onTap: onSettings, semanticLabel: 'Settings'),
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
              child: _LargeTitle(month: month, count: count, colors: c),
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
      old.colors != colors;
}

class _LargeTitle extends StatelessWidget {
  const _LargeTitle({required this.month, required this.count, required this.colors});

  final YearMonth month;
  final int count;
  final GtColors colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
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
          child: FittedBox(
            key: ValueKey(month),
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: Text(
              Fmt.monthName(month.month).toUpperCase(),
              style: GtText.dot(46, weight: 400).colored(c.text1),
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(height: GtSpace.sm),
        Row(
          children: [
            Text('${month.year} · ', style: GtText.mono.sized(13).colored(c.text2)),
            RollingNumber(count, style: GtText.mono.sized(13).colored(c.text2)),
            Text(count == 1 ? ' session' : ' sessions', style: GtText.label.colored(c.text2)),
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
    final c = context.c;
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: ShapeDecoration(color: c.ink, shape: const StadiumBorder()),
        child: Text('This month', style: GtText.label.weight(600).colored(c.onInk)),
      ),
    );
  }
}
