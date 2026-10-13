import '../core/utils/day_key.dart';

/// A workout another app (usually a watch) wrote to Health Connect.
typedef HealthWorkout = ({DateTime start, DateTime end, int type, String? title, String origin});

/// A time span.
typedef Window = ({DateTime start, DateTime end});

/// Health Connect exercise types that look like a gym session. Matched
/// first; anything else (a walk to the gym, say) only if nothing better.
const gymWorkoutTypes = {
  70, // strength training
  81, // weightlifting
  13, // calisthenics
  36, // HIIT
  10, // boot camp
  26, // exercise class
  0, // other workout
  9, // stationary bike
  25, // elliptical
  54, // rowing machine
  57, // treadmill
  69, // stair climber
};

/// The hours that belong to [dayKey] when the day starts at [dayStartHour]:
/// a 1 AM session counts toward the previous day.
Window logicalDayWindow(int dayKey, int dayStartHour) {
  final start = DayKeys.toDate(dayKey).add(Duration(hours: dayStartHour));
  return (start: start, end: start.add(const Duration(days: 1)));
}

Duration _overlap(Window a, Window b) {
  final start = a.start.isAfter(b.start) ? a.start : b.start;
  final end = a.end.isBefore(b.end) ? a.end : b.end;
  return end.isAfter(start) ? end.difference(start) : Duration.zero;
}

/// The watch workout that best stands for a gym session on a day:
/// - if [startedAt] is known, the gym-type workout overlapping it the most;
/// - otherwise the longest gym-type workout in the day;
/// - failing both, the longest workout of any type over 10 minutes.
HealthWorkout? pickWorkout(List<HealthWorkout> workouts, Window day, {DateTime? startedAt}) {
  final inDay = [
    for (final w in workouts)
      if (_overlap((start: w.start, end: w.end), day) > Duration.zero) w,
  ];
  if (inDay.isEmpty) return null;
  Duration length(HealthWorkout w) => w.end.difference(w.start);

  final gym = [
    for (final w in inDay)
      if (gymWorkoutTypes.contains(w.type)) w,
  ];
  if (gym.isNotEmpty) {
    if (startedAt != null) {
      final around = (
        start: startedAt.subtract(const Duration(minutes: 30)),
        end: startedAt.add(const Duration(hours: 3)),
      );
      gym.sort(
        (a, b) =>
            _overlap((start: b.start, end: b.end), around).compareTo(_overlap((start: a.start, end: a.end), around)),
      );
      if (_overlap((start: gym.first.start, end: gym.first.end), around) > Duration.zero) return gym.first;
    }
    gym.sort((a, b) => length(b).compareTo(length(a)));
    return gym.first;
  }
  final any = [
    for (final w in inDay)
      if (length(w) >= const Duration(minutes: 10)) w,
  ]..sort((a, b) => length(b).compareTo(length(a)));
  return any.firstOrNull;
}

/// The span heart rate and calories are read for: a matched watch workout,
/// else the session's own start time plus its duration (an hour if none).
/// Null when neither is known.
Window? sessionWindow({HealthWorkout? workout, DateTime? startedAt, int? durationMin}) {
  if (workout != null) return (start: workout.start, end: workout.end);
  if (startedAt == null) return null;
  return (start: startedAt, end: startedAt.add(Duration(minutes: durationMin ?? 60)));
}

/// Sleep per morning: each sleep span counts toward the day it ended on.
Map<int, int> sleepByMorning(Iterable<Window> spans) {
  final out = <int, int>{};
  for (final s in spans) {
    final day = DayKeys.of(s.end);
    out[day] = (out[day] ?? 0) + s.end.difference(s.start).inMinutes;
  }
  return out;
}

/// A readable name for the app that wrote a record.
String healthAppName(String package, {String? label}) =>
    label ??
    const {
      'com.sec.android.app.shealth': 'Samsung Health',
      'com.google.android.apps.fitness': 'Google Fit',
      'com.fitbit.FitbitMobile': 'Fitbit',
      'com.google.android.apps.healthdata': 'Health Connect',
      'com.mi.health': 'Mi Fitness',
      'com.xiaomi.wearable': 'Mi Fitness',
      'com.xiaomi.hm.health': 'Zepp Life',
      'com.huami.watch.hmwatchmanager': 'Zepp',
      'com.garmin.android.apps.connectmobile': 'Garmin Connect',
      'com.ouraring.oura': 'Oura',
      'com.whoop.android': 'WHOOP',
      'com.withings.wiscale2': 'Withings',
      'com.nothing.smartcenter': 'Nothing X',
      'com.coros.coros': 'COROS',
      'com.polar.polarflow': 'Polar Flow',
      'com.heytap.health.international': 'OHealth',
      'com.huawei.health': 'Huawei Health',
      'com.noisefit': 'NoiseFit',
      'com.boat.crest': 'boAt Crest',
      'com.amazfit.android': 'Zepp',
      'com.strava': 'Strava',
    }[package] ??
    'your watch app';
