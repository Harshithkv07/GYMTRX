import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../body_map/body_map_data.dart';
import '../body_map/muscle_regions.dart';

/// Parsed paths for one side of the body, built once and shared.
class BodySide {
  BodySide._(Map<String, List<String>> parts, String outline, double offsetX)
    : regions = {
        for (final MapEntry(:key, :value) in parts.entries) key: _combine(value).shift(Offset(-offsetX, 0)),
      },
      outline = parseSvgPathData(outline).shift(Offset(-offsetX, 0));

  static final front = BodySide._(bodyFrontParts, bodyFrontOutline, 0);
  static final back = BodySide._(bodyBackParts, bodyBackOutline, 724);

  /// Path coordinates per side (the artwork's own units).
  static const viewBox = Size(724, 1448);

  final Map<String, Path> regions;
  final Path outline;

  late final Map<String, Rect> _bounds = {for (final e in regions.entries) e.key: e.value.getBounds()};

  // Muscles first, so they win wherever a muscle overlaps a non-muscle part.
  late final List<String> _order = [
    ...regions.keys.where(muscleRegions.contains),
    ...regions.keys.where((k) => !muscleRegions.contains(k)),
  ];

  final _fields = <int, DotField>{};

  /// The silhouette sampled every [step] artwork units (cached).
  DotField dots(int step) => _fields.putIfAbsent(step, () => DotField._sample(this, step.toDouble()));

  static Path _combine(List<String> svg) {
    final path = Path();
    for (final d in svg) {
      path.addPath(parseSvgPathData(d), Offset.zero);
    }
    return path;
  }

  /// The muscle region at [p] (artwork units), if any.
  String? hitTest(Offset p) {
    for (final key in _order) {
      if (!muscleRegions.contains(key)) continue;
      if (_bounds[key]!.contains(p) && regions[key]!.contains(p)) return key;
    }
    return null;
  }
}

/// One side's silhouette sampled on a square grid. Muscle dots are grouped
/// by region and sorted bottom-first, so a bottom-to-top reveal is just a
/// prefix of each list.
class DotField {
  DotField._(this.step, this.all, this.hair, this.byRegion, this.top, this.bottom);

  final double step;

  /// Every dot except the hair, as x,y pairs for [Canvas.drawRawPoints].
  final Float32List all;
  final Float32List hair;
  final Map<String, Float32List> byRegion;
  final double top;
  final double bottom;

  static DotField _sample(BodySide side, double step) {
    var bounds = side.outline.getBounds();
    for (final b in side._bounds.values) {
      bounds = bounds.expandToInclude(b);
    }
    final outlineBounds = side.outline.getBounds();
    // Grid anchored at multiples of the step, so front and back line up.
    final x0 = (bounds.left / step).floor() * step + step / 2;
    final y0 = (bounds.top / step).floor() * step + step / 2;

    final all = <double>[];
    final hair = <double>[];
    final byRegion = <String, List<double>>{};
    for (var y = y0; y <= bounds.bottom; y += step) {
      for (var x = x0; x <= bounds.right; x += step) {
        final p = Offset(x, y);
        String? key;
        for (final k in side._order) {
          if (side._bounds[k]!.contains(p) && side.regions[k]!.contains(p)) {
            key = k;
            break;
          }
        }
        if (key == null && !(outlineBounds.contains(p) && side.outline.contains(p))) continue;
        if (key == 'hair') {
          hair.addAll([x, y]);
          continue;
        }
        all.addAll([x, y]);
        if (key != null && muscleRegions.contains(key)) byRegion.putIfAbsent(key, () => []).addAll([x, y]);
      }
    }

    Float32List bottomFirst(List<double> xy) {
      final pairs = [for (var i = 0; i < xy.length; i += 2) (xy[i], xy[i + 1])]..sort((a, b) => b.$2.compareTo(a.$2));
      final out = Float32List(xy.length);
      for (var i = 0; i < pairs.length; i++) {
        out[i * 2] = pairs[i].$1;
        out[i * 2 + 1] = pairs[i].$2;
      }
      return out;
    }

    return DotField._(
      step,
      Float32List.fromList(all),
      Float32List.fromList(hair),
      {for (final e in byRegion.entries) e.key: bottomFirst(e.value)},
      bounds.top,
      bounds.bottom,
    );
  }
}

enum DotBodyView { both, front, back }

/// The body map as a dot-matrix figure: every dot is a pixel of the
/// silhouette, and the muscles in [strength] (region → 0..1) light up in the
/// accent, sweeping in from the feet up.
class DotBody extends StatefulWidget {
  const DotBody({
    super.key,
    required this.strength,
    required this.height,
    this.view = DotBodyView.both,
    this.spacing = 3.2,
    this.reveal = true,
    this.glow = true,
    this.onRegionTap,
    this.litColor,
    this.offColor,
  });

  final Map<String, double> strength;

  /// Height of each figure. Each is half as wide.
  final double height;
  final DotBodyView view;

  /// Distance between dots on screen, in logical pixels.
  final double spacing;
  final bool reveal;
  final bool glow;
  final ValueChanged<String>? onRegionTap;

  /// Overrides for dots drawn on an ink surface (selected tiles).
  final Color? litColor;
  final Color? offColor;

  static const _steps = [8, 10, 12, 14, 17, 20, 24, 28, 34, 40, 48, 56];

  /// The cached grid step closest to [spacing] at [height].
  static int stepFor(double height, double spacing) {
    final ideal = spacing * BodySide.viewBox.height / height;
    return _steps.reduce((a, b) => (a - ideal).abs() <= (b - ideal).abs() ? a : b);
  }

  /// Samples the common sizes during idle time so the first screen that
  /// shows a body never pays for it.
  static void warmUp() {
    for (final step in const [48, 17, 20, 40]) {
      for (final side in [BodySide.front, BodySide.back]) {
        SchedulerBinding.instance.scheduleTask(() => side.dots(step), Priority.idle);
      }
    }
  }

  @override
  State<DotBody> createState() => _DotBodyState();
}

class _DotBodyState extends State<DotBody> with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reveal.isDismissed) {
      if (!widget.reveal || GtMotion.reduced(context)) {
        _reveal.value = 1;
      } else {
        _reveal.forward();
      }
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final step = DotBody.stepFor(widget.height, widget.spacing);
    // Small figures (thumbnails, tiles) get fatter, darker dots, or the
    // silhouette dissolves into the background at that size.
    final pitch = step * widget.height / BodySide.viewBox.height;
    final small = pitch < 2.8;
    final lit = widget.litColor ?? c.accentStrong;
    final off = widget.offColor ?? (small ? Color.lerp(c.dotOff, c.text2, c.isDark ? 0.18 : 0.32)! : c.dotOff);

    Widget figure(BodySide side) {
      final size = Size(widget.height / 2, widget.height);
      return GestureDetector(
        onTapUp: widget.onRegionTap == null
            ? null
            : (d) {
                final k = BodySide.viewBox.height / widget.height;
                final hit = side.hitTest(d.localPosition * k);
                if (hit != null) widget.onRegionTap!(hit);
              },
        child: SizedBox.fromSize(
          size: size,
          child: CustomPaint(
            painter: _DotBodyPainter(
              side: side,
              field: side.dots(step),
              strength: widget.strength,
              reveal: _reveal,
              lit: lit,
              glowColor: c.accent,
              off: off,
              hair: Color.lerp(off, c.text1, c.isDark ? 0.25 : 0.35)!,
              glow: widget.glow,
              offSize: small ? 0.64 : 0.46,
              litSize: small ? 0.76 : 0.52,
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Body map',
      child: RepaintBoundary(
        child: switch (widget.view) {
          DotBodyView.front => figure(BodySide.front),
          DotBodyView.back => figure(BodySide.back),
          DotBodyView.both => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              figure(BodySide.front),
              SizedBox(width: widget.height * 0.07),
              figure(BodySide.back),
            ],
          ),
        },
      ),
    );
  }
}

class _DotBodyPainter extends CustomPainter {
  _DotBodyPainter({
    required this.side,
    required this.field,
    required this.strength,
    required this.reveal,
    required this.lit,
    required this.glowColor,
    required this.off,
    required this.hair,
    required this.glow,
    required this.offSize,
    required this.litSize,
  }) : super(repaint: reveal);

  final BodySide side;
  final DotField field;
  final Map<String, double> strength;
  final Animation<double> reveal;
  final Color lit;
  final Color glowColor;
  final Color off;
  final Color hair;
  final bool glow;

  /// Dot diameters as a fraction of the grid step: unlit, and lit at zero
  /// strength (full strength adds a little more).
  final double offSize;
  final double litSize;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / BodySide.viewBox.height;
    canvas.save();
    canvas.translate((size.width - BodySide.viewBox.width * scale) / 2, 0);
    canvas.scale(scale);

    final step = field.step;
    final dot = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = step * offSize
      ..color = off;
    canvas.drawRawPoints(ui.PointMode.points, field.all, dot);
    canvas.drawRawPoints(ui.PointMode.points, field.hair, dot..color = hair);

    // The scan line rises from the feet; each region's dots light as it passes.
    final t = GtMotion.emphasized.transform(reveal.value);
    final scanY = field.bottom - (field.bottom - field.top) * t * 1.02;
    for (final MapEntry(key: region, value: s) in strength.entries) {
      final pts = field.byRegion[region];
      if (pts == null || s <= 0) continue;
      final n = _countBelow(pts, scanY);
      if (n == 0) continue;

      if (glow) {
        final path = side.regions[region];
        if (path != null) {
          final regionReveal = n / (pts.length / 2);
          canvas.drawPath(
            path,
            Paint()
              ..color = glowColor.withValues(alpha: 0.30 * s * regionReveal)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
          );
        }
      }
      dot
        ..color = Color.lerp(off, lit, 0.45 + 0.55 * s)!
        ..strokeWidth = step * (litSize + 0.16 * s);
      canvas.drawRawPoints(ui.PointMode.points, Float32List.sublistView(pts, 0, n * 2), dot);
    }
    canvas.restore();
  }

  /// Points are sorted by y, largest first: how many lie at or below [y].
  static int _countBelow(Float32List pts, double y) {
    var lo = 0, hi = pts.length ~/ 2;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (pts[mid * 2 + 1] >= y) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  @override
  bool shouldRepaint(_DotBodyPainter old) =>
      old.field != field ||
      old.strength != strength ||
      old.lit != lit ||
      old.off != off ||
      old.hair != hair ||
      old.glowColor != glowColor ||
      old.glow != glow ||
      old.offSize != offSize ||
      old.litSize != litSize;
}
