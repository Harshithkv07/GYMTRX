import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';

/// The illustrated artwork bundled with the app.
abstract final class GtArt {
  static const welcome = 'assets/art/welcome.jpg';
  static const homeHeader = 'assets/art/home_header.jpg';

  /// Decodes both images early so they never pop in.
  static void precache(BuildContext context) {
    precacheImage(const AssetImage(welcome), context);
    precacheImage(const AssetImage(homeHeader), context);
  }
}

/// A full-bleed illustration that dissolves into the page background,
/// optionally drifting slowly (Ken Burns) with faint speed streaks across it.
/// In the dark theme the same art is dimmed so it sits in the night palette.
class HeroArt extends StatefulWidget {
  const HeroArt({
    super.key,
    required this.asset,
    this.alignment = Alignment.topCenter,
    this.fadeFrom = 0.55,
    this.fadeTo = 1.0,
    this.drift = false,
    this.streaks = false,
  });

  final String asset;
  final Alignment alignment;

  /// Where (0 = top, 1 = bottom) the fade into the background starts and ends.
  final double fadeFrom;
  final double fadeTo;
  final bool drift;
  final bool streaks;

  @override
  State<HeroArt> createState() => _HeroArtState();
}

class _HeroArtState extends State<HeroArt> with SingleTickerProviderStateMixin {
  // Only animated art needs a ticker; static headers never create one.
  AnimationController? _controller;

  AnimationController get _loop =>
      _controller ??= AnimationController(vsync: this, duration: const Duration(seconds: 24));

  bool get _animated => widget.drift || widget.streaks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_animated) return;
    if (GtMotion.reduced(context)) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget image = Image.asset(
      widget.asset,
      fit: BoxFit.cover,
      alignment: widget.alignment,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      // A missing file shows the plain mist instead of an error box.
      errorBuilder: (_, _, _) => const SizedBox.expand(),
    );
    if (c.isDark) {
      // Dim and cool the daylight art for the night palette.
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.36, 0, 0, 0, 2, //
          0, 0.40, 0, 0, 4,
          0, 0, 0.40, 0, 5,
          0, 0, 0, 1, 0,
        ]),
        child: image,
      );
    }
    if (widget.drift) {
      image = AnimatedBuilder(
        animation: _loop,
        child: image,
        builder: (context, child) {
          // Breathes in and out once per loop: a slow push-in with a little pan.
          final t = (1 - math.cos(_loop.value * 2 * math.pi)) / 2;
          return Transform.scale(
            scale: 1.0 + 0.06 * t,
            alignment: const Alignment(0.2, -0.4),
            child: child,
          );
        },
      );
    }

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (widget.streaks)
            IgnorePointer(
              child: CustomPaint(painter: _StreaksPainter(_loop, Colors.white.withValues(alpha: c.isDark ? 0.10 : 0.55))),
            ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.bg.withValues(alpha: 0), c.bg.withValues(alpha: 0), c.bg],
                  stops: [0, widget.fadeFrom, widget.fadeTo],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin horizontal light streaks drifting right to left, like motion blur.
class _StreaksPainter extends CustomPainter {
  _StreaksPainter(this.loop, this.color) : super(repaint: loop);

  final Animation<double> loop;
  final Color color;

  // (y as a fraction of height, length as a fraction of width, speed, phase)
  static const _streaks = [
    (0.20, 0.55, 3.0, 0.10),
    (0.27, 0.30, 4.0, 0.62),
    (0.34, 0.45, 2.0, 0.35),
    (0.41, 0.25, 5.0, 0.81),
    (0.46, 0.60, 3.0, 0.48),
    (0.53, 0.35, 4.0, 0.05),
    (0.60, 0.50, 2.0, 0.72),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (fy, fl, speed, phase) in _streaks) {
      final len = size.width * fl;
      final travel = size.width + len;
      final p = (phase + loop.value * speed) % 1.0;
      final x = size.width - p * travel;
      final y = size.height * fy;
      final rect = Rect.fromLTWH(x, y, len, 1.2);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(_StreaksPainter old) => old.color != color;
}
