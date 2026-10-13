import '../data/database/tables.dart' show ExerciseKind;
import '../data/models/guide.dart';

/// The guide's muscle names → GYMTRX's muscle-group slugs.
const guideMuscleToGroup = {
  'abdominals': 'core',
  'abductors': 'glutes',
  'adductors': 'legs',
  'biceps': 'biceps',
  'calves': 'calves',
  'chest': 'chest',
  'forearms': 'forearms',
  'glutes': 'glutes',
  'hamstrings': 'legs',
  'lats': 'back',
  'lower back': 'back',
  'middle back': 'back',
  'neck': 'traps',
  'quadriceps': 'legs',
  'shoulders': 'shoulders',
  'traps': 'traps',
  'triceps': 'triceps',
};

/// The guide's muscle names → body-map regions.
const guideMuscleToRegions = {
  'abdominals': ['abs', 'obliques'],
  'abductors': ['gluteal'],
  'adductors': ['adductors'],
  'biceps': ['biceps'],
  'calves': ['calves'],
  'chest': ['chest'],
  'forearms': ['forearm'],
  'glutes': ['gluteal'],
  'hamstrings': ['hamstring'],
  'lats': ['upper-back'],
  'lower back': ['lower-back'],
  'middle back': ['upper-back'],
  'neck': ['trapezius'],
  'quadriceps': ['quadriceps'],
  'shoulders': ['deltoids'],
  'traps': ['trapezius'],
  'triceps': ['triceps'],
};

/// Body-map strengths: main muscles full, supporting ones faint.
Map<String, double> guideBodyMap(GuideExercise e) => {
  for (final m in e.secondaryMuscles)
    for (final r in guideMuscleToRegions[m] ?? const <String>[]) r: 0.35,
  for (final m in e.primaryMuscles)
    for (final r in guideMuscleToRegions[m] ?? const <String>[]) r: 1.0,
};

/// Which muscle group an exercise from the guide belongs to.
String? guideGroupSlug(GuideExercise e) =>
    e.category == 'cardio' ? 'cardio' : guideMuscleToGroup[e.primaryMuscles.firstOrNull];

/// How sets are recorded for an exercise from the guide.
ExerciseKind guideKind(GuideExercise e) => switch (e.category) {
  'cardio' => ExerciseKind.cardio,
  'stretching' => ExerciseKind.timed,
  _ when e.equipment == 'body only' || e.equipment == null => ExerciseKind.bodyweight,
  _ => ExerciseKind.strength,
};

/// "e-z curl bar" → "EZ curl bar", "body only" → "Bodyweight".
String guideEquipmentLabel(String equipment) => switch (equipment) {
  'body only' => 'Bodyweight',
  'e-z curl bar' => 'EZ curl bar',
  'foam roll' => 'Foam roller',
  _ => equipment[0].toUpperCase() + equipment.substring(1),
};

final _word = RegExp('[a-z0-9]+');

Set<String> _words(String s) => {
  for (final m in _word.allMatches(s.toLowerCase().replaceAll('-', ' ')))
    switch (m.group(0)!) {
      'db' => 'dumbbell',
      'bb' => 'barbell',
      'ez' => 'e',
      'pushup' || 'pushups' => 'push',
      'pullup' || 'pullups' => 'pull',
      'flyes' || 'flye' => 'fly',
      final w when w.length > 3 && w.endsWith('s') => w.substring(0, w.length - 1),
      final w => w,
    },
};

/// Guide exercises whose names look like [name], best first.
List<GuideExercise> guideMatches(String name, Iterable<GuideExercise> all, {int limit = 8}) {
  final q = _words(name);
  if (q.isEmpty) return const [];
  final scored = <(double, GuideExercise)>[];
  for (final e in all) {
    final w = _words(e.name);
    final common = q.intersection(w).length;
    if (common == 0) continue;
    // Words in common, against everything mentioned; a full match of the
    // query's words counts extra.
    final score = common / q.union(w).length + (common == q.length ? 0.5 : 0);
    scored.add((score, e));
  }
  scored.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final s in scored.take(limit)) s.$2];
}
