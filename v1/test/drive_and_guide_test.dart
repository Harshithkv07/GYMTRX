import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/data/database/tables.dart' show ExerciseKind;
import 'package:gymtrx/data/services/guide_service.dart';
import 'package:gymtrx/logic/drive_plan.dart';
import 'package:gymtrx/logic/guide_mapping.dart';

void main() {
  group('Drive pruning', () {
    DateTime day(int d) => DateTime(2026, 10, d);
    final snapshots = [for (var d = 1; d <= 9; d++) (id: 's$d', createdAt: day(d))];

    test('keeps the newest seven snapshots', () {
      final plan = planDrivePrune(snapshots: snapshots, photos: const [], onPhone: const {}, keep: 7);
      expect(plan.deleteSnapshots, unorderedEquals(['s1', 's2']));
    });

    test('a photo goes only once every kept snapshot was taken without it', () {
      final plan = planDrivePrune(
        snapshots: snapshots,
        photos: [
          (id: 'p-keep', name: 'a.jpg', goneSince: null), // still on the phone
          (id: 'p-new-gone', name: 'b.jpg', goneSince: null), // just deleted on the phone
          (id: 'p-recent', name: 'c.jpg', goneSince: day(5)), // older kept snapshots still have it
          (id: 'p-old', name: 'd.jpg', goneSince: day(2)), // before the oldest kept (3 Oct)
          (id: 'p-back', name: 'e.jpg', goneSince: day(4)), // restored onto the phone
        ],
        onPhone: const {'a.jpg', 'e.jpg'},
        keep: 7,
      );
      expect(plan.deletePhotos, ['p-old']);
      expect(plan.markGone, ['p-new-gone']);
      expect(plan.unmarkGone, ['p-back']);
    });

    test('the fingerprint ignores when a backup was made', () {
      final a = jsonEncode({
        'format': 'gymtrx-backup',
        'exportedAt': '2026-10-10T10:00',
        'entries': [1],
      });
      final b = jsonEncode({
        'format': 'gymtrx-backup',
        'exportedAt': '2026-10-11T09:00',
        'entries': [1],
      });
      final c = jsonEncode({
        'format': 'gymtrx-backup',
        'exportedAt': '2026-10-11T09:00',
        'entries': [1, 2],
      });
      expect(backupFingerprint(a), backupFingerprint(b));
      expect(backupFingerprint(a), isNot(backupFingerprint(c)));
    });
  });

  group('exercise guide', () {
    final catalog = GuideService.parse(
      jsonEncode([
        {
          'id': 'Barbell_Bench_Press_-_Medium_Grip',
          'name': 'Barbell Bench Press - Medium Grip',
          'category': 'strength',
          'equipment': 'barbell',
          'primaryMuscles': ['chest'],
          'secondaryMuscles': ['shoulders', 'triceps'],
          'instructions': ['Lie back.', 'Press.'],
          'images': ['Barbell_Bench_Press_-_Medium_Grip/0.jpg', 'Barbell_Bench_Press_-_Medium_Grip/1.jpg'],
        },
        {
          'id': 'Pushups',
          'name': 'Pushups',
          'category': 'strength',
          'equipment': 'body only',
          'primaryMuscles': ['chest'],
          'secondaryMuscles': [],
          'instructions': [],
          'images': [],
        },
        {
          'id': 'Running_Treadmill',
          'name': 'Running, Treadmill',
          'category': 'cardio',
          'equipment': 'machine',
          'primaryMuscles': ['quadriceps'],
          'secondaryMuscles': [],
          'instructions': [],
          'images': [],
        },
        {'name': 'no id: skipped'},
      ]),
    );

    test('parses entries and skips broken ones', () {
      expect(catalog.keys, ['Barbell_Bench_Press_-_Medium_Grip', 'Pushups', 'Running_Treadmill']);
      expect(catalog['Pushups']!.secondaryMuscles, isEmpty);
    });

    test('maps to groups, kinds and body-map regions', () {
      final bench = catalog['Barbell_Bench_Press_-_Medium_Grip']!;
      expect(guideGroupSlug(bench), 'chest');
      expect(guideKind(bench), ExerciseKind.strength);
      expect(guideKind(catalog['Pushups']!), ExerciseKind.bodyweight);
      expect(guideKind(catalog['Running_Treadmill']!), ExerciseKind.cardio);
      expect(guideGroupSlug(catalog['Running_Treadmill']!), 'cardio');
      expect(guideBodyMap(bench), {'chest': 1.0, 'deltoids': 0.35, 'triceps': 0.35});
    });

    test('name matching finds the obvious one first', () {
      expect(guideMatches('Bench Press', catalog.values).first.id, 'Barbell_Bench_Press_-_Medium_Grip');
      expect(guideMatches('Push-up', catalog.values).first.id, 'Pushups');
      expect(guideMatches('Treadmill', catalog.values).first.id, 'Running_Treadmill');
      expect(guideMatches('Zercher carry', catalog.values), isEmpty);
    });
  });
}
