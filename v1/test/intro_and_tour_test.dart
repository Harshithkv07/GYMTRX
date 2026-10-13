import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/core/theme/accents.dart';
import 'package:gymtrx/core/theme/app_theme.dart';
import 'package:gymtrx/presentation/onboarding/intro_carousel.dart';
import 'package:gymtrx/presentation/tour/home_tour.dart';
import 'package:gymtrx/presentation/tour/tour_target.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Widget body) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGtTheme(GtAccent.fallback.color),
        home: Scaffold(body: body),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('intro slides', () {
    testWidgets('Next walks through the slides, then Get started leaves', (tester) async {
      var started = 0;
      final pages = <int>[];
      await pumpApp(tester, IntroCarousel(onPageChanged: pages.add, onStart: () => started++, onRestore: () {}));
      expect(find.text('Restore from Google Drive'), findsOneWidget);

      for (final title in ['Log in seconds', 'See it add up', 'Yours, on this phone']) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget);
      }
      expect(pages, [1, 2, 3]);
      expect(find.text('Restore from Google Drive'), findsNothing);
      expect(started, 0);

      await tester.tap(find.text('Get started'));
      expect(started, 1);
    });

    testWidgets('Skip leaves straight away', (tester) async {
      var started = 0;
      await pumpApp(tester, IntroCarousel(onPageChanged: (_) {}, onStart: () => started++));
      expect(find.text('Restore from Google Drive'), findsNothing);
      await tester.tap(find.text('Skip'));
      expect(started, 1);
    });

    testWidgets('opens on the slide it was left on', (tester) async {
      await pumpApp(tester, IntroCarousel(initialPage: 3, onPageChanged: (_) {}, onStart: () {}));
      expect(find.text('Yours, on this phone'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
    });
  });

  group('home tour', () {
    test('the tab bar is only a stop when other tabs are on', () {
      expect(homeTourSteps(extraTabs: const []).map((s) => s.spot), [
        TourSpot.add,
        TourSpot.calendar,
        TourSpot.settings,
      ]);
      final steps = homeTourSteps(extraTabs: const ['Progress', 'Insights']);
      expect(steps.map((s) => s.spot), contains(TourSpot.tabs));
      expect(steps.firstWhere((s) => s.spot == TourSpot.tabs).title, 'Progress and Insights');
    });

    Future<bool Function()> pumpHome(WidgetTester tester, {required bool withTabs}) async {
      var closed = false;
      await pumpApp(
        tester,
        Stack(
          children: [
            const Positioned(
              right: 12,
              top: 40,
              child: TourTarget(spot: TourSpot.settings, child: SizedBox.square(dimension: 44)),
            ),
            const Positioned(
              left: 12,
              right: 12,
              top: 120,
              height: 300,
              child: TourTarget(spot: TourSpot.calendar, child: SizedBox.expand()),
            ),
            if (withTabs)
              const Positioned(
                left: 16,
                bottom: 20,
                width: 220,
                height: 64,
                child: TourTarget(spot: TourSpot.tabs, child: SizedBox.expand()),
              ),
            const Positioned(
              right: 16,
              bottom: 20,
              child: TourTarget(spot: TourSpot.add, child: SizedBox.square(dimension: 64)),
            ),
            Center(
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    await showHomeTour(context, extraTabs: withTabs ? const ['Progress'] : const []);
                    closed = true;
                  },
                  child: const Text('Start'),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      return () => closed;
    }

    testWidgets('steps through each spot and closes on Done', (tester) async {
      final closed = await pumpHome(tester, withTabs: true);
      expect(find.text('1 of 4'), findsOneWidget);
      expect(find.text('Log a session'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Your month'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Progress'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('4 of 4'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(closed(), isTrue);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('a tap on the dimmed area moves on, and Skip closes', (tester) async {
      final closed = await pumpHome(tester, withTabs: false);
      expect(find.text('1 of 3'), findsOneWidget);

      await tester.tapAt(const Offset(30, 60));
      await tester.pumpAndSettle();
      expect(find.text('2 of 3'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(closed(), isTrue);
      expect(find.text('2 of 3'), findsNothing);
    });
  });
}
