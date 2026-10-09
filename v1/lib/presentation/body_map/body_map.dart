import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import 'body_map_data.dart';
import 'muscle_regions.dart';

/// Front and back figures side by side, with trained regions lit in the
/// accent and a soft glow. [strength] maps region slugs to 0..1.
class BodyMap extends StatefulWidget {
  const BodyMap({super.key, required this.strength, this.height = 280, this.onRegionTap});

  final Map<String, double> strength;
  final double height;
  final ValueChanged<String>? onRegionTap;

  @override
  State<BodyMap> createState() => _BodyMapState();
}

class _BodyMapState extends State<BodyMap> with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reveal.isDismissed) {
      GtMotion.reduced(context) ? _reveal.value = 1 : _reveal.forward();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    Widget figure(_Side side) => GestureDetector(
      onTapUp: widget.onRegionTap == null
          ? null
          : (d) {
              final hit = side.hitTest(d.localPosition, Size(widget.height / 2, widget.height));
              if (hit != null) widget.onRegionTap!(hit);
            },
      child: SizedBox(
        width: widget.height / 2,
        height: widget.height,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _BodyPainter(side: side, strength: widget.strength, accent: accent, reveal: _reveal),
          ),
        ),
      ),
    );

    return Semantics(
      label: 'Body map',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [figure(_Side.front), const SizedBox(width: GtSpace.xxl), figure(_Side.back)],
      ),
    );
  }
}

/// Parsed paths for one side, built once and shared.
class _Side {
  _Side._(Map<String, List<String>> parts, String outline, double offsetX)
    : regions = {
        for (final MapEntry(:key, :value) in parts.entries)
          key: _combine(value).shift(Offset(-offsetX, 0)),
      },
      outline = parseSvgPathData(outline).shift(Offset(-offsetX, 0));

  static final front = _Side._(bodyFrontParts, bodyFrontOutline, 0);
  static final back = _Side._(bodyBackParts, bodyBackOutline, 724);

  static const viewBox = Size(724, 1448);

  final Map<String, Path> regions;
  final Path outline;

  static Path _combine(List<String> svg) {
    final path = Path();
    for (final d in svg) {
      path.addPath(parseSvgPathData(d), Offset.zero);
    }
    return path;
  }

  /// The muscle region under [local] in a widget of [size], if any.
  String? hitTest(Offset local, Size size) {
    final p = Offset(local.dx * viewBox.width / size.width, local.dy * viewBox.height / size.height);
    for (final MapEntry(:key, :value) in regions.entries) {
      if (muscleRegions.contains(key) && value.contains(p)) return key;
    }
    return null;
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({required this.side, required this.strength, required this.accent, required this.reveal})
    : super(repaint: reveal);

  final _Side side;
  final Map<String, double> strength;
  final Color accent;
  final Animation<double> reveal;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _Side.viewBox.width, size.height / _Side.viewBox.height);

    final base = Paint()..color = GtColors.s3;
    final rest = Paint()..color = const Color(0xFF202024);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = GtColors.bg;
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = GtColors.hairlineStrong;

    // Silhouette, then every region as a muted plate.
    for (final MapEntry(:key, :value) in side.regions.entries) {
      canvas.drawPath(value, muscleRegions.contains(key) ? base : rest);
      canvas.drawPath(value, edge);
    }
    canvas.drawPath(side.outline, rim);

    // Lit regions: glow underneath, then the fill. Stronger regions arrive
    // first, so the reveal reads as light spreading across the body.
    final t = GtMotion.emphasized.transform(reveal.value);
    for (final MapEntry(:key, :value) in strength.entries) {
      final path = side.regions[key];
      if (path == null || value <= 0) continue;
      final delay = (1 - value) * 0.35;
      final local = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (local == 0) continue;
      final glow = Paint()
        ..color = accent.withValues(alpha: 0.45 * value * local)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
      canvas.drawPath(path, glow);
      canvas.drawPath(path, Paint()..color = accent.withValues(alpha: (0.25 + 0.75 * value) * local));
      canvas.drawPath(path, edge);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.strength != strength || old.accent != accent || old.side != side;
}
