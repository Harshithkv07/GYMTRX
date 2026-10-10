import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/tokens.dart';

/// A round progress track that sweeps to [value] (0..1) with a rounded cap.
/// Optional [segments] split the track into that many arcs, one per session.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 64,
    this.stroke = 7,
    this.segments,
    this.child,
  });

  final double value;
  final Color color;
  final double size;
  final double stroke;
  final int? segments;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: GtMotion.of(context, const Duration(milliseconds: 900)),
      curve: GtMotion.emphasized,
      builder: (context, v, child) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(value: v, color: color, stroke: stroke, segments: segments),
        child: SizedBox.square(dimension: size, child: Center(child: child)),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.stroke, required this.segments});

  final double value;
  final Color color;
  final double stroke;
  final int? segments;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: (size.shortestSide - stroke) / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    const start = -math.pi / 2;

    final n = segments;
    if (n != null && n > 1 && n <= 14) {
      // One arc per session with small gaps: reads as "2 of 3" at a glance.
      final gap = stroke * 1.6 / (rect.width / 2);
      final sweep = (2 * math.pi - gap * n) / n;
      for (var i = 0; i < n; i++) {
        final filled = value * n - i;
        final a = start + i * (sweep + gap) + gap / 2;
        canvas.drawArc(rect, a, sweep, false, paint..color = GtColors.s3);
        if (filled > 0) canvas.drawArc(rect, a, sweep * filled.clamp(0, 1), false, paint..color = color);
      }
      return;
    }

    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = GtColors.s3);
    if (value > 0) canvas.drawArc(rect, start, 2 * math.pi * value, false, paint..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.stroke != stroke || old.segments != segments;
}

/// A slim horizontal track that fills to [value] (0..1).
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, required this.color, this.height = 6});

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: ShapeDecoration(color: GtColors.s3, shape: StadiumBorder()),
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: GtMotion.of(context, const Duration(milliseconds: 900)),
        curve: GtMotion.emphasized,
        builder: (context, v, _) => FractionallySizedBox(
          widthFactor: v,
          heightFactor: 1,
          child: DecoratedBox(decoration: ShapeDecoration(color: color, shape: const StadiumBorder())),
        ),
      ),
    );
  }
}
