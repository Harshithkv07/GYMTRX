import '../core/utils/day_key.dart';

/// Trailing average over the last [windowDays] calendar days (inclusive) at
/// each point. Feed it every weigh-in, oldest first, then cut to the chart
/// range, so the first points in view still average a full window.
List<(int, double)> movingAverage(List<(int, double)> oldestFirst, {int windowDays = 7}) {
  final out = <(int, double)>[];
  var lo = 0;
  var sum = 0.0;
  for (var i = 0; i < oldestFirst.length; i++) {
    final (day, v) = oldestFirst[i];
    sum += v;
    while (DayKeys.daysBetween(oldestFirst[lo].$1, day) >= windowDays) {
      sum -= oldestFirst[lo].$2;
      lo++;
    }
    out.add((day, sum / (i - lo + 1)));
  }
  return out;
}

typedef BodyWeightProgress = ({double toGoKg, double fraction, bool achieved, bool losing});

/// Progress from [startKg] toward [targetKg]; the direction comes from which
/// side of the start the target is on.
BodyWeightProgress bodyWeightGoal({required double startKg, required double targetKg, required double currentKg}) {
  final losing = targetKg < startKg;
  final achieved = losing ? currentKg <= targetKg + 1e-6 : currentKg >= targetKg - 1e-6;
  final total = (targetKg - startKg).abs();
  final done = losing ? startKg - currentKg : currentKg - startKg;
  final fraction = achieved ? 1.0 : (total < 1e-9 ? 0.0 : (done / total).clamp(0.0, 1.0));
  return (toGoKg: achieved ? 0.0 : (targetKg - currentKg).abs(), fraction: fraction, achieved: achieved, losing: losing);
}
