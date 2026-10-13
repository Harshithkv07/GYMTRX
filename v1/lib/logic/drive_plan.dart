import 'dart:convert';

import 'package:flutter/foundation.dart';

/// A backup snapshot stored in Drive.
typedef DriveSnapshotRef = ({String id, DateTime createdAt});

/// A photo stored in Drive. [goneSince] is set when the photo stopped being
/// part of the phone's data; older snapshots may still need it.
typedef DrivePhotoRef = ({String id, String name, DateTime? goneSince});

/// What to change in Drive after a new snapshot is uploaded.
@immutable
class DrivePrunePlan {
  const DrivePrunePlan({
    required this.deleteSnapshots,
    required this.deletePhotos,
    required this.markGone,
    required this.unmarkGone,
  });

  final List<String> deleteSnapshots;
  final List<String> deletePhotos;

  /// Photos the phone no longer has: remember since when.
  final List<String> markGone;

  /// Photos that came back (e.g. after a restore).
  final List<String> unmarkGone;
}

/// Keeps the newest [keep] snapshots. A photo goes once no kept snapshot can
/// refer to it: it has been gone from the phone since before the oldest
/// snapshot that's kept, so every kept snapshot was taken without it.
DrivePrunePlan planDrivePrune({
  required List<DriveSnapshotRef> snapshots,
  required List<DrivePhotoRef> photos,
  required Set<String> onPhone,
  int keep = 7,
}) {
  final newest = [...snapshots]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final kept = newest.take(keep).toList();
  final oldestKept = kept.isEmpty ? null : kept.last.createdAt;
  return DrivePrunePlan(
    deleteSnapshots: [for (final s in newest.skip(keep)) s.id],
    deletePhotos: [
      for (final p in photos)
        if (!onPhone.contains(p.name) &&
            p.goneSince != null &&
            (oldestKept == null || p.goneSince!.isBefore(oldestKept)))
          p.id,
    ],
    markGone: [
      for (final p in photos)
        if (!onPhone.contains(p.name) && p.goneSince == null) p.id,
    ],
    unmarkGone: [
      for (final p in photos)
        if (onPhone.contains(p.name) && p.goneSince != null) p.id,
    ],
  );
}

/// A stable fingerprint of a backup's content (ignoring when it was made),
/// so an unchanged log isn't uploaded again. 64-bit FNV-1a.
String backupFingerprint(String backupJson) {
  final map = (jsonDecode(backupJson) as Map).cast<String, Object?>()..remove('exportedAt');
  var hash = 0xcbf29ce484222325;
  for (final b in utf8.encode(jsonEncode(map))) {
    hash ^= b;
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash.toUnsigned(64).toRadixString(16);
}
