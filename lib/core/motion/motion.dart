import 'package:flutter/widgets.dart';

/// Motion tokens shared by every animation in the app.
abstract final class GtMotion {
  static const fast = Duration(milliseconds: 140);
  static const medium = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 420);

  /// Material 3 "emphasized": quick start, long gentle settle.
  static const emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const decelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const accelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  /// Snappy, slightly under-damped spring for press feedback.
  static final press = SpringDescription.withDampingRatio(mass: 1, stiffness: 650, ratio: 0.72);

  /// Smooth, critically damped spring for things that settle into place.
  static final settle = SpringDescription.withDampingRatio(mass: 1, stiffness: 320, ratio: 1.0);

  /// Bouncier spring for small "pop" moments (selection marks, counters).
  static final pop = SpringDescription.withDampingRatio(mass: 1, stiffness: 420, ratio: 0.6);

  /// True when the user turned on Android's "Remove animations".
  static bool reduced(BuildContext context) => MediaQuery.disableAnimationsOf(context);

  /// [duration], or zero when animations are disabled system-wide.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
