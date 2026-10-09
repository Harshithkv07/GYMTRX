import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';

/// Columns of dots, one per period, filled from the bottom like an LED bar
/// graph. The [highlight] column is drawn in ink; tapping a column shows
/// [tooltipOf] above it.
class DotColumns extends StatefulWidget {
  const DotColumns({
    super.key,
    required this.values,
    required this.labels,
    this.highlight,
    this.rows = 10,
    this.height = 112,
    this.tooltipOf,
    this.minScale = 4,
  });

  final List<int> values;
  final List<String> labels;
  final int? highlight;
  final int rows;
  final double height;
  final String Function(int index)? tooltipOf;

  /// The scale never goes below this, so a single session isn't a full bar.
  final int minScale;

  @override
  State<DotColumns> createState() => _DotColumnsState();
}

class _DotColumnsState extends State<DotColumns> with SingleTickerProviderStateMixin {
  late final AnimationController _grow = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  int? _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_grow.isDismissed) GtMotion.reduced(context) ? _grow.value = 1 : _grow.forward();
  }

  @override
  void didUpdateWidget(DotColumns old) {
    super.didUpdateWidget(old);
    if (old.values.length != widget.values.length) _selected = null;
    if (!_sameValues(old.values, widget.values) && !GtMotion.reduced(context)) _grow.forward(from: 0.35);
  }

  static bool _sameValues(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final n = widget.values.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final colW = width / n;
        final selected = _selected;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (selected != null && widget.tooltipOf != null)
                    Positioned(
                      left: (colW * (selected + 0.5) - 70).clamp(0.0, width - 140),
                      width: 140,
                      top: 0,
                      child: Center(
                        child: Text(
                          widget.tooltipOf!(selected),
                          key: ValueKey(selected),
                          style: GtText.monoSmall.colored(c.text1),
                          maxLines: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: widget.tooltipOf == null
                  ? null
                  : (d) {
                      final i = (d.localPosition.dx / colW).floor().clamp(0, n - 1);
                      Haptics.selection();
                      setState(() => _selected = _selected == i ? null : i);
                    },
              child: SizedBox(
                height: widget.height,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _ColumnsPainter(
                      values: widget.values,
                      rows: widget.rows,
                      highlight: widget.highlight,
                      selected: selected,
                      progress: _grow,
                      minScale: widget.minScale,
                      on: Color.lerp(c.dotOff, c.text1, c.isDark ? 0.45 : 0.38)!,
                      strong: c.text1,
                      off: c.dotOff.withValues(alpha: c.isDark ? 0.55 : 0.6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < n; i++)
                  Expanded(
                    child: Text(
                      widget.labels[i],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: GtText.monoSmall
                          .sized(9.5)
                          .colored(i == widget.highlight || i == selected ? c.text1 : c.text3),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ColumnsPainter extends CustomPainter {
  _ColumnsPainter({
    required this.values,
    required this.rows,
    required this.highlight,
    required this.selected,
    required this.progress,
    required this.minScale,
    required this.on,
    required this.strong,
    required this.off,
  }) : super(repaint: progress);

  final List<int> values;
  final int rows;
  final int? highlight;
  final int? selected;
  final Animation<double> progress;
  final int minScale;
  final Color on;
  final Color strong;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    final colW = size.width / n;
    final rowH = size.height / rows;
    final d = math.min(colW * 0.5, rowH * 0.62);
    final maxV = math.max(values.fold(0, math.max), minScale);
    final t = GtMotion.emphasized.transform(progress.value);

    final offPts = <double>[], onPts = <double>[], strongPts = <double>[];
    for (var i = 0; i < n; i++) {
      final v = values[i];
      final lit = v == 0 ? 0 : math.max(1, (v / maxV * rows).round());
      final shown = (lit * t).ceil();
      final x = colW * (i + 0.5);
      final emphasis = i == highlight || i == selected;
      for (var r = 0; r < rows; r++) {
        final y = size.height - rowH * (r + 0.5);
        (r < shown ? (emphasis ? strongPts : onPts) : offPts).addAll([x, y]);
      }
    }
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = d;
    canvas.drawRawPoints(ui.PointMode.points, Float32List.fromList(offPts), paint..color = off);
    canvas.drawRawPoints(ui.PointMode.points, Float32List.fromList(onPts), paint..color = on);
    canvas.drawRawPoints(ui.PointMode.points, Float32List.fromList(strongPts), paint..color = strong);
  }

  @override
  bool shouldRepaint(_ColumnsPainter old) =>
      old.values != values ||
      old.highlight != highlight ||
      old.selected != selected ||
      old.on != on ||
      old.strong != strong ||
      old.off != off;
}

/// A row of dots, one per day, oldest on the left; gym days are lit and a
/// small marker sits under the last (today).
class DotTimeline extends StatelessWidget {
  const DotTimeline({super.key, required this.days, this.height = 22});

  final List<bool> days;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TimelinePainter(days: days, on: c.text1, off: c.dotOff, marker: c.text1),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({required this.days, required this.on, required this.off, required this.marker});

  final List<bool> days;
  final Color on;
  final Color off;
  final Color marker;

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final gap = size.width / days.length;
    final y = size.height * 0.32;
    final small = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.min(gap * 0.38, 3.0)
      ..color = off;
    final big = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.min(gap * 0.62, 5.5)
      ..color = on;
    final offPts = <double>[], onPts = <double>[];
    for (var i = 0; i < days.length; i++) {
      (days[i] ? onPts : offPts).addAll([gap * (i + 0.5), y]);
    }
    canvas.drawRawPoints(ui.PointMode.points, Float32List.fromList(offPts), small);
    canvas.drawRawPoints(ui.PointMode.points, Float32List.fromList(onPts), big);

    // Today's marker: a small triangle under the last dot.
    final x = gap * (days.length - 0.5);
    final top = y + 6;
    canvas.drawPath(
      Path()
        ..moveTo(x, top)
        ..lineTo(x - 3.5, top + 5)
        ..lineTo(x + 3.5, top + 5)
        ..close(),
      Paint()..color = marker,
    );
  }

  @override
  bool shouldRepaint(_TimelinePainter old) => old.days != days || old.on != on || old.off != off;
}

/// A small line chart drawn as a trail of dots; the latest value is a
/// larger dot in the accent.
class DotSparkline extends StatelessWidget {
  const DotSparkline({super.key, required this.values, this.height = 34});

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparkPainter(values: values, line: c.text2, end: c.accentStrong, ring: c.surface),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.values, required this.line, required this.end, required this.ring});

  final List<double> values;
  final Color line;
  final Color end;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const pad = 5.0;
    final lo = values.reduce(math.min), hi = values.reduce(math.max);
    final span = hi - lo == 0 ? 1.0 : hi - lo;
    Offset at(int i) => Offset(
      values.length == 1 ? size.width - pad : pad + (size.width - pad * 2) * i / (values.length - 1),
      pad + (size.height - pad * 2) * (1 - (values[i] - lo) / span),
    );

    final pts = <double>[];
    for (var i = 0; i < values.length - 1; i++) {
      final a = at(i), b = at(i + 1);
      final dist = (b - a).distance;
      final steps = math.max(1, (dist / 4).floor());
      for (var s = 0; s < steps; s++) {
        final p = Offset.lerp(a, b, s / steps)!;
        pts.addAll([p.dx, p.dy]);
      }
    }
    canvas.drawRawPoints(
      ui.PointMode.points,
      Float32List.fromList(pts),
      Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.8
        ..color = line.withValues(alpha: 0.7),
    );
    final last = at(values.length - 1);
    canvas.drawCircle(last, 4.5, Paint()..color = ring);
    canvas.drawCircle(last, 3.2, Paint()..color = end);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.values != values || old.line != line || old.end != end;
}
