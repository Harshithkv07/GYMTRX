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

  /// A weigh-in typed in GYMTRX. It replaces one that came from another app.
  Future<void> upsert(int dayKey, double kg) => db
      .into(db.bodyWeights)
      .insertOnConflictUpdate(
        BodyWeightsCompanion.insert(
          dayKey: Value(dayKey),
          weightKg: kg,
          recordedAt: Value(DateTime.now()),
          source: const Value(null),
        ),
      );

  /// A weigh-in another app (a smart scale, say) wrote to Health Connect.
  /// Never replaces one typed in GYMTRX.
  Future<void> importFrom(String source, int dayKey, double kg, DateTime at) => db.transaction(() async {
    final existing = await (db.select(db.bodyWeights)..where((w) => w.dayKey.equals(dayKey))).getSingleOrNull();
    if (existing != null && existing.source == null) return;
    if (existing != null && existing.source == source && (existing.weightKg - kg).abs() < 0.001) return;
    await db
        .into(db.bodyWeights)
        .insertOnConflictUpdate(
          BodyWeightsCompanion.insert(
            dayKey: Value(dayKey),
            weightKg: kg,
            recordedAt: Value(at),
            source: Value(source),
          ),
        );
  });

  Future<void> remove(int dayKey) => (db.delete(db.bodyWeights)..where((w) => w.dayKey.equals(dayKey))).go();
}
