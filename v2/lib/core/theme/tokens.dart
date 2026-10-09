import 'package:flutter/material.dart';

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
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
}

/// Continuous-curvature ("squircle") shape used for every surface.
RoundedSuperellipseBorder squircle(double radius, {BorderSide side = BorderSide.none}) =>
    RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(radius), side: side);
