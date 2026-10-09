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
import 'package:gymtrx/presentation/calendar/calendar_screen.dart';
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

/// The welcome cover animates forever (drifting art), so it can't settle;
/// this advances time in steps instead.
Future<void> _pumpFor(WidgetTester tester, Duration total) async {
  for (var t = Duration.zero; t < total; t += const Duration(milliseconds: 100)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Pumps the real app on a phone-sized screen with an in-memory database.
/// By default the welcome page has already been seen.
Future<AppDatabase> _pumpApp(
  WidgetTester tester, {
  double textScale = 1.0,
  bool welcomeSeen = true,
  Brightness brightness = Brightness.light,
}) async {
  _semantics = tester.ensureSemantics();
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  final prefs = await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions());
  if (welcomeSeen) await prefs.setBool('welcomeSeen', true);
  final db = AppDatabase(NativeDatabase.memory());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs), databaseProvider.overrideWithValue(db)],
      child: const GymtrxApp(),
    ),
  );
  if (welcomeSeen) {
    await tester.pumpAndSettle();
  } else {
    await _pumpFor(tester, const Duration(seconds: 2));
  }
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

  testWidgets('first launch: welcome → name → home greets by name', (tester) async {
    final db = await _pumpApp(tester, welcomeSeen: false);
    expect(find.text('Get started'), findsOneWidget);
    _expectCleanLayout(tester, 'welcome');

    await tester.tap(find.text('Get started'));
    await _pumpFor(tester, const Duration(seconds: 1));
    expect(find.text('What should we call you?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Harshith');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Hey, Harshith'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);
    _expectCleanLayout(tester, 'home');
    await _closeApp(tester, db);
  });

  testWidgets('quick capture: ＋, pick a group, Done → logged', (tester) async {
    final db = await _pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Log a session'));
    await tester.pumpAndSettle();
    expect(find.text('What did you train?'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Chest')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    final day = DayKeys.logicalToday();
    final entry = await SessionRepository(db).loadEntry(day);
    expect(entry, isNotNull);
    expect(entry!.groups.map((g) => g.name), ['Chest']);
    expect(find.textContaining('Logged'), findsOneWidget, reason: 'the undo toast');
    expect(find.text('CHEST'), findsWidgets, reason: 'the recent-session card on Home');

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

  for (final brightness in Brightness.values) {
    testWidgets('large text (1.3×, ${brightness.name}) lays out without overflow', (tester) async {
      final db = await _pumpApp(tester, textScale: 1.3, brightness: brightness);
      // Some history so cards, charts and the entry detail all have content.
      final repo = SessionRepository(db);
      final today = DayKeys.today();
      final groups = await db.select(db.muscleGroups).get();
      for (var i = 0; i < 6; i++) {
        final day = DayKeys.addDays(today, -i * 3);
        await repo.setGroups(day, [groups[i % 5].id, groups[(i + 2) % 5].id]);
        final se = await repo.addExercise(day, 1);
        await repo.addSet(se);
        await repo.setDuration(day, 50);
      }
      await tester.pumpAndSettle();
      _expectCleanLayout(tester, 'home');
      for (var i = 0; i < 3; i++) {
        await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -500));
        await tester.pumpAndSettle();
        _expectCleanLayout(tester, 'home, scrolled ${i + 1}');
      }

      await tester.tap(find.bySemanticsLabel('Log a session'));
      await tester.pumpAndSettle();
      _expectCleanLayout(tester, 'log sheet');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calendar').last); // the nav item
      await tester.pumpAndSettle();
      _expectCleanLayout(tester, 'calendar');

      // Every tab stays built, so look only inside the calendar.
      final open = find.descendant(of: find.byType(CalendarScreen), matching: find.bySemanticsLabel('Open')).first;
      await tester.ensureVisible(open);
      await tester.pumpAndSettle();
      await tester.tap(open);
      await tester.pumpAndSettle();
      _expectCleanLayout(tester, 'entry detail');
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Insights').last);
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
}
