import 'package:flutter/material.dart';

/// Colour tokens. GYMTRX is dark-only: depth comes from tone steps and
/// hairlines rather than shadows.
abstract final class GtColors {
  static const bg = Color(0xFF0A0A0B);
  static const s1 = Color(0xFF141416);
  static const s2 = Color(0xFF1C1C1F);
  static const s3 = Color(0xFF26262A);

  static const hairline = Color(0x0FFFFFFF); // 6% white
  static const hairlineStrong = Color(0x1AFFFFFF); // 10% white
  static const highlight = Color(0x14FFFFFF); // 8% white, top inner edge of cards

  static const text1 = Color(0xFFF4F4F5);
  static const text2 = Color(0xFF8E8E93);
  static const text3 = Color(0xFF5C5C63);

  static const onAccent = Color(0xFF0A0A0B);

  /// Destructive actions. Missed program days use [missed].
  static const danger = Color(0xFFFF5C5C);

  /// Personal records and reached goals.
  static const gold = Color(0xFFFFC94D);
  static const goldMuted = Color(0x29FFC94D); // 16%

  /// The streak flame.
  static const flame = Color(0xFFFF9F1C);
  static const flameMuted = Color(0x29FF9F1C); // 16%

  /// Program days that passed without a session.
  static const missed = Color(0xFFFF4D4F);
  static const missedMuted = Color(0x29FF4D4F); // 16%
}

/// 4-pt spacing grid.
abstract final class GtSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double x3 = 32;
  static const double x4 = 40;

  /// Horizontal page padding.
  static const double gutter = 20;
}

abstract final class GtRadius {
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
}

/// Continuous-curvature ("squircle") shape used for every surface.
RoundedSuperellipseBorder squircle(double radius, {BorderSide side = BorderSide.none}) =>
    RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(radius), side: side);
