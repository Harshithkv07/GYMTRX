import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// The Health Connect numbers GYMTRX keeps: steps and sleep per day, and
/// watch stats per session. A cache: Health Connect stays the source.
class HealthRepository {
  HealthRepository(this.db);

  final AppDatabase db;

  Stream<Map<int, DailyHealthData>> watchDaily() =>
      db.select(db.dailyHealth).watch().map((rows) => {for (final r in rows) r.dayKey: r});

  /// Writes what was read for a range of days. A day missing from [steps]
  /// had none; [sleep] is only written when it was read.
  Future<void> putDaily({required Map<int, int> steps, Map<int, int>? sleep, required Iterable<int> days}) =>
      db.batch((b) {
        for (final day in days) {
          b.insert(
            db.dailyHealth,
            DailyHealthCompanion.insert(
              dayKey: Value(day),
              steps: Value(steps[day]),
              sleepMin: sleep == null ? const Value.absent() : Value(sleep[day]),
              fetchedAt: Value(DateTime.now()),
            ),
            onConflict: DoUpdate(
              (_) => DailyHealthCompanion(
                steps: Value(steps[day]),
                sleepMin: sleep == null ? const Value.absent() : Value(sleep[day]),
                fetchedAt: Value(DateTime.now()),
              ),
            ),
          );
        }
      });

  Stream<SessionHealthData?> watchSession(int sessionId) =>
      (db.select(db.sessionHealth)..where((h) => h.sessionId.equals(sessionId))).watchSingleOrNull();

  Future<Map<int, SessionHealthData>> sessionsById() async => {
    for (final h in await db.select(db.sessionHealth).get()) h.sessionId: h,
  };

  Future<void> putSession(SessionHealthCompanion row) => db.into(db.sessionHealth).insertOnConflictUpdate(row);

  Future<void> removeSession(int sessionId) =>
      (db.delete(db.sessionHealth)..where((h) => h.sessionId.equals(sessionId))).go();

  /// Forgets everything read from Health Connect (on disconnect). Weigh-ins
  /// that came from it stay: they're part of the log now.
  Future<void> clear() async {
    await db.delete(db.dailyHealth).go();
    await db.delete(db.sessionHealth).go();
  }
}
