import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../../core/motion/motion.dart';
import '../../core/utils/haptics.dart';

enum PressHaptic { none, selection, light, medium }

/// Press feedback without Material ripples: the child springs down to [scale]
/// while pressed and springs back on release.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.scale = 0.97,
    this.haptic = PressHaptic.light,
    this.semanticLabel,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final double scale;
  final PressHaptic haptic;
  final String? semanticLabel;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final AnimationController _scale = AnimationController.unbounded(vsync: this, value: 1);

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _springTo(double target) {
    if (GtMotion.reduced(context)) {
      _scale.value = target;
      return;
    }
    _scale.animateWith(SpringSimulation(GtMotion.press, _scale.value, target, _scale.velocity));
  }

  void _fireHaptic() {
    switch (widget.haptic) {
      case PressHaptic.none:
        break;
      case PressHaptic.selection:
        Haptics.selection();
      case PressHaptic.light:
        Haptics.light();
      case PressHaptic.medium:
        Haptics.medium();
    }
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: _enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: _enabled
            ? (details) {
                _springTo(widget.scale);
                widget.onTapDown?.call(details);
              }
            : null,
        onTapUp: _enabled ? (_) => _springTo(1) : null,
        onTapCancel: _enabled ? () => _springTo(1) : null,
        onTap: widget.onTap == null
            ? null
            : () {
                _fireHaptic();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _springTo(1);
                widget.onLongPress!();
              },
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
          child: widget.child,
        ),
      ),
    );
  }
}
