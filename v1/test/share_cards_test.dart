import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/core/theme/accents.dart';
import 'package:gymtrx/core/theme/app_theme.dart';
import 'package:gymtrx/core/utils/units.dart';
import 'package:gymtrx/data/database/app_database.dart';
import 'package:gymtrx/data/models/entry.dart';
import 'package:gymtrx/presentation/share/share_cards.dart';

MuscleGroup _group(int id, String slug, String name) =>
    MuscleGroup(id: id, name: name, slug: slug, sortOrder: id, hidden: false, isCustom: false);

ExerciseEntry _exercise(int id, String name, List<(double, int)> sets) => ExerciseEntry(
  row: SessionExercise(id: id, sessionId: 1, exerciseId: id, position: id),
  exercise: Exercise(id: id, name: name, kind: ExerciseKind.strength, hidden: false, isCustom: false),
  sets: [
    for (var i = 0; i < sets.length; i++)
      ExerciseSet(id: id * 10 + i, sessionExerciseId: id, position: i, weightKg: sets[i].$1, reps: sets[i].$2),
  ],
);

/// Renders a card exactly as it's captured, failing on any overflow.
Future<void> _pumpCard(WidgetTester tester, Widget card, {double textScale = 1}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildGtTheme(GtAccent.fallback.color),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: true, textScaler: TextScaler.linear(textScale)),
        child: Center(child: RepaintBoundary(child: card)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final error = tester.takeException();
  if (error is FlutterError) fail(error.toStringDeep());
  expect(error, isNull);
  expect(tester.getSize(find.byType(ShareFrame)), ShareFrame.size);
}

void main() {
  setUp(() {});

  testWidgets('a busy day fits the card', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    final entry = EntryDetail(
      session: Session(id: 1, dayKey: 20261009, durationMin: 75, createdAt: DateTime(2026), updatedAt: DateTime(2026)),
      groups: [
        _group(1, 'chest', 'Chest'),
        _group(2, 'shoulders', 'Shoulders'),
        _group(3, 'triceps', 'Triceps'),
        _group(4, 'core', 'Core'),
      ],
      exercises: [
        _exercise(1, 'Incline Dumbbell Press With A Very Long Name', [(32.5, 10), (35, 8), (37.5, 6)]),
        _exercise(2, 'Bench Press', [(85, 5), (90, 5)]),
        _exercise(3, 'Overhead Tricep Extension', [(25, 12)]),
        _exercise(4, 'Lateral Raise', [(12, 15)]),
        _exercise(5, 'Plank', []),
      ],
    );
    await _pumpCard(tester, DayShareCard(entry: entry, unit: WeightUnit.kg, prSetIds: const {21}));
    expect(find.text('+2 more'), findsOneWidget);
  });

  testWidgets('a record card fits, even with big numbers', (tester) async {
    await _pumpCard(
      tester,
      const PrShareCard(
        exercise: 'Romanian Deadlift With Pause',
        value: '1187.5 lb × 12',
        gain: '+22.5 lb',
        metric: 'heaviest',
        dayKey: 20261009,
      ),
    );
  });

  testWidgets('a streak card fits, even a long one', (tester) async {
    await _pumpCard(tester, const StreakShareCard(weeks: 104, best: 104, goal: 5, sessions: 260));
  });
}
