import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/core/theme/accents.dart';
import 'package:gymtrx/core/theme/app_theme.dart';
import 'package:gymtrx/data/models/entry.dart';
import 'package:gymtrx/logic/program_plan.dart';
import 'package:gymtrx/presentation/calendar/month_grid.dart';

void main() {
  Future<void> pump(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width * 3, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGtTheme(GtAccent.fallback.color),
        home: Scaffold(
          body: MonthGrid(
            month: (year: 2026, month: 10),
            weekStart: DateTime.monday,
            today: 20261011,
            entries: const {
              20261005: EntrySummary(sessionId: 1, dayKey: 20261005, groupIds: [], exerciseCount: 0, hasNote: false),
            },
            onDayTap: (_) {},
            holidays: const {20261008: 'Test holiday'},
            planOf: (d) => d == 20261009 ? PlanStatus.missed : PlanStatus.none,
            // Every past day has steps; the gym day must not show them.
            stepsOf: (d) => 8412,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('rest days show compact steps; gym and future days don’t', (tester) async {
    await pump(tester, 412);
    expect(tester.takeException(), isNull);
    // 1–11 Oct minus the gym day on the 5th.
    expect(find.text('8.4k'), findsNWidgets(10));
  });

  testWidgets('the smallest cells still lay out', (tester) async {
    await pump(tester, 280);
    expect(tester.takeException(), isNull);
  });
}
