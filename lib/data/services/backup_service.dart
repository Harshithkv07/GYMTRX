import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// What a backup file holds, after validation.
class BackupData {
  BackupData._(this.json, {required this.entryCount, required this.weighInCount, this.firstDay, this.lastDay});

  final Map<String, Object?> json;
  final int entryCount;
  final int weighInCount;
  final int? firstDay;
  final int? lastDay;

  Map<String, Object?> get settings => (json['settings'] as Map?)?.cast<String, Object?>() ?? const {};
}

/// Versioned JSON backups. Restoring replaces everything in one transaction.
class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  static const format = 'gymtrx-backup';
  static const version = 1;

  Future<String> export({required Map<String, Object?> settings}) async {
    final groups = await db.select(db.muscleGroups).get();
    final exercises = await db.select(db.exercises).get();
    final sessions = await (db.select(db.sessions)..orderBy([(s) => OrderingTerm.asc(s.dayKey)])).get();
    final sessionGroups = await db.select(db.sessionGroups).get();
    final entries =
        await (db.select(db.sessionExercises)
              ..orderBy([(e) => OrderingTerm.asc(e.position), (e) => OrderingTerm.asc(e.id)]))
            .get();
    final sets =
        await (db.select(db.exerciseSets)..orderBy([(s) => OrderingTerm.asc(s.position), (s) => OrderingTerm.asc(s.id)]))
            .get();
    final weights = await (db.select(db.bodyWeights)..orderBy([(w) => OrderingTerm.asc(w.dayKey)])).get();

    final groupsBySession = <int, List<int>>{};
    for (final g in sessionGroups) {
      groupsBySession.putIfAbsent(g.sessionId, () => []).add(g.groupId);
    }
    final setsByEntry = <int, List<ExerciseSet>>{};
    for (final s in sets) {
      setsByEntry.putIfAbsent(s.sessionExerciseId, () => []).add(s);
    }
    final entriesBySession = <int, List<SessionExercise>>{};
    for (final e in entries) {
      entriesBySession.putIfAbsent(e.sessionId, () => []).add(e);
    }

    final json = {
      'format': format,
      'version': version,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings,
      'groups': [
        for (final g in groups)
          {
            'id': g.id,
            'name': g.name,
            'slug': g.slug,
            'sortOrder': g.sortOrder,
            'hidden': g.hidden,
            'isCustom': g.isCustom,
          },
      ],
      'exercises': [
        for (final e in exercises)
          {
            'id': e.id,
            'name': e.name,
            'groupId': e.groupId,
            'kind': e.kind.name,
            'hidden': e.hidden,
            'isCustom': e.isCustom,
          },
      ],
      'entries': [
        for (final s in sessions)
          {
            'dayKey': s.dayKey,
            'note': s.note,
            'durationMin': s.durationMin,
            'createdAt': s.createdAt.toIso8601String(),
            'updatedAt': s.updatedAt.toIso8601String(),
            'groupIds': groupsBySession[s.id] ?? const <int>[],
            'exercises': [
              for (final e in entriesBySession[s.id] ?? const <SessionExercise>[])
                {
                  'exerciseId': e.exerciseId,
                  'note': e.note,
                  'sets': [
                    for (final set in setsByEntry[e.id] ?? const <ExerciseSet>[])
                      {
                        'weightKg': set.weightKg,
                        'reps': set.reps,
                        'durationSec': set.durationSec,
                        'distanceKm': set.distanceKm,
                      },
                  ],
                },
            ],
          },
      ],
      'bodyWeights': [
        for (final w in weights) {'dayKey': w.dayKey, 'weightKg': w.weightKg},
      ],
    };
    return const JsonEncoder.withIndent(' ').convert(json);
  }

  /// Validates a backup file. Pure, so it can run in an isolate via compute().
  static BackupData parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FormatException("This file isn't a GYMTRX backup.");
    }
    if (decoded is! Map || decoded['format'] != format) {
      throw const FormatException("This file isn't a GYMTRX backup.");
    }
    final v = decoded['version'];
    if (v is! int || v > version) {
      throw const FormatException('This backup was made by a newer version of GYMTRX.');
    }
    final json = decoded.cast<String, Object?>();
    for (final key in ['groups', 'exercises', 'entries', 'bodyWeights']) {
      if (json[key] is! List) throw FormatException('The backup is missing "$key".');
    }
    final entries = (json['entries']! as List).cast<Map<String, Object?>>();
    final days = [for (final e in entries) e['dayKey']! as int]..sort();
    return BackupData._(
      json,
      entryCount: entries.length,
      weighInCount: (json['bodyWeights']! as List).length,
      firstDay: days.firstOrNull,
      lastDay: days.lastOrNull,
    );
  }

  /// Replaces all data with the backup's.
  Future<void> restore(BackupData data) => db.transaction(() async {
    final json = data.json;
    // Children first, then the library.
    for (final TableInfo<Table, dynamic> t in [
      db.exerciseSets,
      db.sessionExercises,
      db.sessionGroups,
      db.sessions,
      db.bodyWeights,
      db.exercises,
      db.muscleGroups,
    ]) {
      await db.delete(t).go();
    }

    await db.batch((b) {
      for (final g in (json['groups']! as List).cast<Map<String, Object?>>()) {
        b.insert(
          db.muscleGroups,
          MuscleGroupsCompanion.insert(
            id: Value(g['id']! as int),
            name: g['name']! as String,
            slug: Value(g['slug'] as String?),
            sortOrder: Value(g['sortOrder'] as int? ?? 0),
            hidden: Value(g['hidden'] as bool? ?? false),
            isCustom: Value(g['isCustom'] as bool? ?? false),
          ),
        );
      }
      for (final e in (json['exercises']! as List).cast<Map<String, Object?>>()) {
        b.insert(
          db.exercises,
          ExercisesCompanion.insert(
            id: Value(e['id']! as int),
            name: e['name']! as String,
            groupId: Value(e['groupId'] as int?),
            kind: ExerciseKind.values.firstWhere((k) => k.name == e['kind'], orElse: () => ExerciseKind.strength),
            hidden: Value(e['hidden'] as bool? ?? false),
            isCustom: Value(e['isCustom'] as bool? ?? false),
          ),
        );
      }
      for (final w in (json['bodyWeights']! as List).cast<Map<String, Object?>>()) {
        b.insert(
          db.bodyWeights,
          BodyWeightsCompanion.insert(dayKey: Value(w['dayKey']! as int), weightKg: (w['weightKg']! as num).toDouble()),
        );
      }
    });

    for (final e in (json['entries']! as List).cast<Map<String, Object?>>()) {
      final sid = await db
          .into(db.sessions)
          .insert(
            SessionsCompanion.insert(
              dayKey: e['dayKey']! as int,
              note: Value(e['note'] as String?),
              durationMin: Value(e['durationMin'] as int?),
              createdAt: Value(DateTime.tryParse(e['createdAt'] as String? ?? '') ?? DateTime.now()),
              updatedAt: Value(DateTime.tryParse(e['updatedAt'] as String? ?? '') ?? DateTime.now()),
            ),
          );
      await db.batch((b) {
        b.insertAll(db.sessionGroups, [
          for (final g in (e['groupIds'] as List? ?? const []).cast<int>())
            SessionGroupsCompanion.insert(sessionId: sid, groupId: g),
        ], mode: InsertMode.insertOrIgnore);
      });
      final exercises = (e['exercises'] as List? ?? const []).cast<Map<String, Object?>>();
      for (var i = 0; i < exercises.length; i++) {
        final x = exercises[i];
        final seId = await db
            .into(db.sessionExercises)
            .insert(
              SessionExercisesCompanion.insert(
                sessionId: sid,
                exerciseId: x['exerciseId']! as int,
                position: i,
                note: Value(x['note'] as String?),
              ),
            );
        final sets = (x['sets'] as List? ?? const []).cast<Map<String, Object?>>();
        await db.batch((b) {
          b.insertAll(db.exerciseSets, [
            for (var j = 0; j < sets.length; j++)
              ExerciseSetsCompanion.insert(
                sessionExerciseId: seId,
                position: j,
                weightKg: Value((sets[j]['weightKg'] as num?)?.toDouble()),
                reps: Value(sets[j]['reps'] as int?),
                durationSec: Value(sets[j]['durationSec'] as int?),
                distanceKm: Value((sets[j]['distanceKm'] as num?)?.toDouble()),
              ),
          ]);
        });
      }
    }
  });
}
