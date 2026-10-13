import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../../core/config.dart';
import '../../logic/drive_plan.dart';
import '../database/app_database.dart';
import 'backup_service.dart';
import 'photo_store.dart';

/// A backup in Drive, as offered for restoring.
typedef DriveSnapshot = ({String id, DateTime createdAt, int? entries, int? photos});

/// Thrown with a message that can be shown as is.
class DriveBackupException implements Exception {
  const DriveBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Backups in the user's own Google Drive, in the hidden app-data folder that
/// only GYMTRX can see (the `drive.appdata` scope: no access to anything else
/// in their Drive).
///
/// Incremental: each backup is one small JSON snapshot (the same content as
/// `backup.json` in an exported ZIP), and each photo is uploaded only once.
/// The newest [keepSnapshots] snapshots are kept.
class DriveBackupService {
  DriveBackupService._();

  static final instance = DriveBackupService._();

  static const scopes = [drive.DriveApi.driveAppdataScope];
  static const keepSnapshots = 7;
  static const _space = 'appDataFolder';

  Future<void>? _init;

  Future<void> _ensureInit() => _init ??= GoogleSignIn.instance.initialize(serverClientId: googleWebClientId);

  /// Interactive: account picker, then consent for the app folder. Returns
  /// the account's email.
  Future<String> signIn() async {
    if (!driveConfigured) throw const DriveBackupException('Drive backup isn’t set up in this copy of GYMTRX.');
    await _ensureInit();
    try {
      final account = await GoogleSignIn.instance.authenticate(scopeHint: scopes);
      await account.authorizationClient.authorizeScopes(scopes);
      return account.email;
    } on GoogleSignInException catch (e) {
      throw DriveBackupException(switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Sign-in was cancelled.',
        GoogleSignInExceptionCode.uiUnavailable => 'Couldn’t show the Google sign-in screen.',
        _ => 'Couldn’t sign in to Google. Check your connection and try again.',
      });
    }
  }

  Future<void> signOut() async {
    await _ensureInit();
    try {
      await GoogleSignIn.instance.disconnect();
    } on Object {
      await GoogleSignIn.instance.signOut();
    }
  }

  /// A Drive client without any UI, for automatic backups. [interactive]
  /// may show Google's consent screen again if access was withdrawn.
  Future<drive.DriveApi> _api({bool interactive = false}) async {
    if (!driveConfigured) throw const DriveBackupException('Drive backup isn’t set up in this copy of GYMTRX.');
    await _ensureInit();
    final client = GoogleSignIn.instance.authorizationClient;
    var auth = await client.authorizationForScopes(scopes);
    if (auth == null && interactive) {
      try {
        auth = await client.authorizeScopes(scopes);
      } on GoogleSignInException {
        auth = null;
      }
    }
    if (auth == null) throw const DriveBackupException('Sign in to Google again to keep backing up.');
    return drive.DriveApi(auth.authClient(scopes: scopes));
  }

  Future<List<drive.File>> _list(drive.DriveApi api, String kind) async {
    final out = <drive.File>[];
    String? page;
    do {
      final res = await api.files.list(
        spaces: _space,
        q: "appProperties has { key='kind' and value='$kind' }",
        $fields: 'nextPageToken, files(id, name, createdTime, appProperties)',
        pageSize: 1000,
        pageToken: page,
      );
      out.addAll(res.files ?? const []);
      page = res.nextPageToken;
    } while (page != null);
    return out;
  }

  /// Uploads a snapshot and any photos Drive doesn't have yet, then prunes.
  Future<void> backUp({
    required AppDatabase db,
    required PhotoStore photos,
    required String backupJson,
    bool interactive = false,
  }) async {
    final api = await _api(interactive: interactive);
    try {
      final rows = await db.select(db.progressPhotos).get();
      final onPhone = {for (final r in rows) r.fileName};

      // Photos first, so a snapshot never points at a photo Drive lacks.
      final inDrive = await _list(api, 'photo');
      final have = {for (final f in inDrive) f.appProperties?['file']};
      for (final name in onPhone.difference(have.nonNulls.toSet())) {
        final file = photos.file(name);
        if (!await file.exists()) continue;
        await api.files.create(
          drive.File()
            ..name = 'photo-$name'
            ..parents = [_space]
            ..appProperties = {'kind': 'photo', 'file': name},
          uploadMedia: drive.Media(file.openRead(), await file.length(), contentType: 'image/jpeg'),
          uploadOptions: drive.ResumableUploadOptions(),
        );
      }

      final decoded = jsonDecode(backupJson) as Map<String, Object?>;
      final bytes = utf8.encode(backupJson);
      final now = DateTime.now();
      await api.files.create(
        drive.File()
          ..name = 'snapshot-${now.toUtc().toIso8601String()}.json'
          ..parents = [_space]
          ..appProperties = {
            'kind': 'snapshot',
            'entries': '${(decoded['entries'] as List?)?.length ?? 0}',
            'photos': '${(decoded['photos'] as List?)?.length ?? 0}',
          },
        uploadMedia: drive.Media(Stream.value(bytes), bytes.length, contentType: 'application/json'),
      );

      final snapshots = await _list(api, 'snapshot');
      final photoFiles = await _list(api, 'photo');
      final plan = planDrivePrune(
        snapshots: [
          for (final s in snapshots)
            if (s.id != null) (id: s.id!, createdAt: s.createdTime ?? now),
        ],
        photos: [
          for (final p in photoFiles)
            if (p.id != null && p.appProperties?['file'] != null)
              (
                id: p.id!,
                name: p.appProperties!['file']!,
                goneSince: DateTime.tryParse(p.appProperties?['goneSince'] ?? ''),
              ),
        ],
        onPhone: onPhone,
        keep: keepSnapshots,
      );
      for (final id in [...plan.deleteSnapshots, ...plan.deletePhotos]) {
        await api.files.delete(id);
      }
      for (final id in plan.markGone) {
        await api.files.update(drive.File()..appProperties = {'goneSince': now.toUtc().toIso8601String()}, id);
      }
      for (final id in plan.unmarkGone) {
        // A null value removes the property.
        await api.files.update(drive.File()..appProperties = {'goneSince': null}, id);
      }
    } on DriveBackupException {
      rethrow;
    } on Object catch (e) {
      throw DriveBackupException(_describe(e));
    }
  }

  /// Backups in Drive, newest first.
  Future<List<DriveSnapshot>> snapshots({bool interactive = true}) async {
    final api = await _api(interactive: interactive);
    try {
      final files = await _list(api, 'snapshot');
      final list = [
        for (final f in files)
          if (f.id != null)
            (
              id: f.id!,
              createdAt: (f.createdTime ?? DateTime.now()).toLocal(),
              entries: int.tryParse(f.appProperties?['entries'] ?? ''),
              photos: int.tryParse(f.appProperties?['photos'] ?? ''),
            ),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } on Object catch (e) {
      throw DriveBackupException(_describe(e));
    }
  }

  /// Downloads [snapshot] and its photos into [stagingDir], ready for
  /// [BackupService.restore].
  Future<BackupData> download(DriveSnapshot snapshot, {required String stagingDir}) async {
    final api = await _api(interactive: true);
    try {
      final media = await api.files.get(snapshot.id, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final text = await utf8.decodeStream(media.stream);
      final json = jsonDecode(text) as Map<String, Object?>;
      final wanted = {
        for (final p in (json['photos'] as List? ?? const []).cast<Map<String, Object?>>())
          if (p['fileName'] case final String name) name,
      };

      final staging = Directory(stagingDir);
      if (await staging.exists()) await staging.delete(recursive: true);
      await staging.create(recursive: true);
      final got = <String>{};
      final valid = RegExp(r'^[A-Za-z0-9._-]+$');
      for (final f in await _list(api, 'photo')) {
        final name = f.appProperties?['file'];
        if (f.id == null || name == null || !wanted.contains(name) || !valid.hasMatch(name)) continue;
        final m = await api.files.get(f.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
        final sink = File('${staging.path}/$name').openWrite();
        await sink.addStream(m.stream);
        await sink.close();
        got.add(name);
      }
      return BackupService.parse(text, photoFiles: got, stagingDir: staging.path);
    } on FormatException {
      rethrow;
    } on Object catch (e) {
      throw DriveBackupException(_describe(e));
    }
  }

  static String _describe(Object e) => switch (e) {
    SocketException() || TimeoutException() || HttpException() => 'No connection to Google Drive. Try again later.',
    drive.DetailedApiRequestError(status: 401 || 403) => 'Google Drive refused access. Sign in again.',
    drive.DetailedApiRequestError(status: 507) ||
    drive.DetailedApiRequestError(status: 413) => 'Your Google Drive is full.',
    _ => 'Couldn’t reach Google Drive. Try again later.',
  };
}
