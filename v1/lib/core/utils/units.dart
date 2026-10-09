import 'formatters.dart';

enum WeightUnit {
  kg,
  lb;

  static WeightUnit fromName(String? name) => name == 'lb' ? WeightUnit.lb : WeightUnit.kg;
}

/// Weights are always stored in kilograms and converted only for display.
abstract final class Units {
  static const kgPerLb = 0.45359237;

  static double toDisplay(double kg, WeightUnit unit) => unit == WeightUnit.kg ? kg : kg / kgPerLb;

  static double toKg(double value, WeightUnit unit) => unit == WeightUnit.kg ? value : value * kgPerLb;

  /// "62.5 kg" / "137.8 lb"
  static String format(double kg, WeightUnit unit, {bool withUnit = true, int maxDecimals = 2}) {
    final display = toDisplay(kg, unit);
    final decimals = unit == WeightUnit.lb ? 1 : maxDecimals;
    final s = Fmt.number(display, maxDecimals: decimals);
    return withUnit ? '$s ${unit.name}' : s;
  }
}
