import 'package:flutter/foundation.dart';

import '../data/database/app_database.dart';
import '../data/models/progress.dart';

/// What a set can be a personal record in.
enum PrMetric {
  heaviest('Heaviest'),
  e1rm('Est. 1RM'),
  reps('Most reps'),
  distance('Longest distance'),
  duration('Longest time');

  const PrMetric(this.label);
  final String label;
}

/// A set that beat every earlier set of its exercise in [metric].
@immutable
class PrHit {
  const PrHit({
    required this.setId,
    required this.exerciseId,
    required this.dayKey,
    required this.metric,
    required this.value,
    required this.previous,
  });

  final int setId;
  final int exerciseId;
  final int dayKey;
  final PrMetric metric;

  /// In storage units: kg, reps, km or seconds.
  final double value;
  final double previous;
}

typedef PrBest = ({double value, int dayKey, int setId});

/// The personal records of one exercise on one day, for lists and sharing.
@immutable
class PrDayRecord {
  const PrDayRecord({required this.dayKey, required this.exerciseId, required this.hits});

  final int dayKey;
  final int exerciseId;
  final List<PrHit> hits;

  /// The most telling hit: heaviest beats est. 1RM beats reps and so on,
  /// and within a metric the biggest value wins.
  PrHit get headline => hits.reduce((a, b) {
    if (a.metric != b.metric) return a.metric.index < b.metric.index ? a : b;
    return b.value > a.value ? b : a;
  });
}

/// Every personal record in the log, recomputed from scratch on each change
/// so edits to old days are always reflected.
class PrIndex {
  PrIndex(this.hits, this.bests);

  static final empty = PrIndex(const [], const {});

  /// Oldest first.
  final List<PrHit> hits;

  /// Current all-time best per exercise and metric.
  final Map<int, Map<PrMetric, PrBest>> bests;

  late final Map<int, List<PrHit>> bySet = _group((h) => h.setId);
  late final Map<int, List<PrHit>> byDay = _group((h) => h.dayKey);

  Map<int, List<PrHit>> _group(int Function(PrHit) key) {
    final map = <int, List<PrHit>>{};
    for (final h in hits) {
      map.putIfAbsent(key(h), () => []).add(h);
    }
    return map;
  }

  bool isPrSet(int setId) => bySet.containsKey(setId);

  /// Exercises that set a record on [dayKey].
  Set<int> prExercisesOn(int dayKey) => {for (final h in byDay[dayKey] ?? const <PrHit>[]) h.exerciseId};

  /// `(setId, metric)` keys, to tell which hits are new since a snapshot.
  Set<(int, PrMetric)> get hitKeys => {for (final h in hits) (h.setId, h.metric)};

  /// Newest first, one row per day and exercise.
  List<PrDayRecord> recent({int limit = 20}) {
    final grouped = <(int, int), List<PrHit>>{};
    for (final h in hits.reversed) {
      grouped.putIfAbsent((h.dayKey, h.exerciseId), () => []).add(h);
      if (grouped.length > limit) break;
    }
    return [
      for (final MapEntry(key: (day, ex), value: list) in grouped.entries.take(limit))
        PrDayRecord(dayKey: day, exerciseId: ex, hits: list),
    ];
  }
}

/// Epley's estimated one-rep max. Beyond 12 reps the estimate is too loose to
/// call a record.
double? epley(double kg, int reps) {
  if (reps == 1) return kg;
  if (reps >= 2 && reps <= 12) return kg * (1 + reps / 30);
  return null;
}

/// What [r] counts toward, by its exercise's current kind. Blank and zero
/// fields count toward nothing.
Map<PrMetric, double> metricsOf(SetRecordRow r) {
  switch (r.kind) {
    case ExerciseKind.strength:
      final w = r.weightKg, reps = r.reps;
      if (w == null || w <= 0 || (reps != null && reps < 1)) return const {};
      final e = reps == null ? null : epley(w, reps);
      return {PrMetric.heaviest: w, PrMetric.e1rm: ?e};
    case ExerciseKind.bodyweight:
      final reps = r.reps;
      return reps == null || reps < 1 ? const {} : {PrMetric.reps: reps.toDouble()};
    case ExerciseKind.cardio:
      final km = r.distanceKm, sec = r.durationSec;
      return {
        if (km != null && km > 0) PrMetric.distance: km,
        if (sec != null && sec > 0) PrMetric.duration: sec.toDouble(),
      };
    case ExerciseKind.timed:
      final sec = r.durationSec;
      return sec == null || sec <= 0 ? const {} : {PrMetric.duration: sec.toDouble()};
  }
}

const _eps = 1e-6;

/// Walks every set in logging order keeping a running best per exercise and
/// metric. The first day an exercise is logged only sets the baseline; after
/// that a set is a record when it beats everything before it, including
/// earlier sets the same day. Ties never count, so a copied set isn't one.
PrIndex computePrIndex(Iterable<SetRecordRow> rows) {
  final sorted = rows.toList()
    ..sort((a, b) {
      var c = a.dayKey.compareTo(b.dayKey);
      if (c != 0) return c;
      c = a.entryPos.compareTo(b.entryPos);
      if (c != 0) return c;
      c = a.entryId.compareTo(b.entryId);
      if (c != 0) return c;
      c = a.setPos.compareTo(b.setPos);
      return c != 0 ? c : a.setId.compareTo(b.setId);
    });

  final firstDay = <(int, PrMetric), int>{};
  final bests = <int, Map<PrMetric, PrBest>>{};
  final hits = <PrHit>[];

  for (final r in sorted) {
    for (final MapEntry(key: metric, value: v) in metricsOf(r).entries) {
      final key = (r.exerciseId, metric);
      final perEx = bests.putIfAbsent(r.exerciseId, () => {});
      final best = perEx[metric];
      final baseline = firstDay.putIfAbsent(key, () => r.dayKey);
      if (best == null || v > best.value + _eps) {
        if (best != null && r.dayKey != baseline) {
          hits.add(
            PrHit(
              setId: r.setId,
              exerciseId: r.exerciseId,
              dayKey: r.dayKey,
              metric: metric,
              value: v,
              previous: best.value,
            ),
          );
        }
        perEx[metric] = (value: v, dayKey: r.dayKey, setId: r.setId);
      }
    }
  }
  return PrIndex(hits, bests);
}

/// The heaviest weight [exerciseId] has been lifted for at least [minReps]
/// reps. A set without reps counts as a single.
({double kg, int dayKey})? bestAtReps(Iterable<SetRecordRow> rows, int exerciseId, int minReps) {
  ({double kg, int dayKey})? best;
  for (final r in rows) {
    if (r.exerciseId != exerciseId) continue;
    final w = r.weightKg;
    if (w == null || w <= 0 || (r.reps ?? 1) < minReps) continue;
    if (best == null || w > best.kg + _eps) best = (kg: w, dayKey: r.dayKey);
  }
  return best;
}

/// The first day [exerciseId] was lifted at [targetKg] or more for at least
/// [minReps] reps, or null if it hasn't been yet.
int? firstDayReaching(Iterable<SetRecordRow> rows, int exerciseId, double targetKg, int minReps) {
  int? day;
  for (final r in rows) {
    if (r.exerciseId != exerciseId) continue;
    final w = r.weightKg;
    if (w == null || w + _eps < targetKg || (r.reps ?? 1) < minReps) continue;
    if (day == null || r.dayKey < day) day = r.dayKey;
  }
  return day;
}
