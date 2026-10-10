import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/haptics.dart';

/// Gold trophy on a set that's a personal record. It springs in with a burst
/// and a double haptic the moment a set becomes one; sets that already were
/// records when the screen opened just show it.
class PrBadge extends StatefulWidget {
  const PrBadge({super.key, required this.isPr, this.size = 24});

  /// Null while records are still loading: shown as nothing, and coming out
  /// of it never celebrates.
  final bool? isPr;
  final double size;

  @override
  State<PrBadge> createState() => _PrBadgeState();
}

class _PrBadgeState extends State<PrBadge> with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this, value: widget.isPr == true ? 1 : 0);

  @override
  void didUpdateWidget(PrBadge old) {
    super.didUpdateWidget(old);
    final was = old.isPr, now = widget.isPr;
    if (now == true && was == false) {
      _celebrate();
    } else if (now == true && was == null) {
      _c.value = 1;
    } else if (now != true && was == true) {
      _c.animateTo(0, duration: GtMotion.of(context, GtMotion.fast));
    }
  }

  void _celebrate() {
    Haptics.celebrate();
    if (GtMotion.reduced(context)) {
      _c.value = 1;
      return;
    }
    _c.value = 0;
    _c.animateWith(SpringSimulation(GtMotion.pop, 0, 1, 4));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      ParticleBurst.show(context, box.localToGlobal(box.size.center(Offset.zero)));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.isPr == true ? 'Personal record' : null,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final v = _c.value;
          if (v <= 0.001) return SizedBox(width: widget.size, height: widget.size);
          return Transform.scale(
            scale: v,
            child: Opacity(opacity: v.clamp(0, 1), child: child),
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: const BoxDecoration(color: GtColors.goldMuted, shape: BoxShape.circle),
          child: Icon(GtIcons.trophy, size: widget.size * 0.55, color: GtColors.gold),
        ),
      ),
    );
  }
}

/// A one-shot ring of gold and accent sparks, drawn in the root overlay so
/// cards that clip their content can't cut it off.
class ParticleBurst extends StatefulWidget {
  const ParticleBurst({super.key, required this.center, required this.onDone});

  final Offset center;
  final VoidCallback onDone;

  static void show(BuildContext context, Offset center) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => IgnorePointer(child: ParticleBurst(center: center, onDone: entry.remove)),
    );
    overlay.insert(entry);
  }

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))
    ..forward().whenComplete(widget.onDone);
  final _seed = math.Random();
  late final _particles = [
    for (var i = 0; i < 16; i++)
      (
        angle: i / 16 * 2 * math.pi + _seed.nextDouble() * 0.3,
        distance: 26 + _seed.nextDouble() * 22,
        size: 2.0 + _seed.nextDouble() * 2.5,
        gold: i.isEven,
      ),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _BurstPainter(
            t: _c.value,
            center: widget.center,
            particles: _particles,
            accent: accent,
          ),
        ),
      ),
    );
  }
}

typedef _Particle = ({double angle, double distance, double size, bool gold});

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.t, required this.center, required this.particles, required this.accent});

  final double t;
  final Offset center;
  final List<_Particle> particles;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final travel = Curves.easeOutCubic.transform(t);
    final fade = 1 - Curves.easeIn.transform(t);
    // A soft ring that expands with the sparks.
    canvas.drawCircle(
      center,
      8 + travel * 30,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * fade
        ..color = GtColors.gold.withValues(alpha: 0.5 * fade),
    );
    for (final p in particles) {
      final d = p.distance * travel;
      final pos = center + Offset(math.cos(p.angle) * d, math.sin(p.angle) * d);
      canvas.drawCircle(
        pos,
        p.size * (1 - t * 0.5),
        Paint()..color = (p.gold ? GtColors.gold : accent).withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
