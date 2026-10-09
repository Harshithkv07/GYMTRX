import 'package:flutter/material.dart';

/// The accent-dependent part of the theme. Lerps so that picking a new accent
/// tweens the whole app through MaterialApp's implicit theme animation.
@immutable
class GtPalette extends ThemeExtension<GtPalette> {
  const GtPalette({required this.accent});

  final Color accent;

  Color get accentMuted => accent.withValues(alpha: 0.14);
  Color get accentSoft => accent.withValues(alpha: 0.28);
  Color get accentGlow => accent.withValues(alpha: 0.22);

  @override
  GtPalette copyWith({Color? accent}) => GtPalette(accent: accent ?? this.accent);

  @override
  GtPalette lerp(GtPalette? other, double t) {
    if (other == null) return this;
    return GtPalette(accent: Color.lerp(accent, other.accent, t)!);
  }
}

extension GtThemeContext on BuildContext {
  GtPalette get gt => Theme.of(this).extension<GtPalette>()!;
  Color get accent => gt.accent;
}
