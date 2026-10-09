import 'package:flutter/material.dart';

/// Curated accent colours, tuned separately for the light and dark themes.
/// The enum names are stored in settings and backups, so they never change.
enum GtAccent {
  volt('Volt', Color(0xFFC6F24E), Color(0xFFD4FF3F)),
  ice('Ice', Color(0xFF7FCBFF), Color(0xFF8AD8FF)),
  ember('Ember', Color(0xFFFF8B4F), Color(0xFFFF7A3D)),
  rose('Rose', Color(0xFFFF86AC), Color(0xFFFF6B9A)),
  mint('Mint', Color(0xFF63E2B2), Color(0xFF5CF2B5)),
  lilac('Lilac', Color(0xFFB9A8FF), Color(0xFFB9A4FF)),
  mono('Mono', Color(0xFF161B26), Color(0xFFF2F4F3));

  const GtAccent(this.label, this.light, this.dark);

  final String label;
  final Color light;
  final Color dark;

  Color of(Brightness brightness) => brightness == Brightness.dark ? dark : light;

  static GtAccent fromName(String? name) =>
      GtAccent.values.firstWhere((a) => a.name == name, orElse: () => GtAccent.volt);
}
