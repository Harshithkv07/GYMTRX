import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/guide.dart';
import '../../data/services/guide_service.dart';

final guideServiceProvider = Provider<GuideService>((ref) => GuideService());

/// The whole exercise guide by id. Fails with [GuideOfflineException] the
/// first time without internet; invalidate to try again.
final guideCatalogProvider = FutureProvider<Map<String, GuideExercise>>((ref) => ref.read(guideServiceProvider).load());

/// A guide picture on disk (downloaded on first view); null when offline.
final guideImageProvider = FutureProvider.family<File?, String>(
  (ref, path) => ref.read(guideServiceProvider).image(path),
);
