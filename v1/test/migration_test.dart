import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/data/database/app_database.dart';
import 'package:gymtrx/data/repositories/session_repository.dart';

import 'generated_migrations/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in [1, 2]) {
    test('$from → 3 matches a fresh v3 schema', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 3);
      await db.close();
    });
  }

  test('1 → 3 keeps an early database’s data and adds empty new tables', () async {
    final schema = await verifier.schemaAt(1);
    final raw = schema.rawDatabase;
    // What the first schema would have held.
    raw.execute(
      "INSERT INTO muscle_groups (id, name, slug, sort_order, hidden, is_custom) VALUES (1, 'Chest', 'chest', 0, 0, 0)",
    );
    raw.execute(
      "INSERT INTO exercises (id, name, group_id, kind, hidden, is_custom) VALUES (1, 'Bench Press', 1, 0, 0, 0)",
    );
    raw.execute(
      "INSERT INTO exercises (id, name, group_id, kind, hidden, is_custom) VALUES (2, 'Squat', NULL, 0, 0, 1)",
    );
    raw.execute('INSERT INTO sessions (id, day_key, created_at, updated_at) VALUES (1, 20261001, 0, 0)');
    raw.execute('INSERT INTO session_groups (session_id, group_id) VALUES (1, 1)');
    raw.execute('INSERT INTO session_exercises (id, session_id, exercise_id, position) VALUES (1, 1, 1, 0)');
    raw.execute(
      'INSERT INTO exercise_sets (id, session_exercise_id, position, weight_kg, reps) VALUES (1, 1, 0, 80.0, 5)',
    );
    raw.execute('INSERT INTO body_weights (day_key, weight_kg, recorded_at) VALUES (20261001, 72.5, 0)');

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);

    final entry = await SessionRepository(db).loadEntry(20261001);
    expect(entry!.exercises.single.sets.single.weightKg, 80.0);
    expect(entry.session.startedAt, isNull);
    final weight = await db.select(db.bodyWeights).getSingle();
    expect(weight.weightKg, 72.5);
    expect(weight.source, isNull, reason: 'old weigh-ins were typed in GYMTRX');
    expect(await db.select(db.goals).get(), isEmpty);
    expect(await db.select(db.programDays).get(), isEmpty);
    expect(await db.select(db.progressPhotos).get(), isEmpty);
    expect(await db.select(db.sessionHealth).get(), isEmpty);
    expect(await db.select(db.dailyHealth).get(), isEmpty);

    final exercises = {for (final e in await db.select(db.exercises).get()) e.name: e};
    expect(exercises.length, 2, reason: 'the upgrade never re-seeds the library');
    expect(exercises['Bench Press']!.guideId, 'Barbell_Bench_Press_-_Medium_Grip');
    expect(exercises['Squat']!.guideId, isNull, reason: 'a custom exercise is never linked automatically');
    await db.close();
  });
}
