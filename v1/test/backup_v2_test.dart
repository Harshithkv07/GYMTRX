import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/data/database/app_database.dart';
import 'package:gymtrx/data/models/progress.dart';
import 'package:gymtrx/data/repositories/goal_repository.dart';
import 'package:gymtrx/data/repositories/photo_repository.dart';
import 'package:gymtrx/data/repositories/program_repository.dart';
import 'package:gymtrx/data/repositories/session_repository.dart';
import 'package:gymtrx/data/services/backup_service.dart';
import 'package:gymtrx/data/services/photo_store.dart';

Map<String, Object?> _comparable(String json) {
  final map = (jsonDecode(json) as Map).cast<String, Object?>()..remove('exportedAt');
  return map;
}

/// A phone: its own database and photo folder.
class _Phone {
  _Phone(this.dir) : db = AppDatabase(NativeDatabase.memory()), store = PhotoStore(dir);

  final Directory dir;
  final AppDatabase db;
  final PhotoStore store;

  BackupService get backup => BackupService(db, photos: store);
  PhotoRepository get photos => PhotoRepository(db, store);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('gymtrx_backup_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<_Phone> phone(String name) async {
    final p = _Phone(Directory('${tmp.path}/$name')..createSync());
    await p.store.dir.create(recursive: true);
    return p;
  }

  Future<String> fakeJpeg(String name, List<int> bytes) async {
    final f = File('${tmp.path}/$name')..writeAsBytesSync(bytes);
    return f.path;
  }

  test('zip round trip: goals, program and photos come back identical', () async {
    final a = await phone('a');
    final ex = {for (final e in await a.db.select(a.db.exercises).get()) e.name: e.id};
    final groups = {for (final g in await a.db.select(a.db.muscleGroups).get()) g.slug!: g.id};
    await SessionRepository(a.db).setGroups(20261001, [groups['chest']!]);
    await GoalRepository(a.db).addLift(exerciseId: ex['Bench Press']!, targetKg: 90, targetReps: 5, today: 20261001);
    await GoalRepository(a.db).setBodyWeight(targetKg: 72, startKg: 76, today: 20261001);
    await ProgramRepository(a.db).saveDay(
      ProgramDayPlan(weekday: 1, label: 'Push', groupIds: [groups['chest']!], exerciseIds: [ex['Bench Press']!]),
    );
    await a.photos.add(20261001, await fakeJpeg('one.jpg', [1, 2, 3]));
    await a.photos.add(20261005, await fakeJpeg('two.jpg', [4, 5, 6, 7]));

    final json = await a.backup.export(settings: {'unit': 'kg'});
    final zip = '${tmp.path}/backup.zip';
    await BackupService.writeArchive((json: json, photos: await a.backup.photoFiles(), outPath: zip));

    final b = await phone('b');
    final data = await BackupService.parseFile((path: zip, stagingDir: '${tmp.path}/staging'));
    expect(data.photoCount, 2);
    expect(data.goalCount, 2);
    expect(data.programDays, 1);
    await b.backup.restore(data);

    expect(_comparable(await b.backup.export(settings: {'unit': 'kg'})), _comparable(json));
    final restored = await b.db.select(b.db.progressPhotos).get();
    expect([for (final p in restored) b.store.file(p.fileName).readAsBytesSync().length]..sort(), [3, 4]);
    expect(Directory('${tmp.path}/staging').existsSync(), isFalse, reason: 'staging became the photo folder');
  });

  test('an old JSON backup keeps the phone’s goals, program and photos', () async {
    final a = await phone('a');
    final ex = {for (final e in await a.db.select(a.db.exercises).get()) e.name: e.id};
    await SessionRepository(a.db).setGroups(20261001, [1]);
    final legacy = (jsonDecode(await a.backup.export(settings: const {})) as Map).cast<String, Object?>()
      ..['version'] = 1
      ..remove('goals')
      ..remove('program')
      ..remove('photos');

    final b = await phone('b');
    await GoalRepository(b.db).addLift(exerciseId: ex['Squat']!, targetKg: 100, today: 20261001);
    await ProgramRepository(b.db).saveDay(const ProgramDayPlan(weekday: 3, label: 'Legs'));
    await b.photos.add(20261002, await fakeJpeg('keep.jpg', [9]));

    final file = File('${tmp.path}/old.json')..writeAsStringSync(jsonEncode(legacy));
    final data = await BackupService.parseFile((path: file.path, stagingDir: '${tmp.path}/staging'));
    expect(data.photoCount, isNull);
    expect(data.goalCount, isNull);
    await b.backup.restore(data);

    expect((await b.db.select(b.db.goals).getSingle()).targetKg, 100);
    expect((await ProgramRepository(b.db).loadProgram()).keys, [3]);
    final photo = await b.db.select(b.db.progressPhotos).getSingle();
    expect(b.store.file(photo.fileName).existsSync(), isTrue);
    expect(await SessionRepository(b.db).loadEntry(20261001), isNotNull);
  });

  test('zip entries outside photos/ are never written', () async {
    final a = await phone('a');
    final json = await a.backup.export(settings: const {});
    final zip = '${tmp.path}/evil.zip';
    final enc = ZipFileEncoder()..create(zip);
    enc.addArchiveFile(ArchiveFile.string('backup.json', json));
    enc.addArchiveFile(ArchiveFile.bytes('photos/../escape.jpg', [1]));
    enc.addArchiveFile(ArchiveFile.bytes('photos/sub/nested.jpg', [1]));
    enc.addArchiveFile(ArchiveFile.bytes('photos/ok.jpg', [1]));
    await enc.close();

    final staging = '${tmp.path}/staging';
    await BackupService.parseFile((path: zip, stagingDir: staging));
    expect(File('${tmp.path}/escape.jpg').existsSync(), isFalse);
    expect([for (final f in Directory(staging).listSync()) f.uri.pathSegments.last], ['ok.jpg']);
  });

  test('broken and foreign files are rejected', () async {
    final corrupt = File('${tmp.path}/corrupt.zip')..writeAsBytesSync([0x50, 0x4B, 3, 4, 0, 0, 1, 2, 3]);
    await expectLater(
      BackupService.parseFile((path: corrupt.path, stagingDir: '${tmp.path}/s1')),
      throwsFormatException,
    );

    final noJson = '${tmp.path}/nojson.zip';
    final enc = ZipFileEncoder()..create(noJson);
    enc.addArchiveFile(ArchiveFile.string('readme.txt', 'hi'));
    await enc.close();
    await expectLater(BackupService.parseFile((path: noJson, stagingDir: '${tmp.path}/s2')), throwsFormatException);

    expect(
      () => BackupService.parse('{"format":"gymtrx-backup","version":4}'),
      throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('newer'))),
    );
  });
}
