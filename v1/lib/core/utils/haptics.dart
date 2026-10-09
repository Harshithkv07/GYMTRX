import 'package:flutter/services.dart';

/// The app's haptic vocabulary. [enabled] mirrors the Haptics setting.
abstract final class Haptics {
  static bool enabled = true;

  /// Chips, steppers, toggles, swipes between months.
  static void selection() {
    if (enabled) HapticFeedback.selectionClick();
  }

  /// Ordinary buttons.
  static void light() {
    if (enabled) HapticFeedback.lightImpact();
  }

  /// Logging or saving something.
  static void medium() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  /// Deleting something.
  static void heavy() {
    if (enabled) HapticFeedback.heavyImpact();
  }
}
