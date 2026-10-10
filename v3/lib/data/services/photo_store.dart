import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Where progress photos live: `<app documents>/photos/`. Private to the app,
/// so they never show up in the phone's gallery. The database stores only
/// file names, since the absolute path can change between installs.
class PhotoStore {
  PhotoStore(this.root);

  /// The app documents directory (a temp directory in tests).
  final Directory root;

  static const folder = 'photos';

  Directory get dir => Directory('${root.path}/$folder');

  static Future<PhotoStore> open() async {
    final store = PhotoStore(await getApplicationDocumentsDirectory());
    await store.dir.create(recursive: true);
    return store;
  }

  File file(String fileName) => File('${dir.path}/$fileName');

  /// Copies a picked image in and returns its new file name.
  Future<String> importFile(String sourcePath, int dayKey) async {
    await dir.create(recursive: true);
    final name = 'p_${dayKey}_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(sourcePath).copy(file(name).path);
    return name;
  }

  Future<void> delete(String fileName) async {
    try {
      await file(fileName).delete();
    } on FileSystemException {
      // Already gone.
    }
  }

  /// Deletes files no row points at. Recent files are left alone: they may
  /// belong to an add or an undo that's still in flight.
  Future<int> sweepOrphans(Set<String> known, {Duration olderThan = const Duration(hours: 1)}) async {
    if (!await dir.exists()) return 0;
    final cutoff = DateTime.now().subtract(olderThan);
    var removed = 0;
    await for (final e in dir.list()) {
      if (e is! File) continue;
      final name = e.uri.pathSegments.last;
      if (known.contains(name)) continue;
      if ((await e.lastModified()).isAfter(cutoff)) continue;
      await e.delete();
      removed++;
    }
    return removed;
  }

  /// Swaps [staging] in as the photo folder. Returns the old folder so the
  /// caller can delete it once the database commit succeeded, or put it back.
  Future<Directory?> swapIn(Directory staging) async {
    Directory? old;
    if (await dir.exists()) {
      old = await dir.rename('${root.path}/${folder}_old_${DateTime.now().millisecondsSinceEpoch}');
    }
    try {
      await staging.rename(dir.path);
    } on FileSystemException {
      if (old != null) await old.rename(dir.path);
      rethrow;
    }
    return old;
  }

  /// Undoes [swapIn] after a failed restore.
  Future<void> swapBack(Directory? old) async {
    if (await dir.exists()) await dir.delete(recursive: true);
    if (old != null) await old.rename(dir.path);
  }
}
