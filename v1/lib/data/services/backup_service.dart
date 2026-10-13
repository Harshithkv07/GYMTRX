import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/progress.dart';
import '../repositories/program_repository.dart';
import 'photo_store.dart';

/// What a backup file holds, after validation.
class BackupData {
  BackupData._(
    this.json, {
    required this.entryCount,
    required this.weighInCount,
    this.firstDay,
    this.lastDay,
    this.photoCount,
    this.goalCount,
    this.programDays,
    this.stagingDir,
  });

  final Map<String, Object?> json;
  final int entryCount;
  final int weighInCount;
  final int? firstDay;
  final int? lastDay;

  /// Null when the file has none of that kind of data (older backups, or a
  /// plain JSON without photos): what's on the phone is then kept.
  final int? photoCount;
  final int? goalCount;
  final int? programDays;

  /// Where a ZIP's photos were unpacked, ready to be swapped in.
  final String? stagingDir;

  Map<String, Object?> get settings => (json['settings'] as Map?)?.cast<String, Object?>() ?? const {};
}

/// Input for [BackupService.parseFile], which runs in an isolate.
typedef BackupParseRequest = ({String path, String stagingDir});

/// Input for [BackupService.writeArchive], which runs in an isolate.
typedef BackupArchiveRequest = ({String json, List<(String, String)> photos, String outPath});

/// Versioned backups. Since version 2 a file is a ZIP: `backup.json` plus
/// `photos/`. Version 3 adds start times, guide links, weigh-in sources and
/// the cached Health Connect numbers. Plain JSON files (version 1, from the
/// earliest builds) still import. Restoring replaces everything in one
/// transaction.
class BackupService {
  BackupService(this.db, {this.photos});

  final AppDatabase db;
  final PhotoStore? photos;

  static const format = 'gymtrx-backup';
  static const version = 3;
  static const jsonName = 'backup.json';
  static final _photoEntry = RegExp(r'^photos/([A-Za-z0-9._-]+)$');

  Future<String> export({required Map<String, Object?> settings}) async {
    final groups = await db.select(db.muscleGroups).get();
    final exercises = await db.select(db.exercises).get();
    final sessions = await (db.select(db.sessions)..orderBy([(s) => OrderingTerm.asc(s.dayKey)])).get();
    final sessionGroups = await db.select(db.sessionGroups).get();
    final entries = await (db.select(
      db.sessionExercises,
    )..orderBy([(e) => OrderingTerm.asc(e.position), (e) => OrderingTerm.asc(e.id)])).get();
    final sets = await (db.select(
      db.exerciseSets,
    )..orderBy([(s) => OrderingTerm.asc(s.position), (s) => OrderingTerm.asc(s.id)])).get();
    final weights = await (db.select(db.bodyWeights)..orderBy([(w) => OrderingTerm.asc(w.dayKey)])).get();
    final goals = await (db.select(
      db.goals,
    )..orderBy([(g) => OrderingTerm.asc(g.sortOrder), (g) => OrderingTerm.asc(g.id)])).get();
    final program = await ProgramRepository(db).loadProgram();
    final photoRows = await (db.select(
      db.progressPhotos,
    )..orderBy([(p) => OrderingTerm.asc(p.dayKey), (p) => OrderingTerm.asc(p.id)])).get();
    final healthBySession = {for (final h in await db.select(db.sessionHealth).get()) h.sessionId: h};
    final daily = await (db.select(db.dailyHealth)..orderBy([(d) => OrderingTerm.asc(d.dayKey)])).get();

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
            'guideId': e.guideId,
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
            'startedAt': s.startedAt?.toIso8601String(),
            if (healthBySession[s.id] case final h?)
              'health': {
                'startAt': h.startAt.toIso8601String(),
                'endAt': h.endAt.toIso8601String(),
                'avgHr': h.avgHr,
                'maxHr': h.maxHr,
                'activeKcal': h.activeKcal,
                'source': h.source,
              },
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
        for (final w in weights) {'dayKey': w.dayKey, 'weightKg': w.weightKg, 'source': w.source},
      ],
      'goals': [
        for (final g in goals)
          {
            'kind': g.kind.name,
            'exerciseId': g.exerciseId,
            'targetKg': g.targetKg,
            'targetReps': g.targetReps,
            'startKg': g.startKg,
            'createdDayKey': g.createdDayKey,
            'createdAt': g.createdAt.toIso8601String(),
            'achievedDayKey': g.achievedDayKey,
            'sortOrder': g.sortOrder,
          },
      ],
      'program': [
        for (final d in program.values)
          {'weekday': d.weekday, 'label': d.label, 'groupIds': d.groupIds, 'exerciseIds': d.exerciseIds},
      ],
      'photos': [
        for (final p in photoRows)
          {'dayKey': p.dayKey, 'fileName': p.fileName, 'note': p.note, 'createdAt': p.createdAt.toIso8601String()},
      ],
      'dailyHealth': [
        for (final d in daily) {'dayKey': d.dayKey, 'steps': d.steps, 'sleepMin': d.sleepMin},
      ],
    };
    return const JsonEncoder.withIndent(' ').convert(json);
  }

  /// Every photo as `(absolute path, file name)`, for [writeArchive].
  Future<List<(String, String)>> photoFiles() async {
    final store = photos;
    if (store == null) return const [];
    final rows = await db.select(db.progressPhotos).get();
    return [for (final p in rows) (store.file(p.fileName).path, p.fileName)];
  }

  /// Writes the ZIP. Photos are stored, not compressed: JPEGs don't shrink.
  static Future<void> writeArchive(BackupArchiveRequest r) async {
    final enc = ZipFileEncoder()..create(r.outPath, level: ZipFileEncoder.store);
    enc.addArchiveFile(ArchiveFile.string(jsonName, r.json));
    for (final (path, name) in r.photos) {
      final f = File(path);
      if (f.existsSync()) enc.addFileSync(f, 'photos/$name', ZipFileEncoder.store);
    }
    await enc.close();
  }

  /// Reads a backup from disk: a ZIP (its photos unpacked into
  /// `r.stagingDir`) or a plain JSON file. Tells them apart by content, not
  /// by name. Runs in an isolate via compute().
  static Future<BackupData> parseFile(BackupParseRequest r) async {
    final raf = await File(r.path).open();
    final head = await raf.read(2);
    await raf.close();
    if (head.length < 2 || head[0] != 0x50 || head[1] != 0x4B) {
      return parse(await File(r.path).readAsString());
    }

    final input = InputFileStream(r.path);
    try {
      final Archive archive;
      try {
        archive = ZipDecoder().decodeStream(input);
      } on Object {
        throw const FormatException("This file isn't a GYMTRX backup.");
      }
      final jsonBytes = archive.findFile(jsonName)?.readBytes();
      if (jsonBytes == null) throw const FormatException("This file isn't a GYMTRX backup.");
      final text = utf8.decode(jsonBytes);

      final staging = Directory(r.stagingDir);
      if (staging.existsSync()) staging.deleteSync(recursive: true);
      staging.createSync(recursive: true);
      final names = <String>{};
      for (final f in archive.files) {
        if (!f.isFile) continue;
        // Only plain names under photos/: nothing can be written outside staging.
        final name = _photoEntry.firstMatch(f.name)?.group(1);
        if (name == null || name.startsWith('.')) continue;
        final out = OutputFileStream('${staging.path}/$name');
        f.writeContent(out);
        out.closeSync();
        names.add(name);
      }
      return parse(text, photoFiles: names, stagingDir: staging.path);
    } finally {
      input.closeSync();
    }
  }

  /// Validates backup JSON. [photoFiles] are the images that came with it;
  /// photo rows without their image are dropped. A plain JSON never carries
  /// photos, so the phone's photos are kept.
  static BackupData parse(String text, {Set<String>? photoFiles, String? stagingDir}) {
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

    if (photoFiles == null) {
      json.remove('photos');
    } else {
      json['photos'] = [
        for (final p in (json['photos'] as List? ?? const []).cast<Map<String, Object?>>())
          if (photoFiles.contains(p['fileName'])) p,
      ];
    }

    final entries = (json['entries']! as List).cast<Map<String, Object?>>();
    final days = [for (final e in entries) e['dayKey']! as int]..sort();
    return BackupData._(
      json,
      entryCount: entries.length,
      weighInCount: (json['bodyWeights']! as List).length,
      firstDay: days.firstOrNull,
      lastDay: days.lastOrNull,
      photoCount: (json['photos'] as List?)?.length,
      goalCount: (json['goals'] as List?)?.length,
      programDays: (json['program'] as List?)?.length,
      stagingDir: photoFiles == null ? null : stagingDir,
    );
  }

  /// Replaces all data with the backup's. Goals, the program and photos are
  /// only replaced when the backup has them.
  Future<void> restore(BackupData data) async {
    final store = photos;
    final staging = data.stagingDir;
    final swapPhotos = store != null && staging != null && data.photoCount != null;
    var swapped = false;
    Directory? old;
    try {
      await db.transaction(() async {
        await _restoreRows(data.json);
        if (swapPhotos) {
          old = await store.swapIn(Directory(staging));
          swapped = true;
        }
      });
    } catch (_) {
      if (swapped) await store!.swapBack(old);
      rethrow;
    }
    try {
      await old?.delete(recursive: true);
    } on FileSystemException {
      // Left for the orphan sweep.
    }
  }

  Future<void> _restoreRows(Map<String, Object?> json) async {
    // Kept when the backup predates them; the library delete below would
    // otherwise cascade them away.
    final keepGoals = json['goals'] is List ? null : await db.select(db.goals).get();
    final keepProgram = json['program'] is List ? null : await ProgramRepository(db).loadProgram();

    // Children first, then the library.
    for (final TableInfo<Table, dynamic> t in [
      db.programDayExercises,
      db.programDayGroups,
      db.programDays,
      db.goals,
      if (json['photos'] is List) db.progressPhotos,
      if (json['dailyHealth'] is List) db.dailyHealth,
      db.sessionHealth,
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

    final groupIds = <int>{};
    final exerciseIds = <int>{};
    await db.batch((b) {
      for (final g in (json['groups']! as List).cast<Map<String, Object?>>()) {
        groupIds.add(g['id']! as int);
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
        exerciseIds.add(e['id']! as int);
        b.insert(
          db.exercises,
          ExercisesCompanion.insert(
            id: Value(e['id']! as int),
            name: e['name']! as String,
            groupId: Value(e['groupId'] as int?),
            kind: ExerciseKind.values.firstWhere((k) => k.name == e['kind'], orElse: () => ExerciseKind.strength),
            hidden: Value(e['hidden'] as bool? ?? false),
            isCustom: Value(e['isCustom'] as bool? ?? false),
            guideId: Value(e['guideId'] as String?),
          ),
        );
      }
      for (final w in (json['bodyWeights']! as List).cast<Map<String, Object?>>()) {
        b.insert(
          db.bodyWeights,
          BodyWeightsCompanion.insert(
            dayKey: Value(w['dayKey']! as int),
            weightKg: (w['weightKg']! as num).toDouble(),
            source: Value(w['source'] as String?),
          ),
        );
      }
      if (json['dailyHealth'] case final List daily) {
        for (final d in daily.cast<Map<String, Object?>>()) {
          b.insert(
            db.dailyHealth,
            DailyHealthCompanion.insert(
              dayKey: Value(d['dayKey']! as int),
              steps: Value(d['steps'] as int?),
              sleepMin: Value(d['sleepMin'] as int?),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
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
              startedAt: Value(DateTime.tryParse(e['startedAt'] as String? ?? '')),
            ),
          );
      if (e['health'] case final Map<String, Object?> h) {
        final start = DateTime.tryParse(h['startAt'] as String? ?? '');
        final end = DateTime.tryParse(h['endAt'] as String? ?? '');
        if (start != null && end != null) {
          await db
              .into(db.sessionHealth)
              .insert(
                SessionHealthCompanion.insert(
                  sessionId: Value(sid),
                  startAt: start,
                  endAt: end,
                  avgHr: Value(h['avgHr'] as int?),
                  maxHr: Value(h['maxHr'] as int?),
                  activeKcal: Value(h['activeKcal'] as int?),
                  source: Value(h['source'] as String?),
                ),
              );
        }
      }
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

    // Goals and the program, skipping anything whose exercise is gone.
    await db.batch((b) {
      if (keepGoals != null) {
        b.insertAll(db.goals, [
          for (final g in keepGoals)
            if (g.exerciseId == null || exerciseIds.contains(g.exerciseId)) g.copyWith(),
        ]);
      } else {
        for (final g in (json['goals']! as List).cast<Map<String, Object?>>()) {
          final exerciseId = g['exerciseId'] as int?;
          if (exerciseId != null && !exerciseIds.contains(exerciseId)) continue;
          b.insert(
            db.goals,
            GoalsCompanion.insert(
              kind: GoalKind.values.firstWhere((k) => k.name == g['kind'], orElse: () => GoalKind.lift),
              exerciseId: Value(exerciseId),
              targetKg: (g['targetKg']! as num).toDouble(),
              targetReps: Value(g['targetReps'] as int?),
              startKg: Value((g['startKg'] as num?)?.toDouble()),
              createdDayKey: g['createdDayKey']! as int,
              createdAt: Value(DateTime.tryParse(g['createdAt'] as String? ?? '') ?? DateTime.now()),
              achievedDayKey: Value(g['achievedDayKey'] as int?),
              sortOrder: Value(g['sortOrder'] as int? ?? 0),
            ),
          );
        }
      }
    });

    final plans =
        keepProgram?.values.toList() ??
        [
          for (final d in (json['program']! as List).cast<Map<String, Object?>>())
            ProgramDayPlan(
              weekday: d['weekday']! as int,
              label: d['label']! as String,
              groupIds: (d['groupIds'] as List? ?? const []).cast<int>(),
              exerciseIds: (d['exerciseIds'] as List? ?? const []).cast<int>(),
            ),
        ];
    final program = ProgramRepository(db);
    for (final p in plans) {
      if (p.weekday < 1 || p.weekday > 7) continue;
      await program.saveDay(
        ProgramDayPlan(
          weekday: p.weekday,
          label: p.label,
          groupIds: [
            for (final id in p.groupIds)
              if (groupIds.contains(id)) id,
          ],
          exerciseIds: [
            for (final id in p.exerciseIds)
              if (exerciseIds.contains(id)) id,
          ],
        ),
      );
    }

    if (json['photos'] case final List photos) {
      await db.batch((b) {
        for (final p in photos.cast<Map<String, Object?>>()) {
          b.insert(
            db.progressPhotos,
            ProgressPhotosCompanion.insert(
              dayKey: p['dayKey']! as int,
              fileName: p['fileName']! as String,
              note: Value(p['note'] as String?),
              createdAt: Value(DateTime.tryParse(p['createdAt'] as String? ?? '') ?? DateTime.now()),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
    }
  }
}
