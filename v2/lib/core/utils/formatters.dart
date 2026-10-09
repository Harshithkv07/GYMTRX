import 'package:intl/intl.dart';

import 'day_key.dart';

/// Date and number formatting. Patterns put the day before the month
/// ("Wed 8 Oct"), which reads naturally in India and the UK.
abstract final class Fmt {
  static final _weekdayDayMonth = DateFormat('EEE d MMM');
  static final _dayMonth = DateFormat('d MMM');
  static final _dayMonthYear = DateFormat('d MMM yyyy');
  static final _fullDate = DateFormat('EEEE, d MMMM yyyy');
  static final _month = DateFormat('MMMM');
  static final _monthShort = DateFormat('MMM');
  static final _weekdayShort = DateFormat('EEE');
  static final _weekdayLong = DateFormat('EEEE');

  /// "Wed 8 Oct"
  static String weekdayDayMonth(int key) => _weekdayDayMonth.format(DayKeys.toDate(key));

  /// "8 Oct"
  static String dayMonth(int key) => _dayMonth.format(DayKeys.toDate(key));

  /// "8 Oct 2026"
  static String dayMonthYear(int key) => _dayMonthYear.format(DayKeys.toDate(key));

  /// "Wednesday, 8 October 2026"
  static String fullDate(int key) => _fullDate.format(DayKeys.toDate(key));

  /// "October"
  static String monthName(int month) => _month.format(DateTime(2000, month));

  /// "Oct"
  static String monthShort(int month) => _monthShort.format(DateTime(2000, month));

  /// "Wed"
  static String weekdayShort(int key) => _weekdayShort.format(DayKeys.toDate(key));

  /// "Wednesday"
  static String weekdayLong(int key) => _weekdayLong.format(DayKeys.toDate(key));

  /// Single-letter weekday header for ISO weekday 1..7.
  static String weekdayInitial(int isoWeekday) => const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][isoWeekday - 1];

  /// "Today", "Yesterday", "3 days ago". Never judgemental, just distance.
  static String relativeDay(int key, int todayKey) {
    final d = DayKeys.daysBetween(key, todayKey);
    if (d == 0) return 'Today';
    if (d == 1) return 'Yesterday';
    if (d == -1) return 'Tomorrow';
    if (d > 1) return '$d days ago';
    return 'In ${-d} days';
  }

  /// "Today · Wed 8 Oct", "Yesterday · Tue 7 Oct" or just "Mon 6 Oct".
  static String sheetDate(int key, int todayKey) {
    final d = DayKeys.daysBetween(key, todayKey);
    final date = weekdayDayMonth(key);
    if (d == 0) return 'Today · $date';
    if (d == 1) return 'Yesterday · $date';
    return date;
  }

  /// Trims trailing zeros: 60 → "60", 62.5 → "62.5", 61.25 → "61.25".
  static String number(double value, {int maxDecimals = 2}) {
    var s = value.toStringAsFixed(maxDecimals);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    }
    return s;
  }

  /// "45 min", "1 h 15 min"
  static String duration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60, m = minutes % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  /// "1:30" for seconds-based sets.
  static String clock(int seconds) {
    final m = seconds ~/ 60, s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  static String plural(int n, String one, [String? many]) => '$n ${n == 1 ? one : (many ?? '${one}s')}';
}
