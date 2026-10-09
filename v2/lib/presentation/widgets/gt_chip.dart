import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import 'pressable.dart';

/// Selectable pill. Selecting it floods ink outward from the exact point the
/// finger touched (a two-layer reveal), so the label changes colour
/// pixel-perfectly as the fill passes over it.
class GtChip extends StatefulWidget {
  const GtChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 40,
    this.horizontalPadding = 16,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double height;
  final double horizontalPadding;
  final IconData? icon;

  @override
  State<GtChip> createState() => _GtChipState();
}

class _GtChipState extends State<GtChip> with SingleTickerProviderStateMixin {
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: widget.selected ? 1 : 0,
  );
  Offset? _origin;

  @override
  void didUpdateWidget(GtChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected == oldWidget.selected) return;
    if (GtMotion.reduced(context)) {
      _fill.value = widget.selected ? 1 : 0;
    } else if (widget.selected) {
      _fill.forward(from: 0);
    } else {
      _fill.reverse();
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  Widget _layer({required Color bg, required Color fg, Color? border}) {
    // Center(widthFactor: 1) centres vertically without stretching
    // horizontally, so chips hug their label inside a Wrap.
    return Container(
      height: widget.height,
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      decoration: ShapeDecoration(
        color: bg,
        shape: StadiumBorder(side: border == null ? BorderSide.none : BorderSide(color: border)),
      ),
      child: Center(
        widthFactor: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[Icon(widget.icon, size: 15, color: fg), const SizedBox(width: 6)],
            Text(widget.label, maxLines: 1, style: GtText.label.sized(14).colored(fg)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Pressable(
      onTap: widget.onTap,
      haptic: PressHaptic.selection,
      scale: 0.94,
      onTapDown: (d) => _origin = d.localPosition,
      semanticLabel: '${widget.label}${widget.selected ? ', selected' : ''}',
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.circular(widget.height / 2),
        child: Stack(
          children: [
            _layer(bg: c.surface, fg: c.text1, border: c.hairlineStrong),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fill,
                builder: (context, child) {
                  final t = widget.selected
                      ? GtMotion.emphasized.transform(_fill.value)
                      : Curves.easeIn.transform(_fill.value);
                  if (t <= 0) return const SizedBox.shrink();
                  return ClipPath(
                    clipper: _CircleReveal(origin: _origin, progress: t),
                    child: child,
                  );
                },
                child: _layer(bg: c.ink, fg: c.onInk),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleReveal extends CustomClipper<Path> {
  const _CircleReveal({required this.origin, required this.progress});

  final Offset? origin;
  final double progress;

  @override
  Path getClip(Size size) {
    final o = origin ?? size.center(Offset.zero);
    // Farthest corner from the origin decides the full radius.
    final maxR = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].map((c) => (c - o).distance).reduce(math.max);
    return Path()..addOval(Rect.fromCircle(center: o, radius: maxR * progress));
  }

  @override
  bool shouldReclip(_CircleReveal oldClipper) => oldClipper.progress != progress || oldClipper.origin != origin;
}
