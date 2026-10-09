import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';

/// The GYMTRX mark: a 3×3 grid of days, a few of them logged. Mirrors the
/// launcher icon and the heatmap.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});

  final double size;

  /// Which of the nine cells are "logged".
  static const pattern = [true, false, true, false, true, true, true, false, false];

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: size, child: CustomPaint(painter: _MarkPainter(context.accent)));
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = size.width * 0.08;
    final cell = (size.width - gap * 2) / 3;
    for (var i = 0; i < 9; i++) {
      final rect = Rect.fromLTWH((i % 3) * (cell + gap), (i ~/ 3) * (cell + gap), cell, cell);
      final paint = Paint()..color = BrandMark.pattern[i] ? accent : GtColors.s3;
      canvas.drawPath(squircle(cell * 0.32).getOuterPath(rect), paint);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.accent != accent;
}
