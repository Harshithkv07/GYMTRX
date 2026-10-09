import 'package:flutter/material.dart';

/// Curated accent colours. All are bright enough to carry dark text
/// ([GtColors.onAccent]) on top.
enum GtAccent {
  volt('Volt', Color(0xFFD4FF3F)),
  ice('Ice', Color(0xFF8AD8FF)),
  ember('Ember', Color(0xFFFF7A3D)),
  rose('Rose', Color(0xFFFF6B9A)),
  mint('Mint', Color(0xFF5CF2B5)),
  lilac('Lilac', Color(0xFFB9A4FF)),
  mono('Mono', Color(0xFFF4F4F5));

  const GtAccent(this.label, this.color);

  final String label;
  final Color color;

  static GtAccent fromName(String? name) =>
      GtAccent.values.firstWhere((a) => a.name == name, orElse: () => GtAccent.volt);
}
