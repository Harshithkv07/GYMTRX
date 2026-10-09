import 'package:flutter/widgets.dart';

import 'colors.dart';

abstract final class GtFonts {
  static const sans = 'Geist';
  static const mono = 'GeistMono';

  /// Doto: a dot-matrix display face for headlines and big numbers.
  static const dot = 'Doto';
}

/// Type scale. All three families are variable fonts, so every style sets
/// both [TextStyle.fontWeight] (for matching) and the `wght` axis (for the
/// actual glyph weight). Use [GtTextStyle.weight] to change weight safely.
///
/// Styles carry no colour: text inherits the theme's primary text colour, and
/// secondary text is coloured at the call site or through [GtType].
abstract final class GtText {
  static const display = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 32,
    height: 1.08,
    letterSpacing: -0.9,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600)],
  );

  static const title = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 20,
    height: 1.2,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600)],
  );

  static const titleSmall = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 17,
    height: 1.25,
    letterSpacing: -0.25,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600)],
  );

  static const body = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 15,
    height: 1.4,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation.weight(400)],
  );

  static const label = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 13,
    height: 1.3,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
  );

  static const caption = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 0.05,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation.weight(400)],
  );

  /// Small uppercase section labels.
  static const overline = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 11,
    height: 1.2,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    fontFeatures: _monoFeatures,
  );

  /// Tiny "HUD" labels on the welcome art.
  static const micro = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 8.5,
    height: 1.35,
    letterSpacing: 1.4,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    fontFeatures: _monoFeatures,
  );

  /// Large numbers with decimals (body weight): Geist with tabular figures.
  static const figure = TextStyle(
    fontFamily: GtFonts.sans,
    fontSize: 40,
    height: 1.0,
    letterSpacing: -1.2,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600)],
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Geist Mono: dates and small numbers. ss09 swaps the slashed zero for a plain one.
  static const _monoFeatures = [FontFeature('ss09')];

  static const monoTitle = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 20,
    height: 1.1,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    fontFeatures: _monoFeatures,
  );

  static const mono = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 14,
    height: 1.3,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    fontFeatures: _monoFeatures,
  );

  static const monoSmall = TextStyle(
    fontFamily: GtFonts.mono,
    fontSize: 11,
    height: 1.2,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500)],
    fontFeatures: _monoFeatures,
  );

  /// Dot-matrix text. Uppercase reads best; digits are monospaced, so
  /// rolling counters never shift. `ROND` 100 makes every dot round.
  static TextStyle dot(double size, {double weight = 400, double height = 1.0}) => TextStyle(
    fontFamily: GtFonts.dot,
    fontSize: size,
    height: height,
    letterSpacing: size * 0.02,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [const FontVariation('ROND', 100), FontVariation.weight(weight)],
  );

  /// Screen titles: "WELCOME BACK", "OCTOBER".
  static final dotDisplay = dot(44, weight: 400);

  /// Card numbers: "12", "73·4". A touch heavier than headlines.
  static TextStyle dotFigure(double size) => dot(size, weight: 600);

  /// Doto draws "." as a small diamond that reads like "+", so dotted
  /// numbers use its single-dot "·" as the decimal point instead.
  static String figures(String number) => number.replaceAll('.', '·');
}

extension GtTextStyle on TextStyle {
  /// Changes weight on both the matcher and the variable `wght` axis,
  /// keeping any other axes (Doto's roundness).
  TextStyle weight(double value) => copyWith(
    fontWeight: FontWeight.values[((value / 100).round() - 1).clamp(0, 8)],
    fontVariations: [
      ...?fontVariations?.where((v) => v.axis != 'wght'),
      FontVariation.weight(value),
    ],
  );

  TextStyle colored(Color color) => copyWith(color: color);

  TextStyle sized(double size) => copyWith(fontSize: size);
}

/// Ready-coloured styles for the current theme: `context.tx.caption`.
class GtType {
  const GtType(this.c);

  final GtColors c;

  TextStyle get body => GtText.body.colored(c.text1);
  TextStyle get bodySecondary => GtText.body.colored(c.text2);
  TextStyle get label => GtText.label.colored(c.text1);
  TextStyle get labelSecondary => GtText.label.colored(c.text2);
  TextStyle get caption => GtText.caption.colored(c.text2);
  TextStyle get captionFaint => GtText.caption.colored(c.text3);
  TextStyle get overline => GtText.overline.colored(c.text2);
  TextStyle get overlineFaint => GtText.overline.colored(c.text3);

  /// Coral overline: muscle groups above a card title.
  TextStyle get tag => GtText.overline.sized(10.5).weight(600).colored(c.tag);
}

extension GtTypeContext on BuildContext {
  GtType get tx => GtType(c);
}
