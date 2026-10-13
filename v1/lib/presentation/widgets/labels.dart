import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/program_plan.dart';

/// "Chest · Triceps", ordered like the chip grid.
String groupLabel(Iterable<int> ids, Map<int, MuscleGroup> byId) {
  final groups = [for (final id in ids) ?byId[id]]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return groups.map((g) => g.name).join(' · ');
}

/// "3 exercises · 45 min", or empty when there is nothing beyond groups.
String entryMeta(EntrySummary e) {
  final parts = [
    if (e.exerciseCount > 0) Fmt.plural(e.exerciseCount, 'exercise'),
    if (e.durationMin != null) Fmt.duration(e.durationMin!),
  ];
  return parts.join(' · ');
}

/// Screen-reader label for a calendar day.
String daySemantics(
  int dayKey,
  EntrySummary? e,
  Map<int, MuscleGroup> byId, {
  PlanStatus plan = PlanStatus.none,
  String? holiday,
  int? steps,
}) {
  final date = [Fmt.fullDate(dayKey), ?holiday].join(', ');
  if (e == null) {
    final base = switch (plan) {
      PlanStatus.missed => '$date, missed program day',
      PlanStatus.planned => '$date, planned',
      _ => date,
    };
    return steps == null ? base : '$base, ${Fmt.plural(steps, 'step')}';
  }
  final groups = groupLabel(e.groupIds, byId);
  return groups.isEmpty ? '$date, logged' : '$date, logged $groups';
}

/// One set on a single line: "60 kg × 8", "12 reps", "20 min · 3.2 km", "1:00".
String formatSet(ExerciseSet set, ExerciseKind kind, WeightUnit unit) {
  switch (kind) {
    case ExerciseKind.strength:
      final w = set.weightKg == null ? null : Units.format(set.weightKg!, unit);
      final r = set.reps;
      if (w != null && r != null) return '$w × $r';
      if (w != null) return w;
      return r == null ? '–' : '$r reps';
    case ExerciseKind.bodyweight:
      return set.reps == null ? '–' : '${set.reps} reps';
    case ExerciseKind.cardio:
      final parts = [
        if (set.durationSec != null) Fmt.duration(set.durationSec! ~/ 60),
        if (set.distanceKm != null) '${Fmt.number(set.distanceKm!)} km',
      ];
      return parts.isEmpty ? '–' : parts.join(' · ');
    case ExerciseKind.timed:
      return set.durationSec == null ? '–' : Fmt.clock(set.durationSec!);
  }
}
