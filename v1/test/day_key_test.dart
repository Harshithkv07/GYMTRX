import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/core/utils/day_key.dart';

void main() {
  test('round-trips dates', () {
    expect(DayKeys.of(DateTime(2026, 10, 8, 23, 59)), 20261008);
    expect(DayKeys.toDate(20261008), DateTime(2026, 10, 8));
    expect(DayKeys.year(20261008), 2026);
    expect(DayKeys.month(20261008), 10);
    expect(DayKeys.day(20261008), 8);
  });

  test('late-night logging belongs to the previous day', () {
    expect(DayKeys.logicalToday(now: DateTime(2026, 10, 9, 0, 30)), 20261008);
    expect(DayKeys.logicalToday(now: DateTime(2026, 10, 9, 3, 59)), 20261008);
    expect(DayKeys.logicalToday(now: DateTime(2026, 10, 9, 4, 0)), 20261009);
    expect(DayKeys.logicalToday(now: DateTime(2026, 10, 9, 0, 30), dayStartHour: 0), 20261009);
    // Crosses a month and a year boundary.
    expect(DayKeys.logicalToday(now: DateTime(2027, 1, 1, 1)), 20261231);
  });

  test('day arithmetic', () {
    expect(DayKeys.addDays(20261031, 1), 20261101);
    expect(DayKeys.addDays(20260301, -1), 20260228);
    expect(DayKeys.daysBetween(20261001, 20261008), 7);
    expect(DayKeys.daysBetween(20261008, 20261001), -7);
    expect(DayKeys.daysBetween(20261231, 20270101), 1);
    expect(DayKeys.monthEnd(2028, 2), 20280229);
    expect(DayKeys.daysInMonth(2026, 2), 28);
  });

  test('year-month paging', () {
    const oct = (year: 2026, month: 10);
    expect(oct.shift(3), (year: 2027, month: 1));
    expect(oct.shift(-10), (year: 2025, month: 12));
    expect(oct.shift(3).monthsSince(oct), 3);
    expect(oct.contains(20261008), isTrue);
    expect(oct.contains(20261108), isFalse);
  });
}
