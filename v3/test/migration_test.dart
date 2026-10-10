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

  test('1 → 2 matches a fresh v2 schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('1 → 2 keeps a 1.0/2.0 phone’s data and adds empty new tables', () async {
    final schema = await verifier.schemaAt(1);
    final raw = schema.rawDatabase;
    // What GYMTRX 1.0 or 2.0 would have written.
    raw.execute("INSERT INTO muscle_groups (id, name, slug, sort_order, hidden, is_custom) VALUES (1, 'Chest', 'chest', 0, 0, 0)");
    raw.execute("INSERT INTO exercises (id, name, group_id, kind, hidden, is_custom) VALUES (1, 'Bench Press', 1, 0, 0, 0)");
    raw.execute('INSERT INTO sessions (id, day_key, created_at, updated_at) VALUES (1, 20261001, 0, 0)');
    raw.execute('INSERT INTO session_groups (session_id, group_id) VALUES (1, 1)');
    raw.execute('INSERT INTO session_exercises (id, session_id, exercise_id, position) VALUES (1, 1, 1, 0)');
    raw.execute('INSERT INTO exercise_sets (id, session_exercise_id, position, weight_kg, reps) VALUES (1, 1, 0, 80.0, 5)');
    raw.execute('INSERT INTO body_weights (day_key, weight_kg, recorded_at) VALUES (20261001, 72.5, 0)');

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);

    final entry = await SessionRepository(db).loadEntry(20261001);
    expect(entry!.exercises.single.sets.single.weightKg, 80.0);
    expect((await db.select(db.bodyWeights).getSingle()).weightKg, 72.5);
    expect(await db.select(db.goals).get(), isEmpty);
    expect(await db.select(db.programDays).get(), isEmpty);
    expect(await db.select(db.progressPhotos).get(), isEmpty);
    expect(
      (await db.select(db.exercises).get()).length,
      1,
      reason: 'the upgrade never re-seeds the library',
    );
    await db.close();
  });
}
