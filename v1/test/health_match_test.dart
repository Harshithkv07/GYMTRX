import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrx/logic/health_match.dart';

void main() {
  HealthWorkout w(DateTime start, int minutes, {int type = 70, String origin = 'com.sec.android.app.shealth'}) =>
      (start: start, end: start.add(Duration(minutes: minutes)), type: type, title: null, origin: origin);

  group('logical day', () {
    test('a day runs from the day-start hour to the same hour next day', () {
      final d = logicalDayWindow(20261010, 4);
      expect(d.start, DateTime(2026, 10, 10, 4));
      expect(d.end, DateTime(2026, 10, 11, 4));
    });
  });

  group('picking the watch workout', () {
    final day = logicalDayWindow(20261010, 4);

    test('prefers a gym-type workout over a longer walk', () {
      final walk = w(DateTime(2026, 10, 10, 7), 90, type: 79);
      final gym = w(DateTime(2026, 10, 10, 18), 55);
      expect(pickWorkout([walk, gym], day), gym);
    });

    test('with a start time, the one around it wins', () {
      final morning = w(DateTime(2026, 10, 10, 7), 80);
      final evening = w(DateTime(2026, 10, 10, 18, 5), 50);
      expect(pickWorkout([morning, evening], day, startedAt: DateTime(2026, 10, 10, 18)), evening);
      expect(pickWorkout([morning, evening], day), morning, reason: 'otherwise the longest');
    });

    test('a 1 AM session belongs to the day before', () {
      final late = w(DateTime(2026, 10, 11, 1), 45);
      expect(pickWorkout([late], day), late);
      expect(pickWorkout([late], logicalDayWindow(20261011, 4)), isNull);
    });

    test('nothing that day, or only short other activity: none', () {
      expect(pickWorkout([], day), isNull);
      expect(pickWorkout([w(DateTime(2026, 10, 10, 9), 6, type: 79)], day), isNull);
    });
  });

  group('session window', () {
    test('a watch workout sets it; else the start time plus duration', () {
      final gym = w(DateTime(2026, 10, 10, 18), 55);
      expect(sessionWindow(workout: gym), (start: gym.start, end: gym.end));
      final typed = DateTime(2026, 10, 10, 18);
      expect(sessionWindow(startedAt: typed, durationMin: 40), (start: typed, end: DateTime(2026, 10, 10, 18, 40)));
      expect(sessionWindow(startedAt: typed)!.end, DateTime(2026, 10, 10, 19), reason: 'an hour when no duration');
      expect(sessionWindow(), isNull);
    });
  });

  test('sleep counts toward the morning it ended', () {
    final nights = sleepByMorning([
      (start: DateTime(2026, 10, 9, 23, 30), end: DateTime(2026, 10, 10, 6, 45)),
      (start: DateTime(2026, 10, 10, 14), end: DateTime(2026, 10, 10, 14, 30)), // a nap
    ]);
    expect(nights, {20261010: 435 + 30});
  });

  test('app names', () {
    expect(healthAppName('com.sec.android.app.shealth'), 'Samsung Health');
    expect(healthAppName('com.example.unknown'), 'your watch app');
    expect(healthAppName('com.example.unknown', label: 'Example'), 'Example');
  });
}
