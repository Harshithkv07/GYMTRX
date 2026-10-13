import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/core/theme/accents.dart';
import 'package:gymtrx/core/theme/app_theme.dart';
import 'package:gymtrx/presentation/settings/settings_widgets.dart';

void main() {
  Finder swatch(GtAccent a) =>
      find.byWidgetPredicate((w) => w is AccentSwatch && w.label == a.label && w.color == a.color);

  Future<List<GtAccent>> pump(WidgetTester tester, GtAccent selected) async {
    final picked = <GtAccent>[];
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGtTheme(selected.color),
        home: Scaffold(
          body: Center(
            child: AccentPicker(selected: selected, onChanged: picked.add),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return picked;
  }

  testWidgets('opens on the pack of the chosen accent', (tester) async {
    await pump(tester, GtAccent.volt);
    expect(swatch(GtAccent.volt), findsOneWidget);
    expect(swatch(GtAccent.sage), findsNothing);
  });

  testWidgets('the pill browses packs without changing the accent', (tester) async {
    final picked = await pump(tester, GtAccent.clay);
    expect(swatch(GtAccent.clay), findsOneWidget);

    await tester.tap(find.text('Neon'));
    await tester.pumpAndSettle();
    expect(swatch(GtAccent.volt), findsOneWidget);
    expect(swatch(GtAccent.clay), findsNothing);
    expect(picked, isEmpty);

    await tester.tap(swatch(GtAccent.volt));
    await tester.pumpAndSettle();
    expect(picked, [GtAccent.volt]);
  });

  testWidgets('a sideways fling across the swatches moves between packs', (tester) async {
    await pump(tester, GtAccent.sage);

    await tester.fling(swatch(GtAccent.teal), const Offset(-300, 0), 1200);
    await tester.pumpAndSettle();
    expect(swatch(GtAccent.volt), findsOneWidget);
    expect(swatch(GtAccent.sage), findsNothing);

    await tester.fling(swatch(GtAccent.ice), const Offset(300, 0), 1200);
    await tester.pumpAndSettle();
    expect(swatch(GtAccent.sage), findsOneWidget);
  });
}
