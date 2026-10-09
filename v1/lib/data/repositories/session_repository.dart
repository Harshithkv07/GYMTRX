import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/entry.dart';

/// Reads and writes day entries. Every write lands immediately: the log sheet
/// saves as you go, and Drift's streams push the change to every screen.
class SessionRepository {
  SessionRepository(this.db);

  final AppDatabase db;

  // ---------------------------------------------------------------- reading

  /// Every entry, newest first. Years of use stay small enough to hold in memory.
  Stream<List<EntrySummary>> watchSummaries() {
    return db
        .customSelect(
          'SELECT s.id, s.day_key, s.duration_min, '
          "(s.note IS NOT NULL AND TRIM(s.note) <> '') AS has_note, "
          '(SELECT GROUP_CONCAT(sg.group_id) FROM session_groups sg WHERE sg.session_id = s.id) AS group_ids, '
          '(SELECT COUNT(*) FROM session_exercises se WHERE se.session_id = s.id) AS exercise_count '
          'FROM sessions s ORDER BY s.day_key DESC',
          readsFrom: {db.sessions, db.sessionGroups, db.sessionExercises},
        )
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              EntrySummary(
                sessionId: r.read<int>('id'),
                dayKey: r.read<int>('day_key'),
                durationMin: r.readNullable<int>('duration_min'),
                hasNote: r.read<int>('has_note') == 1,
                groupIds: _parseIds(r.readNullable<String>('group_ids')),
                exerciseCount: r.read<int>('exercise_count'),
              ),
          ],
        );
  }

  static List<int> _parseIds(String? csv) =>
      csv == null || csv.isEmpty ? const [] : [for (final s in csv.split(',')) int.parse(s)];

  /// The full entry for [dayKey], re-emitted whenever anything it shows changes.
  Stream<EntryDetail?> watchEntry(int dayKey) async* {
    yield await loadEntry(dayKey);
    await for (final _ in db.tableUpdates(TableUpdateQuery.onAllTables(db.entryTables))) {
      yield await loadEntry(dayKey);
    }
  }

  Future<Session?> _session(int dayKey) =>
      (db.select(db.sessions)..where((s) => s.dayKey.equals(dayKey))).getSingleOrNull();

  Future<EntryDetail?> loadEntry(int dayKey) async {
    final session = await _session(dayKey);
    if (session == null) return null;

    final groups =
        await (db.select(db.muscleGroups).join([
                innerJoin(db.sessionGroups, db.sessionGroups.groupId.equalsExp(db.muscleGroups.id)),
              ])
              ..where(db.sessionGroups.sessionId.equals(session.id))
              ..orderBy([OrderingTerm.asc(db.muscleGroups.sortOrder)]))
            .map((r) => r.readTable(db.muscleGroups))
            .get();

    final rows =
        await (db.select(db.sessionExercises).join([
                innerJoin(db.exercises, db.exercises.id.equalsExp(db.sessionExercises.exerciseId)),
              ])
              ..where(db.sessionExercises.sessionId.equals(session.id))
              ..orderBy([OrderingTerm.asc(db.sessionExercises.position), OrderingTerm.asc(db.sessionExercises.id)]))
            .get();

    final setsByEntry = await _setsFor([for (final r in rows) r.readTable(db.sessionExercises).id]);

    return EntryDetail(
      session: session,
      groups: groups,
      exercises: [
        for (final r in rows)
          ExerciseEntry(
            row: r.readTable(db.sessionExercises),
            exercise: r.readTable(db.exercises),
            sets: setsByEntry[r.readTable(db.sessionExercises).id] ?? const [],
          ),
      ],
    );
  }

  Future<Map<int, List<ExerciseSet>>> _setsFor(List<int> sessionExerciseIds) async {
    if (sessionExerciseIds.isEmpty) return const {};
    final sets =
        await (db.select(db.exerciseSets)
              ..where((s) => s.sessionExerciseId.isIn(sessionExerciseIds))
              ..orderBy([(s) => OrderingTerm.asc(s.position), (s) => OrderingTerm.asc(s.id)]))
            .get();
    final map = <int, List<ExerciseSet>>{};
    for (final s in sets) {
      map.putIfAbsent(s.sessionExerciseId, () => []).add(s);
    }
    return map;
  }

  /// How many entries each exercise appears in; ranks suggestions.
  Future<Map<int, int>> exerciseUsageCounts() async {
    final rows = await db
        .customSelect('SELECT exercise_id, COUNT(*) AS c FROM session_exercises GROUP BY exercise_id')
        .get();
    return {for (final r in rows) r.read<int>('exercise_id'): r.read<int>('c')};
  }

  /// The latest day before [beforeDayKey] on which [exerciseId] has sets.
  Future<LastPerformance?> lastPerformance(int exerciseId, int beforeDayKey) async {
    final row = await db
        .customSelect(
          'SELECT se.id, s.day_key FROM session_exercises se '
          'JOIN sessions s ON s.id = se.session_id '
          'WHERE se.exercise_id = ? AND s.day_key < ? '
          'AND EXISTS (SELECT 1 FROM exercise_sets es WHERE es.session_exercise_id = se.id) '
          'ORDER BY s.day_key DESC LIMIT 1',
          variables: [Variable.withInt(exerciseId), Variable.withInt(beforeDayKey)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    final id = row.read<int>('id');
    final sets = await _setsFor([id]);
    return (dayKey: row.read<int>('day_key'), sets: sets[id] ?? const <ExerciseSet>[]);
  }

  /// Per-exercise usage, most recently done first.
  Stream<List<({int exerciseId, int count, int lastDayKey})>> watchExerciseUsage() {
    return db
        .customSelect(
          'SELECT se.exercise_id, COUNT(*) AS c, MAX(s.day_key) AS last FROM session_exercises se '
          'JOIN sessions s ON s.id = se.session_id GROUP BY se.exercise_id ORDER BY last DESC',
          readsFrom: {db.sessions, db.sessionExercises},
        )
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              (exerciseId: r.read<int>('exercise_id'), count: r.read<int>('c'), lastDayKey: r.read<int>('last')),
          ],
        );
  }

  /// Every day [exerciseId] was logged, newest first.
  Stream<List<ExerciseHistoryItem>> watchExerciseHistory(int exerciseId) async* {
    yield await _exerciseHistory(exerciseId);
    await for (final _ in db.tableUpdates(TableUpdateQuery.onAllTables(db.entryTables))) {
      yield await _exerciseHistory(exerciseId);
    }
  }

  Future<List<ExerciseHistoryItem>> _exerciseHistory(int exerciseId) async {
    final rows = await db
        .customSelect(
          'SELECT se.id, se.note, s.day_key FROM session_exercises se '
          'JOIN sessions s ON s.id = se.session_id WHERE se.exercise_id = ? '
          'ORDER BY s.day_key DESC, se.position ASC',
          variables: [Variable.withInt(exerciseId)],
        )
        .get();
    final sets = await _setsFor([for (final r in rows) r.read<int>('id')]);
    return [
      for (final r in rows)
        ExerciseHistoryItem(
          dayKey: r.read<int>('day_key'),
          note: r.readNullable<String>('note'),
          sets: sets[r.read<int>('id')] ?? const [],
        ),
    ];
  }

  // ---------------------------------------------------------------- writing

  /// Returns the id of [dayKey]'s session, creating an empty one if needed.
  Future<int> ensureSession(int dayKey) async {
    final existing = await _session(dayKey);
    if (existing != null) return existing.id;
    return db.into(db.sessions).insert(SessionsCompanion.insert(dayKey: dayKey));
  }

  Future<void> _touch(int sessionId) => (db.update(db.sessions)..where((s) => s.id.equals(sessionId)))
      .write(SessionsCompanion(updatedAt: Value(DateTime.now())));

  Future<void> setGroupSelected(int dayKey, int groupId, bool selected) => db.transaction(() async {
    final sid = await ensureSession(dayKey);
    if (selected) {
      await db
          .into(db.sessionGroups)
          .insert(SessionGroupsCompanion.insert(sessionId: sid, groupId: groupId), mode: InsertMode.insertOrIgnore);
    } else {
      await (db.delete(db.sessionGroups)..where((g) => g.sessionId.equals(sid) & g.groupId.equals(groupId))).go();
    }
    await _touch(sid);
  });

  /// Replaces the day's groups in one go (used by "recent combo" chips).
  Future<void> setGroups(int dayKey, Iterable<int> groupIds) => db.transaction(() async {
    final sid = await ensureSession(dayKey);
    await (db.delete(db.sessionGroups)..where((g) => g.sessionId.equals(sid))).go();
    await db.batch((b) {
      b.insertAll(db.sessionGroups, [
        for (final id in groupIds) SessionGroupsCompanion.insert(sessionId: sid, groupId: id),
      ], mode: InsertMode.insertOrIgnore);
    });
    await _touch(sid);
  });

  Future<void> setNote(int dayKey, String? note) => db.transaction(() async {
    final sid = await ensureSession(dayKey);
    final trimmed = note?.trim();
    await (db.update(db.sessions)..where((s) => s.id.equals(sid))).write(
      SessionsCompanion(
        note: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  });

  Future<void> setDuration(int dayKey, int? minutes) => db.transaction(() async {
    final sid = await ensureSession(dayKey);
    await (db.update(db.sessions)..where((s) => s.id.equals(sid))).write(
      SessionsCompanion(
        durationMin: Value(minutes == null || minutes <= 0 ? null : minutes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  });

  Future<int> addExercise(int dayKey, int exerciseId) => db.transaction(() async {
    final sid = await ensureSession(dayKey);
    final next = await db
        .customSelect(
          'SELECT COALESCE(MAX(position), -1) + 1 AS p FROM session_exercises WHERE session_id = ?',
          variables: [Variable.withInt(sid)],
        )
        .getSingle();
    final id = await db
        .into(db.sessionExercises)
        .insert(
          SessionExercisesCompanion.insert(sessionId: sid, exerciseId: exerciseId, position: next.read<int>('p')),
        );
    await _touch(sid);
    return id;
  });

  Future<void> removeExercise(int sessionExerciseId) =>
      (db.delete(db.sessionExercises)..where((e) => e.id.equals(sessionExerciseId))).go();

  /// Restores a removed exercise row (with its sets) for undo.
  Future<void> restoreExercise(int dayKey, ExerciseEntry entry) => db.transaction(() async {
    final sid = await ensureSession(dayKey);
    final id = await db
        .into(db.sessionExercises)
        .insert(
          SessionExercisesCompanion.insert(
            sessionId: sid,
            exerciseId: entry.exercise.id,
            position: entry.row.position,
            note: Value(entry.row.note),
          ),
        );
    await _insertSets(id, entry.sets);
  });

  Future<void> reorderExercises(List<int> sessionExerciseIdsInOrder) => db.batch((b) {
    for (var i = 0; i < sessionExerciseIdsInOrder.length; i++) {
      b.update(
        db.sessionExercises,
        SessionExercisesCompanion(position: Value(i)),
        where: (e) => e.id.equals(sessionExerciseIdsInOrder[i]),
      );
    }
  });

  Future<void> setExerciseNote(int sessionExerciseId, String? note) {
    final trimmed = note?.trim();
    return (db.update(db.sessionExercises)..where((e) => e.id.equals(sessionExerciseId))).write(
      SessionExercisesCompanion(note: Value(trimmed == null || trimmed.isEmpty ? null : trimmed)),
    );
  }

  /// Adds a set, copying the previous set's values so repeating is one tap.
  Future<int> addSet(int sessionExerciseId) => db.transaction(() async {
    final previous =
        await (db.select(db.exerciseSets)
              ..where((s) => s.sessionExerciseId.equals(sessionExerciseId))
              ..orderBy([(s) => OrderingTerm.desc(s.position)])
              ..limit(1))
            .getSingleOrNull();
    return db
        .into(db.exerciseSets)
        .insert(
          ExerciseSetsCompanion.insert(
            sessionExerciseId: sessionExerciseId,
            position: (previous?.position ?? -1) + 1,
            weightKg: Value(previous?.weightKg),
            reps: Value(previous?.reps),
            durationSec: Value(previous?.durationSec),
            distanceKm: Value(previous?.distanceKm),
          ),
        );
  });

  Future<void> updateSet(int setId, ExerciseSetsCompanion values) =>
      (db.update(db.exerciseSets)..where((s) => s.id.equals(setId))).write(values);

  Future<void> removeSet(int setId) => (db.delete(db.exerciseSets)..where((s) => s.id.equals(setId))).go();

  Future<void> _insertSets(int sessionExerciseId, List<ExerciseSet> sets) => db.batch((b) {
    b.insertAll(db.exerciseSets, [
      for (var i = 0; i < sets.length; i++)
        ExerciseSetsCompanion.insert(
          sessionExerciseId: sessionExerciseId,
          position: i,
          weightKg: Value(sets[i].weightKg),
          reps: Value(sets[i].reps),
          durationSec: Value(sets[i].durationSec),
          distanceKm: Value(sets[i].distanceKm),
        ),
    ]);
  });

  /// Removes [dayKey]'s session when nothing is recorded in it. Returns true if removed.
  Future<bool> pruneIfEmpty(int dayKey) => db.transaction(() async {
    final s = await _session(dayKey);
    if (s == null) return false;
    if ((s.note ?? '').trim().isNotEmpty || s.durationMin != null) return false;
    final counts = await db
        .customSelect(
          'SELECT (SELECT COUNT(*) FROM session_groups WHERE session_id = ?1) AS g, '
          '(SELECT COUNT(*) FROM session_exercises WHERE session_id = ?1) AS e',
          variables: [Variable.withInt(s.id)],
        )
        .getSingle();
    if (counts.read<int>('g') > 0 || counts.read<int>('e') > 0) return false;
    await (db.delete(db.sessions)..where((x) => x.id.equals(s.id))).go();
    return true;
  });

  /// Deletes the whole entry and returns what's needed to undo it.
  Future<EntrySnapshot?> deleteEntry(int dayKey) => db.transaction(() async {
    final detail = await loadEntry(dayKey);
    if (detail == null) return null;
    await (db.delete(db.sessions)..where((s) => s.id.equals(detail.session.id))).go();
    return EntrySnapshot.of(detail);
  });

  Future<void> restoreEntry(EntrySnapshot snap) => db.transaction(() async {
    // Anything written to that day since the delete gives way to the restored entry.
    await (db.delete(db.sessions)..where((s) => s.dayKey.equals(snap.dayKey))).go();
    final sid = await db
        .into(db.sessions)
        .insert(
          SessionsCompanion.insert(
            dayKey: snap.dayKey,
            note: Value(snap.note),
            durationMin: Value(snap.durationMin),
            createdAt: Value(snap.createdAt),
          ),
        );
    await db.batch((b) {
      b.insertAll(db.sessionGroups, [
        for (final g in snap.groupIds) SessionGroupsCompanion.insert(sessionId: sid, groupId: g),
      ], mode: InsertMode.insertOrIgnore);
    });
    for (var i = 0; i < snap.exercises.length; i++) {
      final e = snap.exercises[i];
      final seId = await db
          .into(db.sessionExercises)
          .insert(
            SessionExercisesCompanion.insert(sessionId: sid, exerciseId: e.exerciseId, position: i, note: Value(e.note)),
          );
      await _insertSets(seId, e.sets);
    }
  });
}
