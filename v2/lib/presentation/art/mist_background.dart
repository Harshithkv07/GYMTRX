import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// The page background: the base tone with two soft tints, cool at the top
/// left and green at the bottom right, like the light in the reference art.
/// Pure gradients, so it costs nothing to draw.
class MistBackground extends StatelessWidget {
  const MistBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.bg,
        gradient: RadialGradient(
          center: const Alignment(-1.1, -1.0),
          radius: 1.35,
          colors: [c.mistA, c.mistA.withValues(alpha: 0)],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1.2, 0.9),
            radius: 1.25,
            colors: [c.mistB, c.mistB.withValues(alpha: 0)],
          ),
        ),
        child: child ?? const SizedBox.expand(),
      ),
    );
  }
}
