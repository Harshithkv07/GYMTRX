/// A calendar day stored as an int `yyyymmdd` in local time, e.g. 20261008.
/// Timezone-proof, sortable and cheap to compare, so it is the only date
/// representation used for entries.
abstract final class DayKeys {
  static int of(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  static DateTime toDate(int key) => DateTime(year(key), month(key), day(key));

  static int year(int key) => key ~/ 10000;
  static int month(int key) => key ~/ 100 % 100;
  static int day(int key) => key % 100;

  static int today([DateTime? now]) => of(now ?? DateTime.now());

  /// The day a new entry belongs to. Before [dayStartHour] it still counts as
  /// the previous day, so logging at 00:30 lands on last evening's session.
  static int logicalToday({DateTime? now, int dayStartHour = 4}) {
    final n = now ?? DateTime.now();
    return n.hour < dayStartHour ? of(DateTime(n.year, n.month, n.day - 1)) : of(n);
  }

  static int addDays(int key, int days) =>
      of(DateTime(year(key), month(key), day(key) + days));

  /// Whole days from [from] to [to]; positive when [to] is later.
  static int daysBetween(int from, int to) => DateTime.utc(year(to), month(to), day(to))
      .difference(DateTime.utc(year(from), month(from), day(from)))
      .inDays;

  static int monthStart(int year, int month) => year * 10000 + month * 100 + 1;

  static int monthEnd(int year, int month) => of(DateTime(year, month + 1, 0));

  static int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  /// ISO weekday, 1 = Monday … 7 = Sunday.
  static int weekday(int key) => toDate(key).weekday;

  /// The first day of the week holding [key], for weeks starting on [weekStart].
  static int weekStartOf(int key, int weekStart) => addDays(key, -((weekday(key) - weekStart + 7) % 7));
}

/// A calendar month, used to page the calendar.
typedef YearMonth = ({int year, int month});

extension YearMonthX on YearMonth {
  YearMonth shift(int months) {
    final index = year * 12 + (month - 1) + months;
    return (year: index ~/ 12, month: index % 12 + 1);
  }

  /// Months from [other] to this one.
  int monthsSince(YearMonth other) => (year * 12 + month) - (other.year * 12 + other.month);

  bool contains(int dayKey) => DayKeys.year(dayKey) == year && DayKeys.month(dayKey) == month;

  int get startKey => DayKeys.monthStart(year, month);
  int get endKey => DayKeys.monthEnd(year, month);
}

YearMonth yearMonthOf(int dayKey) => (year: DayKeys.year(dayKey), month: DayKeys.month(dayKey));
