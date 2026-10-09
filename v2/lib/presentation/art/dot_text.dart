import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';

/// Dot-matrix text that switches on like an LED sign the first time it
/// appears: a soft edge sweeps left to right and the dots light behind it.
class DotText extends StatefulWidget {
  const DotText(
    this.text, {
    super.key,
    required this.style,
    this.reveal = true,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final TextStyle style;
  final bool reveal;
  final Duration delay;
  final Duration duration;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  State<DotText> createState() => _DotTextState();
}

class _DotTextState extends State<DotText> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_c.isDismissed) return;
    if (!widget.reveal || GtMotion.reduced(context)) {
      _c.value = 1;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(
      widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      softWrap: true,
    );
    return AnimatedBuilder(
      animation: _c,
      child: text,
      builder: (context, child) {
        if (_c.isCompleted) return child!;
        final t = Curves.easeOutCubic.transform(_c.value) * 1.3;
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => LinearGradient(
            colors: const [Colors.white, Colors.white, Color(0x00FFFFFF)],
            stops: [0, (t - 0.3).clamp(0.0, 1.0), t.clamp(0.0, 1.0)],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}
