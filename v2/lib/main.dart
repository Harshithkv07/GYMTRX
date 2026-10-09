import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/licenses.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'logic/providers/data_providers.dart';
import 'logic/providers/settings_provider.dart';
import 'presentation/art/dot_body.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerLicenses();

  // Draw behind the status and navigation bars; the UI handles insets itself.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    gtOverlayStyle(WidgetsBinding.instance.platformDispatcher.platformBrightness),
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions());
  final db = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs), databaseProvider.overrideWithValue(db)],
      child: const GymtrxApp(),
    ),
  );
  // Sample the dot-matrix body during idle frames, before any screen needs it.
  WidgetsBinding.instance.addPostFrameCallback((_) => DotBody.warmUp());
}
