import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/core/utils/units.dart';
import 'package:gymtrx/data/database/app_database.dart';
import 'package:gymtrx/data/models/progress.dart';
import 'package:gymtrx/logic/records.dart';

var _id = 0;

SetRecordRow _s(
  int day,
  double? kg,
  int? reps, {
  int ex = 1,
  ExerciseKind kind = ExerciseKind.strength,
  int entry = 0,
  int? id,
  int? km100,
  int? sec,
}) => (
  setId: id ?? ++_id,
  exerciseId: ex,
  kind: kind,
  dayKey: day,
  entryId: day * 10 + entry,
  entryPos: entry,
  setPos: _id,
  weightKg: kg,
  reps: reps,
  durationSec: sec,
  distanceKm: km100 == null ? null : km100 / 100,
);

Set<PrMetric> _metricsOf(PrIndex idx, int setId) => {for (final h in idx.bySet[setId] ?? const <PrHit>[]) h.metric};

void main() {
  setUp(() => _id = 0);

  test('the first day is a baseline, not a record', () {
    final idx = computePrIndex([_s(20261001, 60, 8), _s(20261001, 70, 5)]);
    expect(idx.hits, isEmpty);
    expect(idx.bests[1]![PrMetric.heaviest]!.value, 70);
  });

  test('a heavier set on a later day is a record; a tie is not', () {
    final tie = _s(20261003, 70, 5);
    final heavier = _s(20261005, 72.5, 5);
    final idx = computePrIndex([_s(20261001, 70, 5), tie, heavier]);
    expect(idx.isPrSet(tie.setId), isFalse);
    expect(_metricsOf(idx, heavier.setId), {PrMetric.heaviest, PrMetric.e1rm});
    expect(idx.bySet[heavier.setId]!.first.previous, 70);
  });

  test('more reps at a lighter weight can be an est. 1RM record only', () {
    final s = _s(20261005, 90, 10);
    final idx = computePrIndex([_s(20261001, 100, 5), s]);
    expect(_metricsOf(idx, s.setId), {PrMetric.e1rm});
  });

  test('beyond 12 reps no 1RM estimate', () {
    expect(epley(50, 13), isNull);
    expect(epley(50, 1), 50);
    expect(epley(60, 10), closeTo(80, 1e-9));
  });

  test('blank and zero fields count toward nothing', () {
    final idx = computePrIndex([
      _s(20261001, 60, 5),
      _s(20261002, null, 20),
      _s(20261003, 0, 5),
      _s(20261004, 100, 0),
    ]);
    expect(idx.hits, isEmpty);
  });

  test('a weight without reps can still be the heaviest', () {
    final s = _s(20261002, 80, null);
    final idx = computePrIndex([_s(20261001, 70, 5), s]);
    expect(_metricsOf(idx, s.setId), {PrMetric.heaviest});
  });

  test('records build up within a day', () {
    final a = _s(20261002, 70, 5), b = _s(20261002, 77.5, 5), c = _s(20261002, 80, 5);
    final idx = computePrIndex([_s(20261001, 75, 5), a, b, c]);
    expect(idx.isPrSet(a.setId), isFalse);
    expect(idx.isPrSet(b.setId), isTrue);
    expect(idx.isPrSet(c.setId), isTrue);
    expect(idx.bySet[c.setId]!.firstWhere((h) => h.metric == PrMetric.heaviest).previous, 77.5);
  });

  test('a copied set (same values) is never a second record', () {
    final first = _s(20261002, 80, 5), copy = _s(20261002, 80, 5);
    final idx = computePrIndex([_s(20261001, 75, 5), first, copy]);
    expect(idx.isPrSet(first.setId), isTrue);
    expect(idx.isPrSet(copy.setId), isFalse);
  });

  test('the same exercise twice in a day follows entry order', () {
    final early = _s(20261002, 80, 5, entry: 0), late = _s(20261002, 85, 5, entry: 1);
    final idx = computePrIndex([late, _s(20261001, 75, 5), early]);
    expect(idx.isPrSet(early.setId), isTrue);
    expect(idx.isPrSet(late.setId), isTrue);
  });

  test('editing an earlier day removes a later record', () {
    final later = _s(20261005, 80, 5);
    final before = computePrIndex([_s(20261001, 75, 5), later]);
    expect(before.isPrSet(later.setId), isTrue);
    final after = computePrIndex([_s(20261001, 75, 5), _s(20261003, 90, 5), later]);
    expect(after.isPrSet(later.setId), isFalse);
  });

  test('exercises are tracked separately', () {
    final s = _s(20261002, 50, 5, ex: 2);
    final idx = computePrIndex([_s(20261001, 100, 5), _s(20261001, 40, 5, ex: 2), s]);
    expect(idx.isPrSet(s.setId), isTrue);
  });

  test('a value entered in lb compares exactly against the same lb value', () {
    final kg = Units.toKg(135, WeightUnit.lb);
    final again = _s(20261002, Units.toKg(135, WeightUnit.lb), 5);
    final idx = computePrIndex([_s(20261001, kg, 5), again]);
    expect(idx.isPrSet(again.setId), isFalse);
  });

  test('bodyweight, cardio and timed records', () {
    final reps = _s(20261002, null, 15, ex: 2, kind: ExerciseKind.bodyweight);
    final run = _s(20261002, null, null, ex: 3, kind: ExerciseKind.cardio, km100: 520, sec: 1500);
    final plank = _s(20261002, null, null, ex: 4, kind: ExerciseKind.timed, sec: 95);
    final idx = computePrIndex([
      _s(20261001, null, 12, ex: 2, kind: ExerciseKind.bodyweight),
      _s(20261001, null, null, ex: 3, kind: ExerciseKind.cardio, km100: 500, sec: 1800),
      _s(20261001, null, null, ex: 4, kind: ExerciseKind.timed, sec: 60),
      reps,
      run,
      plank,
    ]);
    expect(_metricsOf(idx, reps.setId), {PrMetric.reps});
    expect(_metricsOf(idx, run.setId), {PrMetric.distance}, reason: 'shorter time is not a record');
    expect(_metricsOf(idx, plank.setId), {PrMetric.duration});
  });

  test('recent groups by day and exercise, newest first, with a headline', () {
    final idx = computePrIndex([
      _s(20261001, 70, 5),
      _s(20261001, 40, 5, ex: 2),
      _s(20261003, 75, 5),
      _s(20261004, 45, 5, ex: 2),
    ]);
    final recent = idx.recent();
    expect([for (final r in recent) (r.dayKey, r.exerciseId)], [(20261004, 2), (20261003, 1)]);
    expect(recent.last.headline.metric, PrMetric.heaviest);
    expect(idx.prExercisesOn(20261003), {1});
  });

  test('best at reps and first day reaching a target', () {
    final rows = [_s(20261001, 80, 3), _s(20261002, 75, 6), _s(20261004, 82.5, 5), _s(20261005, 90, null)];
    expect(bestAtReps(rows, 1, 5), (kg: 82.5, dayKey: 20261004));
    expect(bestAtReps(rows, 1, 1), (kg: 90.0, dayKey: 20261005));
    expect(firstDayReaching(rows, 1, 80, 5), 20261004);
    expect(firstDayReaching(rows, 1, 100, 1), isNull);
  });

  test('50k sets compute quickly', () {
    final rows = [
      for (var i = 0; i < 50000; i++)
        _s(20200101 + (i ~/ 25), 40 + (i % 97) * 0.5, 1 + i % 15, ex: i % 40),
    ];
    final sw = Stopwatch()..start();
    computePrIndex(rows);
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(400));
  });
}
