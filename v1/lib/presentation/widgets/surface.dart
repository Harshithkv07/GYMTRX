import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import 'pressable.dart';

/// A squircle surface with a hairline edge that is brighter at the top,
/// like light catching the rim of a card.
class GtCard extends StatelessWidget {
  const GtCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GtSpace.lg),
    this.radius = GtRadius.lg,
    this.color = GtColors.s1,
    this.onTap,
    this.onLongPress,
    this.haptic = PressHaptic.light,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final PressHaptic haptic;

  @override
  Widget build(BuildContext context) {
    final card = CustomPaint(
      foregroundPainter: _RimPainter(radius),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: color, shape: squircle(radius)),
        child: Padding(padding: padding, child: child),
      ),
    );
    if (onTap == null && onLongPress == null) return card;
    return Pressable(onTap: onTap, onLongPress: onLongPress, haptic: haptic, scale: 0.98, child: card);
  }
}

class _RimPainter extends CustomPainter {
  const _RimPainter(this.radius);

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = squircle(radius).getOuterPath(rect.deflate(0.5));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x1FFFFFFF), Color(0x0AFFFFFF)],
        stops: [0, 0.6],
      ).createShader(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RimPainter oldDelegate) => oldDelegate.radius != radius;
}

/// Frosted glass: blurs whatever scrolls underneath. Uses the grouped
/// backdrop so several glass surfaces on screen share one backdrop read.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = GtRadius.xl,
    this.sigma = 24,
    this.tint = const Color(0xB8141416),
    this.border = true,
  });

  final Widget child;
  final double radius;
  final double sigma;
  final Color tint;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: CustomPaint(
          foregroundPainter: border ? _RimPainter(radius) : null,
          child: DecoratedBox(
            decoration: ShapeDecoration(color: tint, shape: squircle(radius)),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Small round icon button on a tonal surface.
class GtIconButton extends StatelessWidget {
  const GtIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.iconSize = 20,
    this.color = GtColors.s2,
    this.iconColor = GtColors.text1,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color color;
  final Color iconColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      semanticLabel: semanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(color: color, shape: squircle(size * 0.36)),
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
