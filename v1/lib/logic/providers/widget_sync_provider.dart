import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import 'data_providers.dart';
import 'settings_provider.dart';
import '../../presentation/widgets/labels.dart';

const _receiver = 'com.harshithkv.gymtrx.widget.MonthWidgetReceiver';

/// Keeps the home-screen widget in step with the data: whenever entries,
/// groups or settings change, it writes a small payload and asks Android to
/// redraw. Watch this provider once (the shell does) to start it.
final widgetSyncProvider = Provider<void>((ref) {
  Timer? debounce;
  ref.onDispose(() => debounce?.cancel());

  void schedule() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 400), () {
      final entries = ref.read(summariesProvider).value;
      if (entries == null) return;
      final groups = ref.read(groupsByIdProvider);
      final settings = ref.read(settingsProvider);
      final today = ref.read(todayProvider);
      final from = DayKeys.addDays(today, -400);
      final days = [for (final e in entries) if (e.dayKey >= from) e.dayKey];
      final last = entries.where((e) => e.dayKey <= today).firstOrNull;
      final label = last == null
          ? null
          : [Fmt.weekdayDayMonth(last.dayKey), groupLabel(last.groupIds, groups)].where((s) => s.isNotEmpty).join(' · ');
      final argb = settings.accent.color.toARGB32();
      _push({
        'days': days.join(','),
        'accent': '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        'weekStart': '${settings.weekStart}',
        'lastLabel': label,
      });
    });
  }

  ref.listen(summariesProvider, (_, _) => schedule(), fireImmediately: true);
  ref.listen(groupsByIdProvider, (_, _) => schedule());
  ref.listen(settingsProvider.select((s) => (s.accent, s.weekStart)), (_, _) => schedule());
});

Future<void> _push(Map<String, String?> data) async {
  try {
    for (final MapEntry(:key, :value) in data.entries) {
      await HomeWidget.saveWidgetData<String>(key, value);
    }
    await HomeWidget.updateWidget(qualifiedAndroidName: _receiver);
  } on Exception catch (e) {
    // No widget host (tests) or the plugin isn't ready: the widget catches up next change.
    debugPrint('Widget sync skipped: $e');
  }
}
