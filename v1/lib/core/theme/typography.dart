import 'package:flutter/painting.dart';

import 'tokens.dart';

abstract final class GtFonts {
  static const sans = 'Geist';
  static const mono = 'GeistMono';
}

/// Type scale. Geist and Geist Mono are variable fonts, so every style sets
/// both [TextStyle.fontWeight] (for matching) and the `wght` axis (for the
/// actual glyph weight). Use [GtTextStyle.weight] to change weight safely.
abstract final class GtText {
  static const display = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 40,
    height: 1.05,
    letterSpacing: -1.0,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600)],
    color: GtColors.text1,
  );

  static const headline = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 28,
    height: 1.1,
    letterSpacing: -0.6,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600)],
    color: GtColors.text1,
  );

  static const title = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 20,
    height: 1.2,
    letterSpacing: -0.3,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600)],
    color: GtColors.text1,
  );

  static const titleSmall = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 17,
    height: 1.25,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600)],
    color: GtColors.text1,
  );

  static const body = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 15,
    height: 1.4,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation.weight(400)],
    color: GtColors.text1,
  );

  static const label = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 13,
    height: 1.3,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    color: GtColors.text1,
  );

  static const caption = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation.weight(400)],
    color: GtColors.text2,
  );

  /// Small uppercase section labels.
  static const overline = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 11,
    height: 1.2,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    color: GtColors.text2,
  );

  /// Large numbers with decimals (body weight): Geist with tabular figures,
  /// because a monospaced decimal point is as wide as a digit.
  static const figure = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 40,
    height: 1.0,
    letterSpacing: -1.2,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600)],
    fontFeatures: [FontFeature.tabularFigures()],
    color: GtColors.text1,
  );

  // Numbers and dates use Geist Mono (monospaced, so digits never shift while
  // counting). ss09 swaps its slashed zero for a plain one.
  static const _monoFeatures = [FontFeature('ss09')];

  static const monoDisplay = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 44,
    height: 1.0,
    letterSpacing: -1.5,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    fontFeatures: _monoFeatures,
    color: GtColors.text1,
  );

  static const monoTitle = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 20,
    height: 1.1,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    fontFeatures: _monoFeatures,
    color: GtColors.text1,
  );

  static const mono = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 14,
    height: 1.3,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    fontFeatures: _monoFeatures,
    color: GtColors.text1,
  );

  static const monoSmall = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 11,
    height: 1.2,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    fontFeatures: _monoFeatures,
    color: GtColors.text2,
  );
}

extension GtTextStyle on TextStyle {
  /// Changes weight on both the matcher and the variable `wght` axis.
  TextStyle weight(double value) => copyWith(
    fontWeight: FontWeight.values[((value / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation.weight(value)],
  );

  TextStyle colored(Color color) => copyWith(color: color);

  TextStyle sized(double size) => copyWith(fontSize: size);
}
