import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/core/theme/accents.dart';
import 'package:gymtrx/core/theme/tokens.dart';

/// WCAG contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// How colourful a colour is, 0 (grey) to 1 (pure hue). Neon accents like
/// volt (#D4FF3F) sit around 0.75.
double _chroma(Color c) => math.max(c.r, math.max(c.g, c.b)) - math.min(c.r, math.min(c.g, c.b));

double _distance(Color a, Color b) =>
    math.sqrt(math.pow(a.r - b.r, 2) + math.pow(a.g - b.g, 2) + math.pow(a.b - b.b, 2));

void main() {
  // The Neon pack is GYMTRX's original set, kept exactly as it was, so only
  // Sage is held to the calm and reserved-colour rules.
  test('sage accents are calm, never neon', () {
    for (final a in GtAccentPack.sage.accents) {
      expect(_chroma(a.color), lessThanOrEqualTo(0.40), reason: '${a.label} is too saturated');
    }
  });

  test('dark text stays readable on every accent', () {
    for (final a in GtAccent.values) {
      expect(_contrast(GtColors.onAccent, a.color), greaterThanOrEqualTo(7), reason: a.label);
    }
  });

  test('no sage accent can be mistaken for gold, flame or missed red', () {
    for (final a in GtAccentPack.sage.accents) {
      for (final reserved in [GtColors.gold, GtColors.flame, GtColors.missed]) {
        expect(_distance(a.color, reserved), greaterThan(0.25), reason: '${a.label} vs $reserved');
      }
    }
  });

  test('every accent is in exactly one pack, and the default is sage', () {
    expect(GtAccentPack.sage.accents, hasLength(12));
    expect(GtAccentPack.neon.accents, [
      GtAccent.volt,
      GtAccent.ice,
      GtAccent.ember,
      GtAccent.neonRose,
      GtAccent.mint,
      GtAccent.neonLilac,
    ]);
    final packed = [for (final p in GtAccentPack.values) ...p.accents];
    expect(packed.toSet(), GtAccent.values.toSet());
    expect(packed, hasLength(GtAccent.values.length));
    expect(GtAccent.fallback.pack, GtAccentPack.sage);
  });

  test('accent names round-trip, and unknown ones fall back to the default', () {
    expect(GtAccent.fromName('volt'), GtAccent.volt);
    expect(GtAccent.fromName('neonRose'), GtAccent.neonRose);
    expect(GtAccent.fromName('clay'), GtAccent.clay);
    expect(GtAccent.fromName('nope'), GtAccent.fallback);
    expect(GtAccent.fromName(null), GtAccent.fallback);
  });
}
