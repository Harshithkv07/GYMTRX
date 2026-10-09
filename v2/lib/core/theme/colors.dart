import 'package:flutter/material.dart';

import 'accents.dart';

/// Every colour the app paints with, for one brightness and one accent.
/// A theme extension, so switching theme or accent tweens the whole app.
@immutable
class GtColors extends ThemeExtension<GtColors> {
  const GtColors({
    required this.brightness,
    required this.bg,
    required this.mistA,
    required this.mistB,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.glass,
    required this.ink,
    required this.onInk,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.tag,
    required this.danger,
    required this.hairline,
    required this.hairlineStrong,
    required this.dotOff,
    required this.shadow,
    required this.accent,
    required this.onAccent,
    required this.accentOnInk,
    required this.accentStrong,
  });

  factory GtColors.light(GtAccent a) {
    final accent = a.light;
    return GtColors(
      brightness: Brightness.light,
      bg: const Color(0xFFEEF2EE),
      mistA: const Color(0xFFDDE8EA),
      mistB: const Color(0xFFE6F0DA),
      surface: const Color(0xFFFFFFFF),
      surface2: const Color(0xFFF3F6F2),
      surface3: const Color(0xFFE4E9E3),
      glass: const Color(0xB8FFFFFF),
      ink: const Color(0xFF161B26),
      onInk: const Color(0xFFFFFFFF),
      text1: const Color(0xFF12161D),
      text2: const Color(0xFF646B73),
      text3: const Color(0xFF9AA1A8),
      tag: const Color(0xFFE5533D),
      danger: const Color(0xFFD93B3B),
      hairline: const Color(0x0F12161D),
      hairlineStrong: const Color(0x1C12161D),
      dotOff: const Color(0xFFCDD4CC),
      shadow: const Color(0xFF1F2A22),
      accent: accent,
      onAccent: _onFill(accent),
      accentOnInk: _onInkFg(accent, const Color(0xFF161B26)),
      accentStrong: _strong(accent),
    );
  }

  factory GtColors.dark(GtAccent a) {
    final accent = a.dark;
    return GtColors(
      brightness: Brightness.dark,
      bg: const Color(0xFF0E1114),
      mistA: const Color(0xFF13201F),
      mistB: const Color(0xFF171E14),
      surface: const Color(0xFF171B21),
      surface2: const Color(0xFF1F242B),
      surface3: const Color(0xFF29303A),
      glass: const Color(0xA61F242B),
      ink: const Color(0xFF283141),
      onInk: const Color(0xFFF2F4F3),
      text1: const Color(0xFFF2F4F3),
      text2: const Color(0xFF9AA2A9),
      text3: const Color(0xFF5E666E),
      tag: const Color(0xFFFF7A63),
      danger: const Color(0xFFFF5C5C),
      hairline: const Color(0x12FFFFFF),
      hairlineStrong: const Color(0x21FFFFFF),
      dotOff: const Color(0xFF2E3640),
      shadow: const Color(0xFF000000),
      accent: accent,
      onAccent: _onFill(accent),
      accentOnInk: _onInkFg(accent, const Color(0xFF283141)),
      accentStrong: accent,
    );
  }

  static GtColors of(Brightness brightness, GtAccent accent) =>
      brightness == Brightness.dark ? GtColors.dark(accent) : GtColors.light(accent);

  final Brightness brightness;

  /// Page background, plus the two tints of its soft mist gradient.
  final Color bg;
  final Color mistA;
  final Color mistB;

  /// Cards, then insets (fields, chips), then tracks and dividers.
  final Color surface;
  final Color surface2;
  final Color surface3;

  /// Frosted fill for floating circles and the nav bar.
  final Color glass;

  /// The dark pill: primary buttons, the ＋ button, toasts.
  final Color ink;
  final Color onInk;

  final Color text1;
  final Color text2;
  final Color text3;

  /// Coral overline labels ("CHEST · TRICEPS").
  final Color tag;

  /// Destructive actions only.
  final Color danger;
  final Color hairline;
  final Color hairlineStrong;

  /// Unlit dots in the dot-matrix art and charts.
  final Color dotOff;
  final Color shadow;

  /// Accent as a fill (gym days, selected chips).
  final Color accent;

  /// Text and icons on top of an accent fill.
  final Color onAccent;

  /// Accent as text or icons on an [ink] surface ("Get started").
  final Color accentOnInk;

  /// Accent as a foreground on light surfaces (lit dots, links): darker in
  /// the light theme so it reads on white.
  final Color accentStrong;

  bool get isDark => brightness == Brightness.dark;
  Color get accentMuted => accentStrong.withValues(alpha: isDark ? 0.16 : 0.14);

  /// Soft, wide shadow for cards in the light theme; dark cards use rims.
  List<BoxShadow> get cardShadow => isDark
      ? const []
      : [
          BoxShadow(color: shadow.withValues(alpha: 0.06), blurRadius: 32, offset: const Offset(0, 12)),
          BoxShadow(color: shadow.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
        ];

  List<BoxShadow> get floatShadow => [
    BoxShadow(color: shadow.withValues(alpha: isDark ? 0.5 : 0.12), blurRadius: 28, offset: const Offset(0, 10)),
  ];

  static Color _onFill(Color fill) => fill.computeLuminance() > 0.4 ? const Color(0xFF12161D) : Colors.white;

  static Color _onInkFg(Color accent, Color ink) {
    final ratio = _contrast(accent, ink);
    return ratio >= 3 ? accent : Colors.white;
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Darkens a bright accent until it reads on white.
  static Color _strong(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    if (_contrast(accent, Colors.white) >= 2.6) return accent;
    var l = hsl.lightness;
    var c = accent;
    while (_contrast(c, Colors.white) < 2.6 && l > 0.2) {
      l -= 0.02;
      c = hsl.withLightness(l).withSaturation((hsl.saturation * 1.05).clamp(0, 1)).toColor();
    }
    return c;
  }

  @override
  GtColors copyWith() => this;

  @override
  GtColors lerp(GtColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return GtColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: l(bg, other.bg),
      mistA: l(mistA, other.mistA),
      mistB: l(mistB, other.mistB),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3),
      glass: l(glass, other.glass),
      ink: l(ink, other.ink),
      onInk: l(onInk, other.onInk),
      text1: l(text1, other.text1),
      text2: l(text2, other.text2),
      text3: l(text3, other.text3),
      tag: l(tag, other.tag),
      danger: l(danger, other.danger),
      hairline: l(hairline, other.hairline),
      hairlineStrong: l(hairlineStrong, other.hairlineStrong),
      dotOff: l(dotOff, other.dotOff),
      shadow: l(shadow, other.shadow),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentOnInk: l(accentOnInk, other.accentOnInk),
      accentStrong: l(accentStrong, other.accentStrong),
    );
  }
}

extension GtColorsContext on BuildContext {
  GtColors get c => Theme.of(this).extension<GtColors>()!;
}
