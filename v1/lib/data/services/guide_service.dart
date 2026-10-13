import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show BytesBuilder;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/guide.dart';

/// Thrown when the guide isn't on the phone yet and can't be downloaded.
class GuideOfflineException implements Exception {
  const GuideOfflineException();
}

/// The exercise guide: free-exercise-db (public domain, by yuhonas on
/// GitHub), pinned to one version so it never changes under the app.
/// Downloaded on first use, kept in the app's cache and refreshed monthly;
/// pictures are fetched the first time they're shown.
class GuideService {
  GuideService({Directory? cacheDir}) : _cacheDir = cacheDir;

  static const _commit = 'f00c92c7dcf1216a928a52c3706c7ce8e2f71ed5';
  static const _mirrors = [
    'https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@$_commit',
    'https://raw.githubusercontent.com/yuhonas/free-exercise-db/$_commit',
  ];
  static const _maxAge = Duration(days: 30);

  Directory? _cacheDir;

  Future<Directory> _dir() async {
    final dir = _cacheDir ??= Directory('${(await getApplicationCacheDirectory()).path}/guide');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Every exercise, by id.
  Future<Map<String, GuideExercise>> load() async {
    final file = File('${(await _dir()).path}/exercises.json');
    final cached = await file.exists();
    final fresh = cached && DateTime.now().difference(await file.lastModified()) < _maxAge;
    if (!fresh) {
      final bytes = await _download('dist/exercises.json');
      if (bytes != null) {
        await file.writeAsBytes(bytes, flush: true);
      } else if (!cached) {
        throw const GuideOfflineException();
      }
    }
    return compute(parse, await file.readAsString());
  }

  static Map<String, GuideExercise> parse(String text) {
    final list = jsonDecode(text) as List;
    final out = <String, GuideExercise>{};
    for (final raw in list) {
      if (raw is! Map) continue;
      final e = GuideExercise.fromJson(raw.cast<String, Object?>());
      if (e != null) out[e.id] = e;
    }
    return out;
  }

  /// A picture on disk, downloading it first if needed. Null when offline.
  Future<File?> image(String path) async {
    if (!RegExp(r'^[A-Za-z0-9_\-()]+/\d+\.jpg$').hasMatch(path)) return null;
    final file = File('${(await _dir()).path}/img/${path.replaceAll('/', '__')}');
    if (await file.exists()) return file;
    final bytes = await _download('exercises/$path');
    if (bytes == null) return null;
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<Uint8List?> _download(String path) async {
    for (final base in _mirrors) {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      try {
        final req = await client.getUrl(Uri.parse('$base/$path'));
        final res = await req.close().timeout(const Duration(seconds: 20));
        if (res.statusCode != 200) continue;
        final builder = BytesBuilder(copy: false);
        await for (final chunk in res.timeout(const Duration(seconds: 30))) {
          builder.add(chunk);
        }
        return builder.takeBytes();
      } on Object {
        // Try the next mirror.
      } finally {
        client.close(force: true);
      }
    }
    return null;
  }
}
