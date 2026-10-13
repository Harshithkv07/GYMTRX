import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/day_key.dart';
import '../features.dart';
import 'settings_provider.dart';

/// Bottom tab indices.
abstract final class ShellTab {
  static const calendar = 0;
  static const progress = 1;
  static const insights = 2;
}

/// Which bottom tab is showing, one of [ShellTab].
class ShellTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void show(int tab) => state = tab;
}

final shellTabProvider = NotifierProvider<ShellTabNotifier, int>(ShellTabNotifier.new);

/// The tabs the chosen features call for, in order. Calendar is always there.
final visibleTabsProvider = Provider<List<int>>((ref) {
  final features = ref.watch(settingsProvider.select((s) => s.features));
  return [
    ShellTab.calendar,
    if (features.any(AppFeature.progress.contains)) ShellTab.progress,
    if (features.contains(AppFeature.insights)) ShellTab.insights,
  ];
});

/// A month another screen asked the calendar to show (e.g. tapping a month in
/// the Insights year view). The calendar consumes it and resets it to null.
class CalendarJumpNotifier extends Notifier<YearMonth?> {
  @override
  YearMonth? build() => null;

  void request(YearMonth month) => state = month;

  void consumed() => state = null;
}

final calendarJumpProvider = NotifierProvider<CalendarJumpNotifier, YearMonth?>(CalendarJumpNotifier.new);
