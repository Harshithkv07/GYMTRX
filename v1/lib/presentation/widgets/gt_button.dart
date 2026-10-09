import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'pressable.dart';

enum GtButtonKind { primary, secondary, ghost, danger }

/// Pill button. Primary is the accent; everything else stays tonal.
class GtButton extends StatelessWidget {
  const GtButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.kind = GtButtonKind.primary,
    this.expand = false,
    this.height = 52,
    this.haptic = PressHaptic.light,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final GtButtonKind kind;
  final bool expand;
  final double height;
  final PressHaptic haptic;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    final (bg, fg) = switch (kind) {
      GtButtonKind.primary => (accent, GtColors.onAccent),
      GtButtonKind.secondary => (GtColors.s2, GtColors.text1),
      GtButtonKind.ghost => (Colors.transparent, GtColors.text2),
      GtButtonKind.danger => (GtColors.danger.withValues(alpha: 0.12), GtColors.danger),
    };
    final disabled = onTap == null;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: GtSpace.sm)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GtText.label.sized(15).weight(600).colored(fg),
          ),
        ),
      ],
    );

    return Pressable(
      onTap: onTap,
      haptic: haptic,
      scale: 0.96,
      child: AnimatedOpacity(
        duration: GtMotion.fast,
        opacity: disabled ? 0.4 : 1,
        child: AnimatedContainer(
          duration: GtMotion.medium,
          curve: GtMotion.emphasized,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.xxl),
          decoration: ShapeDecoration(color: bg, shape: squircle(height / 2)),
          child: content,
        ),
      ),
    );
  }
}
