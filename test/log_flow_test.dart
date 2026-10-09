import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/app.dart';
import 'package:gymtrx/core/utils/day_key.dart';
import 'package:gymtrx/data/database/app_database.dart';
import 'package:gymtrx/data/repositories/session_repository.dart';
import 'package:gymtrx/logic/providers/data_providers.dart';
import 'package:gymtrx/logic/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

SemanticsHandle? _semantics;

/// Fails with the full diagnostics (which widget, how far) if layout broke.
void _expectCleanLayout(WidgetTester tester, String where) {
  final error = tester.takeException();
  if (error is FlutterError) fail('$where: ${error.toStringDeep()}');
  expect(error, isNull, reason: where);
}

/// Pumps the real app on a phone-sized screen with an in-memory database.
Future<AppDatabase> _pumpApp(WidgetTester tester, {double textScale = 1.0}) async {
  _semantics = tester.ensureSemantics();
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  final prefs = await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions());
  final db = AppDatabase(NativeDatabase.memory());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs), databaseProvider.overrideWithValue(db)],
      child: const GymtrxApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

Future<void> _closeApp(WidgetTester tester, AppDatabase db) async {
  // Unmount first so stream subscriptions close, then the database.
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
  await db.close();
  _semantics?.dispose();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('quick capture: ＋, pick a group, Done → logged on the calendar', (tester) async {
    final db = await _pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Log a session'));
    await tester.pumpAndSettle();
    expect(find.text('WHAT DID YOU TRAIN?'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Chest')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    final day = DayKeys.logicalToday();
    final entry = await SessionRepository(db).loadEntry(day);
    expect(entry, isNotNull);
    expect(entry!.groups.map((g) => g.name), ['Chest']);
    expect(find.textContaining('Logged'), findsOneWidget, reason: 'the undo toast');

    await _closeApp(tester, db);
  });

  testWidgets('opening and closing the sheet without changes logs nothing', (tester) async {
    final db = await _pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Log a session'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(await db.select(db.sessions).get(), isEmpty);
    expect(find.textContaining('Logged'), findsNothing);
    await _closeApp(tester, db);
  });

  testWidgets('large text (1.3×) lays out without overflow', (tester) async {
    final db = await _pumpApp(tester, textScale: 1.3);
    _expectCleanLayout(tester, 'calendar');

    await tester.tap(find.bySemanticsLabel('Log a session'));
    await tester.pumpAndSettle();
    _expectCleanLayout(tester, 'log sheet');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Insights').last); // the nav item
    await tester.pumpAndSettle();
    _expectCleanLayout(tester, 'insights');
    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(CustomScrollView).last, const Offset(0, -500));
      await tester.pumpAndSettle();
      _expectCleanLayout(tester, 'insights, scrolled ${i + 1}');
    }

    await tester.tap(find.bySemanticsLabel('Settings').last);
    await tester.pumpAndSettle();
    _expectCleanLayout(tester, 'settings');
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(CustomScrollView).last, const Offset(0, -500));
      await tester.pumpAndSettle();
      _expectCleanLayout(tester, 'settings, scrolled ${i + 1}');
    }
    await _closeApp(tester, db);
  });
}
