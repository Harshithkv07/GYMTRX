import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'surface.dart';

/// A dot-matrix title that shrinks into a frosted bar on scroll. Used by
/// Insights, Settings and the library and exercise screens.
class LargeTitleHeader extends SliverPersistentHeaderDelegate {
  LargeTitleHeader({
    required this.title,
    required this.topPadding,
    required this.colors,
    this.showBack = false,
    this.trailing,
    this.subtitle,
  });

  static const _bar = 60.0;
  static const _large = 76.0;

  final String title;
  final double topPadding;

  /// Passed in so a theme change rebuilds the header.
  final GtColors colors;
  final bool showBack;
  final Widget? trailing;
  final String? subtitle;

  @override
  double get minExtent => topPadding + _bar;

  @override
  double get maxExtent => topPadding + _bar + _large;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final c = colors;
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
                    color: c.bg.withValues(alpha: 0.78),
                    border: Border(bottom: BorderSide(color: c.hairline)),
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
                CircleButton(icon: GtIcons.back, onTap: () => Navigator.maybePop(context), semanticLabel: 'Back'),
                const SizedBox(width: GtSpace.md),
              ],
              Expanded(
                child: Opacity(
                  opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
                  child: Text(title, style: GtText.titleSmall.colored(c.text1), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        Positioned(
          left: GtSpace.gutter,
          right: GtSpace.gutter,
          bottom: 12,
          child: IgnorePointer(
            child: Opacity(
              opacity: (1 - t * 1.6).clamp(0.0, 1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subtitle != null) ...[
                    Text(subtitle!.toUpperCase(), style: GtText.overline.colored(c.text2)),
                    const SizedBox(height: 6),
                  ],
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(title.toUpperCase(), style: GtText.dot(38).colored(c.text1), maxLines: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(LargeTitleHeader old) =>
      old.title != title ||
      old.topPadding != topPadding ||
      old.showBack != showBack ||
      old.trailing != trailing ||
      old.colors != colors ||
      old.subtitle != subtitle;
}
