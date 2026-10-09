import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// The GYMTRX mark: a 3×3 grid of dots ("days"), a few of them logged.
/// Mirrors the launcher icon.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64, this.on, this.off});

  final double size;
  final Color? on;
  final Color? off;

  /// Which of the nine dots are "logged".
  static const pattern = [true, false, true, false, true, true, true, false, false];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MarkPainter(on ?? c.accent, off ?? c.dotOff)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.on, this.off);

  final Color on;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 3;
    for (var i = 0; i < 9; i++) {
      final center = Offset((i % 3 + 0.5) * cell, (i ~/ 3 + 0.5) * cell);
      canvas.drawCircle(center, cell * 0.36, Paint()..color = BrandMark.pattern[i] ? on : off);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.on != on || old.off != off;
}
