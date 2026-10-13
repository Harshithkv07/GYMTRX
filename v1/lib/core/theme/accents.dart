import 'package:flutter/material.dart';

/// The two sets of accents, browsed with the pill in Settings → Accent.
enum GtAccentPack {
  /// Calm and muted, never neon. The default.
  sage('Sage'),

  /// GYMTRX's original bright accents, kept as they were.
  neon('Neon');

  const GtAccentPack(this.label);

  final String label;

  List<GtAccent> get accents => [
    for (final a in GtAccent.values)
      if (a.pack == this) a,
  ];
}

/// Curated accent colours. Each is light enough to carry dark text
/// ([GtColors.onAccent]) on top. The Sage pack also stays clear of the
/// colours reserved for records (gold), streaks (flame) and missed days
/// (red); `test/accents_test.dart` holds new ones to the same rules.
///
/// The enum names are stored in settings and backups, so they never change.
enum GtAccent {
  sage('Sage', Color(0xFFA8C8A0)),
  teal('Teal', Color(0xFF7FC8BE)),
  sky('Sky', Color(0xFF9EC5EA)),
  periwinkle('Periwinkle', Color(0xFFA8B4F0)),
  lilac('Lilac', Color(0xFFC1AEF2)),
  rose('Rose', Color(0xFFEBA6BE)),
  clay('Clay', Color(0xFFE0A084)),
  sand('Sand', Color(0xFFE2D2B0)),
  olive('Olive', Color(0xFFC7C88E)),
  steel('Steel', Color(0xFFAFB9C7)),
  stone('Stone', Color(0xFFC9C2B8)),
  mono('Mono', Color(0xFFF4F4F5)),

  volt('Volt', Color(0xFFD4FF3F), GtAccentPack.neon),
  ice('Ice', Color(0xFF8AD8FF), GtAccentPack.neon),
  ember('Ember', Color(0xFFFF7A3D), GtAccentPack.neon),
  neonRose('Rose', Color(0xFFFF6B9A), GtAccentPack.neon),
  mint('Mint', Color(0xFF5CF2B5), GtAccentPack.neon),
  neonLilac('Lilac', Color(0xFFB9A4FF), GtAccentPack.neon);

  const GtAccent(this.label, this.color, [this.pack = GtAccentPack.sage]);

  final String label;
  final Color color;
  final GtAccentPack pack;

  static const fallback = GtAccent.sage;

  /// Unknown names fall back to [fallback].
  static GtAccent fromName(String? name) => GtAccent.values.firstWhere((a) => a.name == name, orElse: () => fallback);
}
