import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/day_key.dart';

/// Which bottom tab is showing (0 = Calendar, 1 = Insights).
class ShellTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void show(int tab) => state = tab;
}

final shellTabProvider = NotifierProvider<ShellTabNotifier, int>(ShellTabNotifier.new);

/// A month another screen asked the calendar to show (e.g. tapping a month in
/// the Insights year view). The calendar consumes it and resets it to null.
class CalendarJumpNotifier extends Notifier<YearMonth?> {
  @override
  YearMonth? build() => null;

  void request(YearMonth month) => state = month;

  void consumed() => state = null;
}

final calendarJumpProvider = NotifierProvider<CalendarJumpNotifier, YearMonth?>(CalendarJumpNotifier.new);
