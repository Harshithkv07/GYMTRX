import '../../core/utils/day_key.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';

/// Body-map regions that are muscles (the rest, like head and hands, are
/// only drawn as part of the silhouette).
const muscleRegions = {
  'chest',
  'abs',
  'obliques',
  'biceps',
  'triceps',
  'forearm',
  'deltoids',
  'trapezius',
  'upper-back',
  'lower-back',
  'gluteal',
  'quadriceps',
  'hamstring',
  'adductors',
  'calves',
  'tibialis',
};

/// Which regions light up for each seeded muscle group. Cardio has no
/// region; Full body lights everything at half strength.
const groupRegions = <String, List<String>>{
  'chest': ['chest'],
  'back': ['upper-back', 'lower-back', 'trapezius'],
  'shoulders': ['deltoids'],
  'biceps': ['biceps'],
  'triceps': ['triceps'],
  'legs': ['quadriceps', 'hamstring', 'adductors', 'calves', 'tibialis'],
  'glutes': ['gluteal'],
  'core': ['abs', 'obliques'],
  'forearms': ['forearm'],
  'calves': ['calves', 'tibialis'],
  'traps': ['trapezius'],
};

const _fullBodyStrength = 0.5;

/// Region → strength (0..1) for one day's groups.
Map<String, double> regionsForGroups(Iterable<MuscleGroup> groups) {
  final out = <String, double>{};
  for (final g in groups) {
    if (g.slug == 'full_body') {
      for (final r in muscleRegions) {
        out[r] = (out[r] ?? 0) < _fullBodyStrength ? _fullBodyStrength : out[r]!;
      }
    }
    for (final r in groupRegions[g.slug] ?? const <String>[]) {
      out[r] = 1;
    }
  }
  return out;
}

/// Region → heat (0..1) from how often each region was trained in the last
/// [days] days. Anything trained at all shows at least a soft glow.
Map<String, double> regionHeat(
  List<EntrySummary> entries,
  Map<int, MuscleGroup> groups,
  int today, {
  int days = 30,
}) {
  final from = DayKeys.addDays(today, -(days - 1));
  final counts = <String, double>{};
  for (final e in entries) {
    if (e.dayKey < from || e.dayKey > today) continue;
    final regions = regionsForGroups([for (final id in e.groupIds) ?groups[id]]);
    regions.forEach((r, w) => counts[r] = (counts[r] ?? 0) + w);
  }
  if (counts.isEmpty) return const {};
  final max = counts.values.reduce((a, b) => a > b ? a : b);
  return {for (final MapEntry(:key, :value) in counts.entries) key: 0.3 + 0.7 * (value / max)};
}

bool includesCardio(Iterable<MuscleGroup> groups) => groups.any((g) => g.slug == 'cardio');
