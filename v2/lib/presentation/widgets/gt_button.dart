import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import 'pressable.dart';

enum GtButtonKind {
  /// The dark pill with an accent label ("Get started", "Done").
  ink,

  /// Accent fill with dark text.
  accent,

  /// White pill with a hairline edge.
  secondary,
  ghost,
  danger,
}

/// Pill button.
class GtButton extends StatelessWidget {
  const GtButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.kind = GtButtonKind.ink,
    this.expand = false,
    this.height = 56,
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
    final c = context.c;
    final (Color bg, Color fg, BorderSide side) = switch (kind) {
      GtButtonKind.ink => (c.ink, c.accentOnInk, BorderSide.none),
      GtButtonKind.accent => (c.accent, c.onAccent, BorderSide.none),
      GtButtonKind.secondary => (c.surface, c.text1, BorderSide(color: c.hairlineStrong)),
      GtButtonKind.ghost => (Colors.transparent, c.text2, BorderSide.none),
      GtButtonKind.danger => (c.danger.withValues(alpha: 0.1), c.danger, BorderSide.none),
    };
    final disabled = onTap == null;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
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
          padding: const EdgeInsets.symmetric(horizontal: 26),
          decoration: ShapeDecoration(
            color: bg,
            shape: StadiumBorder(side: side),
            shadows: kind == GtButtonKind.ink && !c.isDark
                ? [BoxShadow(color: c.ink.withValues(alpha: 0.22), blurRadius: 20, offset: const Offset(0, 8))]
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
