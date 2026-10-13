import 'package:flutter/services.dart';

/// A calendar on the phone (Google Calendar's "Holidays in India", say).
typedef PhoneCalendar = ({String id, String name, String account, int color});

/// Dart side of `gymtrx/calendar` (see CalendarBridge.kt). Read-only.
class HolidayService {
  const HolidayService();

  static const _channel = MethodChannel('gymtrx/calendar');

  Future<bool> hasPermission() async => await _channel.invokeMethod<bool>('hasPermission') ?? false;

  Future<bool> requestPermission() async => await _channel.invokeMethod<bool>('requestPermission') ?? false;

  Future<List<PhoneCalendar>> calendars() async {
    final rows = await _channel.invokeListMethod<Map>('calendars') ?? const [];
    return [
      for (final r in rows)
        (
          id: r['id'] as String,
          name: r['name'] as String? ?? '',
          account: r['account'] as String? ?? '',
          color: (r['color'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  /// Holiday names by day for the chosen calendars, between [from] and [to].
  Future<Map<int, String>> holidays(List<String> calendarIds, DateTime from, DateTime to) async {
    if (calendarIds.isEmpty) return const {};
    final rows =
        await _channel.invokeListMethod<Map>('allDayEvents', {
          'calendars': calendarIds,
          'from': from.millisecondsSinceEpoch,
          'to': to.millisecondsSinceEpoch,
        }) ??
        const [];
    final out = <int, String>{};
    for (final r in rows) {
      final day = (r['day'] as num).toInt();
      final title = (r['title'] as String? ?? '').trim();
      if (title.isEmpty) continue;
      final had = out[day];
      out[day] = had == null || had.contains(title) ? title : '$had · $title';
    }
    return out;
  }

  /// Calendars that look like holiday calendars, to tick by default.
  static bool looksLikeHolidays(PhoneCalendar c) =>
      RegExp('holiday', caseSensitive: false).hasMatch(c.name) || c.account.contains('#holiday@');
}
