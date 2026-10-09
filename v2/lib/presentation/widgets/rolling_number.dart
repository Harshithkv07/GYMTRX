import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';

/// A number whose digits roll like an odometer when the value changes.
/// Expects a tabular-figure style (all digits the same width).
class RollingNumber extends StatelessWidget {
  const RollingNumber(this.value, {super.key, required this.style, this.duration = GtMotion.slow});

  final int value;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final text = value.toString();
    final scaler = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final size = painter.size;
    painter.dispose();

    final chars = text.split('');
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < chars.length; i++)
            int.tryParse(chars[i]) == null
                ? Text(chars[i], style: style)
                : _Digit(
                    // Keyed from the right so the units digit keeps its state
                    // when the number gains a digit.
                    key: ValueKey(chars.length - i),
                    digit: int.parse(chars[i]),
                    cell: size,
                    style: style,
                    duration: GtMotion.of(context, duration),
                  ),
        ],
      ),
    );
  }
}

class _Digit extends StatelessWidget {
  const _Digit({super.key, required this.digit, required this.cell, required this.style, required this.duration});

  final int digit;
  final Size cell;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: digit.toDouble()),
      duration: duration,
      curve: GtMotion.emphasized,
      builder: (context, v, _) => SizedBox(
        width: cell.width,
        height: cell.height,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: cell.height * 10,
            child: Transform.translate(
              offset: Offset(0, -v * cell.height),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var d = 0; d < 10; d++)
                    SizedBox(height: cell.height, child: Text('$d', style: style)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
