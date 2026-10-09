import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import 'pressable.dart';

/// A white squircle card with a soft, wide shadow (light theme) or a faint
/// rim (dark theme).
class GtCard extends StatelessWidget {
  const GtCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GtSpace.lg),
    this.radius = GtRadius.lg,
    this.color,
    this.onTap,
    this.onLongPress,
    this.haptic = PressHaptic.light,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final PressHaptic haptic;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final card = DecoratedBox(
      decoration: ShapeDecoration(
        color: color ?? c.surface,
        shape: squircle(radius, side: c.isDark ? BorderSide(color: c.hairline) : BorderSide.none),
        shadows: shadow ? c.cardShadow : null,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null && onLongPress == null) return card;
    return Pressable(onTap: onTap, onLongPress: onLongPress, haptic: haptic, scale: 0.98, child: card);
  }
}

/// Frosted glass: blurs whatever is underneath. Uses the grouped backdrop so
/// several glass surfaces on screen share one backdrop read.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = GtRadius.xl,
    this.sigma = 20,
    this.tint,
    this.border = true,
    this.shadow = false,
  });

  final Widget child;
  final double radius;
  final double sigma;
  final Color? tint;
  final bool border;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final shape = squircle(radius, side: border ? BorderSide(color: c.isDark ? c.hairline : const Color(0x99FFFFFF)) : BorderSide.none);
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, shadows: shadow ? c.floatShadow : null),
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: DecoratedBox(
            decoration: ShapeDecoration(color: tint ?? c.glass, shape: shape),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A round frosted button, as floated over artwork in the reference design.
class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 20,
    this.iconColor,
    this.semanticLabel,
    this.solid = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final String? semanticLabel;

  /// A plain surface circle instead of frosted glass (on cards).
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final glyph = SizedBox(
      width: size,
      height: size,
      child: Icon(icon, size: iconSize, color: iconColor ?? c.text1),
    );
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: semanticLabel,
      child: solid
          ? DecoratedBox(
              decoration: ShapeDecoration(
                color: c.surface2,
                shape: CircleBorder(side: BorderSide(color: c.hairline)),
              ),
              child: glyph,
            )
          : Glass(radius: size / 2, sigma: 14, child: glyph),
    );
  }
}
