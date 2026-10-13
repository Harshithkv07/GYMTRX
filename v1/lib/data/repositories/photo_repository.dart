import 'dart:io';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../services/photo_store.dart';

/// Progress photos: database rows plus the image files they point at.
class PhotoRepository {
  PhotoRepository(this.db, this.store);

  final AppDatabase db;
  final PhotoStore store;

  /// Newest first.
  Stream<List<ProgressPhoto>> watchAll() => (db.select(db.progressPhotos)
        ..orderBy([(p) => OrderingTerm.desc(p.dayKey), (p) => OrderingTerm.desc(p.createdAt)]))
      .watch();

  File fileOf(ProgressPhoto photo) => store.file(photo.fileName);

  /// Copies the picked image in and records it for [dayKey].
  Future<void> add(int dayKey, String sourcePath) async {
    final name = await store.importFile(sourcePath, dayKey);
    await db.into(db.progressPhotos).insert(ProgressPhotosCompanion.insert(dayKey: dayKey, fileName: name));
    // The picker's copy sits in the cache; it isn't needed any more.
    try {
      await File(sourcePath).delete();
    } on FileSystemException {
      // Not ours to delete (e.g. a gallery original); leave it.
    }
  }

  /// Removes the row only. The file stays until [purge] so undo can work.
  Future<void> remove(ProgressPhoto photo) =>
      (db.delete(db.progressPhotos)..where((p) => p.id.equals(photo.id))).go();

  Future<void> restore(ProgressPhoto photo) =>
      db.into(db.progressPhotos).insert(photo, mode: InsertMode.insertOrReplace);

  /// Deletes [photo]'s file if no row uses it any more.
  Future<void> purge(ProgressPhoto photo) async {
    final still = await (db.select(db.progressPhotos)..where((p) => p.fileName.equals(photo.fileName))).get();
    if (still.isEmpty) await store.delete(photo.fileName);
  }

  /// Clears out files left behind by interrupted adds or deletes.
  Future<void> sweepOrphans() async {
    final rows = await db.select(db.progressPhotos).get();
    await store.sweepOrphans({for (final r in rows) r.fileName});
  }
}
