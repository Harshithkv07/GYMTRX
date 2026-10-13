import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/holiday_service.dart';
import '../features.dart';
import 'settings_provider.dart';

final holidayServiceProvider = Provider<HolidayService>((ref) => const HolidayService());

/// Holiday names by day (last year to next year) from the calendars chosen
/// in Settings. Empty when the weekly program is off or none are chosen.
class HolidaysNotifier extends AsyncNotifier<Map<int, String>> {
  @override
  Future<Map<int, String>> build() async {
    final (on, ids) = ref.watch(settingsProvider.select((s) => (s.has(AppFeature.program), s.holidayCalendarIds)));
    if (!on || ids.isEmpty) return const {};
    final service = ref.read(holidayServiceProvider);
    try {
      if (!await service.hasPermission()) return const {};
      final year = DateTime.now().year;
      return await service.holidays(ids, DateTime(year - 1), DateTime(year + 2));
    } on Object {
      return const {};
    }
  }

  /// Picks up calendar changes (called when the app comes back).
  void refresh() => ref.invalidateSelf();
}

final holidaysProvider = AsyncNotifierProvider<HolidaysNotifier, Map<int, String>>(HolidaysNotifier.new);

/// Holidays by day, empty while loading.
final holidayMapProvider = Provider<Map<int, String>>((ref) => ref.watch(holidaysProvider).value ?? const {});
