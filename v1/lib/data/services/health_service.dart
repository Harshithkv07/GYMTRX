import 'package:flutter/services.dart';

import '../../logic/health_match.dart';

enum HealthStatus { available, needsUpdate, unavailable }

/// Health Connect permission names.
abstract final class HealthPermissions {
  static const _p = 'android.permission.health.';
  static const steps = '${_p}READ_STEPS';
  static const heartRate = '${_p}READ_HEART_RATE';
  static const calories = '${_p}READ_ACTIVE_CALORIES_BURNED';
  static const sleep = '${_p}READ_SLEEP';
  static const readWorkouts = '${_p}READ_EXERCISE';
  static const writeWorkouts = '${_p}WRITE_EXERCISE';
  static const readWeight = '${_p}READ_WEIGHT';
  static const writeWeight = '${_p}WRITE_WEIGHT';
  static const history = '${_p}READ_HEALTH_DATA_HISTORY';

  /// Without a watch: steps, nothing else.
  static const noWatch = [steps];

  /// With a watch or band.
  static const watch = [
    steps,
    heartRate,
    calories,
    sleep,
    readWorkouts,
    writeWorkouts,
    readWeight,
    writeWeight,
    history,
  ];
}

typedef HealthStats = ({int? avgHr, int? maxHr, int? kcal, List<String> origins});

/// Dart side of the `gymtrx/health` channel (see HealthBridge.kt).
class HealthService {
  const HealthService();

  static const _channel = MethodChannel('gymtrx/health');

  Future<HealthStatus> status() async {
    try {
      return switch (await _channel.invokeMethod<String>('status')) {
        'available' => HealthStatus.available,
        'update' => HealthStatus.needsUpdate,
        _ => HealthStatus.unavailable,
      };
    } on Object {
      return HealthStatus.unavailable;
    }
  }

  Future<void> openInstall() => _channel.invokeMethod('openInstall');

  Future<void> openSettings() => _channel.invokeMethod('openSettings');

  /// Shows Health Connect's own permission screen; returns what's granted.
  Future<Set<String>> request(List<String> permissions) async => {
    ...?await _channel.invokeListMethod<String>('request', permissions),
  };

  Future<Set<String>> granted() async {
    try {
      return {...?await _channel.invokeListMethod<String>('granted')};
    } on PlatformException {
      return const {};
    }
  }

  Future<String?> appLabel(String package) => _channel.invokeMethod<String>('appLabel', package);

  /// Steps per day for days in [fromDay, toDay).
  Future<Map<int, int>> dailySteps(int fromDay, int toDay) async {
    final rows = await _channel.invokeListMethod<Map>('dailySteps', {'fromDay': fromDay, 'toDay': toDay}) ?? const [];
    return {for (final r in rows) r['day'] as int: (r['steps'] as num).toInt()};
  }

  Future<List<Window>> sleep(DateTime from, DateTime to) async {
    final rows = await _channel.invokeListMethod<Map>('sleep', _range(from, to)) ?? const [];
    return [for (final r in rows) (start: _time(r['start']), end: _time(r['end']))];
  }

  /// Workouts other apps recorded (never GYMTRX's own).
  Future<List<HealthWorkout>> workouts(DateTime from, DateTime to) async {
    final rows = await _channel.invokeListMethod<Map>('workouts', _range(from, to)) ?? const [];
    return [
      for (final r in rows)
        (
          start: _time(r['start']),
          end: _time(r['end']),
          type: (r['type'] as num).toInt(),
          title: r['title'] as String?,
          origin: r['origin'] as String? ?? '',
        ),
    ];
  }

  Future<HealthStats> sessionStats(DateTime from, DateTime to) async {
    final r = await _channel.invokeMapMethod<String, Object?>('sessionStats', _range(from, to)) ?? const {};
    return (
      avgHr: (r['avgHr'] as num?)?.toInt(),
      maxHr: (r['maxHr'] as num?)?.toInt(),
      kcal: (r['kcal'] as num?)?.round(),
      origins: [...(r['origins'] as List? ?? const []).cast<String>()],
    );
  }

  Future<List<(DateTime, int)>> heartRate(DateTime from, DateTime to) async {
    final rows = await _channel.invokeListMethod<List>('heartRate', _range(from, to)) ?? const [];
    return [for (final r in rows) (_time(r[0]), (r[1] as num).toInt())];
  }

  /// Weigh-ins other apps (a smart scale, say) wrote since [from].
  Future<List<({DateTime time, double kg, String origin})>> weights(DateTime from) async {
    final rows = await _channel.invokeListMethod<Map>('weights', {'from': from.millisecondsSinceEpoch}) ?? const [];
    return [
      for (final r in rows)
        (time: _time(r['time']), kg: (r['kg'] as num).toDouble(), origin: r['origin'] as String? ?? ''),
    ];
  }

  Future<void> upsertWorkout({
    required String id,
    required int version,
    required DateTime start,
    required DateTime end,
    String? title,
    String? notes,
  }) => _channel.invokeMethod('upsertWorkout', {
    'id': id,
    'version': version,
    'start': start.millisecondsSinceEpoch,
    'end': end.millisecondsSinceEpoch,
    'title': title,
    'notes': notes,
  });

  Future<void> upsertWeight({required String id, required int version, required DateTime time, required double kg}) =>
      _channel.invokeMethod('upsertWeight', {
        'id': id,
        'version': version,
        'time': time.millisecondsSinceEpoch,
        'kg': kg,
      });

  /// Deletes records GYMTRX wrote, by its own ids. [type] is 'workout' or 'weight'.
  Future<void> delete(String type, List<String> ids) =>
      ids.isEmpty ? Future.value() : _channel.invokeMethod('delete', {'type': type, 'ids': ids});

  static Map<String, int> _range(DateTime from, DateTime to) => {
    'from': from.millisecondsSinceEpoch,
    'to': to.millisecondsSinceEpoch,
  };

  static DateTime _time(Object? ms) => DateTime.fromMillisecondsSinceEpoch((ms as num).toInt());
}
