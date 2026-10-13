import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../data/models/progress.dart';
import '../../logic/records.dart';

/// "100 kg × 5", "Est. 1RM 116.7 kg", "15 reps", "5.2 km", "1:35".
String formatPrValue(PrHit hit, SetRecordRow? row, WeightUnit unit) => switch (hit.metric) {
  PrMetric.heaviest =>
    row?.reps == null ? Units.format(hit.value, unit) : '${Units.format(hit.value, unit)} × ${row!.reps}',
  PrMetric.e1rm => 'Est. 1RM ${Units.format(hit.value, unit, maxDecimals: 1)}',
  PrMetric.reps => Fmt.plural(hit.value.round(), 'rep'),
  PrMetric.distance => '${Fmt.number(hit.value)} km',
  PrMetric.duration => _duration(hit.value, row),
};

/// How much the record beat the previous best by: "+2.5 kg", "+3 reps".
String formatPrGain(PrHit hit, SetRecordRow? row, WeightUnit unit) {
  final d = hit.value - hit.previous;
  return switch (hit.metric) {
    PrMetric.heaviest || PrMetric.e1rm => '+${Units.format(d, unit, maxDecimals: 1)}',
    PrMetric.reps => '+${Fmt.plural(d.round(), 'rep')}',
    PrMetric.distance => '+${Fmt.number(d)} km',
    PrMetric.duration => '+${_duration(d, row)}',
  };
}

String _duration(double seconds, SetRecordRow? row) => row?.kind == ExerciseKind.cardio
    ? Fmt.duration((seconds / 60).round())
    : (seconds < 60 ? '${seconds.round()} s' : Fmt.clock(seconds.round()));
