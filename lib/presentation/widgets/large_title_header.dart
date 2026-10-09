import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'surface.dart';

/// iOS-style large title that shrinks into a frosted bar on scroll. Used by
/// Insights, Settings and the exercise screens.
class LargeTitleHeader extends SliverPersistentHeaderDelegate {
  LargeTitleHeader({required this.title, required this.topPadding, this.showBack = false, this.trailing});

  static const _bar = 56.0;
  static const _large = 64.0;

  final String title;
  final double topPadding;
  final bool showBack;
  final Widget? trailing;

  @override
  double get minExtent => topPadding + _bar;

  @override
  double get maxExtent => topPadding + _bar + _large;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
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
                    color: GtColors.bg.withValues(alpha: 0.72),
                    border: const Border(bottom: BorderSide(color: GtColors.hairline)),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: topPadding,
          left: showBack ? GtSpace.md : GtSpace.gutter,
          right: GtSpace.md,
          height: _bar,
          child: Row(
            children: [
              if (showBack) ...[
                GtIconButton(icon: GtIcons.back, onTap: () => Navigator.maybePop(context), semanticLabel: 'Back'),
                const SizedBox(width: GtSpace.md),
              ],
              Expanded(
                child: Opacity(
                  opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
                  child: Text(title, style: GtText.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        Positioned(
          left: GtSpace.gutter,
          right: GtSpace.gutter,
          bottom: 10,
          child: IgnorePointer(
            child: Opacity(
              opacity: (1 - t * 1.6).clamp(0.0, 1.0),
              child: Text(title, style: GtText.display.sized(34), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(LargeTitleHeader old) =>
      old.title != title || old.topPadding != topPadding || old.showBack != showBack || old.trailing != trailing;
}
