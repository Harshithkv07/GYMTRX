import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Weigh-ins, one per day, stored in kilograms.
class BodyWeightRepository {
  BodyWeightRepository(this.db);

  final AppDatabase db;

  /// Oldest first, ready for charting.
  Stream<List<BodyWeight>> watchAll() =>
      (db.select(db.bodyWeights)..orderBy([(w) => OrderingTerm.asc(w.dayKey)])).watch();

  Future<BodyWeight?> latestOnOrBefore(int dayKey) =>
      (db.select(db.bodyWeights)
            ..where((w) => w.dayKey.isSmallerOrEqualValue(dayKey))
            ..orderBy([(w) => OrderingTerm.desc(w.dayKey)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsert(int dayKey, double kg) => db
      .into(db.bodyWeights)
      .insertOnConflictUpdate(
        BodyWeightsCompanion.insert(dayKey: Value(dayKey), weightKg: kg, recordedAt: Value(DateTime.now())),
      );

  Future<void> remove(int dayKey) => (db.delete(db.bodyWeights)..where((w) => w.dayKey.equals(dayKey))).go();
}
