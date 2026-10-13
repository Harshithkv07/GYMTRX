import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/app.dart';
import 'package:gymtrx/core/utils/day_key.dart';
import 'package:gymtrx/data/database/app_database.dart';
import 'package:gymtrx/data/repositories/session_repository.dart';
import 'package:gymtrx/data/services/photo_store.dart';
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
Future<AppDatabase> _pumpApp(WidgetTester tester, {double textScale = 1.0, bool onboarded = true}) async {
  _semantics = tester.ensureSemantics();
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  final prefs = await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions());
  // Past first launch and the home tour, with every feature on (the default once onboarded).
  if (onboarded) {
    await prefs.setBool('onboardingDone', true);
    await prefs.setBool('tourSeen', true);
  }
  final db = AppDatabase(NativeDatabase.memory());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        photoStoreProvider.overrideWithValue(PhotoStore(Directory.systemTemp)),
      ],
      child: const GymtrxApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

/// Taps Next through the intro slides, checking each one's layout.
Future<void> _walkIntro(WidgetTester tester) async {
  for (final title in [
    'A gym log that stays out of your way.',
    'Log in seconds',
    'See it add up',
    'Yours, on this phone',
  ]) {
    expect(find.text(title), findsOneWidget);
    _expectCleanLayout(tester, 'intro: $title');
    await tester.tap(find.text(title == 'Yours, on this phone' ? 'Get started' : 'Next'));
    await tester.pumpAndSettle();
  }
}

/// The home tour opens by itself after onboarding; checks it, then skips it.
Future<void> _skipTour(WidgetTester tester, {required int stops}) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  expect(find.text('1 of $stops'), findsOneWidget);
  _expectCleanLayout(tester, 'home tour');
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
  expect(find.text('1 of $stops'), findsNothing);
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

    await tester.tap(find.bySemanticsLabel('Insights').last); // the nav item
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

  testWidgets('first launch: "Just log" leaves only the calendar', (tester) async {
    final db = await _pumpApp(tester, onboarded: false);
    await _walkIntro(tester);
    await tester.tap(find.text('Just log my workouts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Fine-tune it'), findsOneWidget);
    _expectCleanLayout(tester, 'checklist');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Here’s your GYMTRX'), findsOneWidget);
    await tester.tap(find.text('Start logging'));
    await tester.pumpAndSettle();
    // ＋, the calendar and Settings; no tab bar stop with only the calendar.
    await _skipTour(tester, stops: 3);

    // Only the calendar: no Progress or Insights tab.
    expect(find.bySemanticsLabel('Log a session'), findsOneWidget);
    expect(find.bySemanticsLabel('Progress'), findsNothing);
    expect(find.bySemanticsLabel('Insights'), findsNothing);
    _expectCleanLayout(tester, 'calendar, logging only');

    // The log sheet has no weigh-in and no "same as before".
    await tester.tap(find.bySemanticsLabel('Log a session'));
    await tester.pumpAndSettle();
    expect(find.text('Body weight'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await _closeApp(tester, db);
  });

  testWidgets('first launch: "Everything" lays out at large text', (tester) async {
    final db = await _pumpApp(tester, onboarded: false, textScale: 1.3);
    await _walkIntro(tester);
    await tester.tap(find.text('Everything'));
    await tester.pumpAndSettle();
    _expectCleanLayout(tester, 'presets');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
      await tester.pumpAndSettle();
      _expectCleanLayout(tester, 'checklist, scrolled ${i + 1}');
    }
    // Then a setup page per permission (reminders, Health Connect, Drive), each skippable.
    for (final title in ['Reminders', 'Health Connect', 'Google Drive backup']) {
      await tester.tap(find.text('Next').evaluate().isEmpty ? find.text('Skip for now') : find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets, reason: 'setup page for $title');
      _expectCleanLayout(tester, title);
    }
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('Here’s your GYMTRX'), findsOneWidget);
    _expectCleanLayout(tester, 'summary');
    await tester.tap(find.text('Start logging'));
    await tester.pumpAndSettle();
    await _skipTour(tester, stops: 4);
    expect(find.bySemanticsLabel('Progress'), findsWidgets);
    expect(find.bySemanticsLabel('Insights'), findsWidgets);
    await _closeApp(tester, db);
  });
}
