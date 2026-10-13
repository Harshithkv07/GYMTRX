import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/day_key.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../data/repositories/health_repository.dart';
import '../../data/services/health_service.dart';
import '../health_match.dart';
import 'data_providers.dart';
import 'settings_provider.dart';

final healthServiceProvider = Provider<HealthService>((ref) => const HealthService());
final healthRepoProvider = Provider((ref) => HealthRepository(ref.watch(databaseProvider)));

/// Steps and sleep by day, as last read from Health Connect.
final dailyHealthProvider = StreamProvider<Map<int, DailyHealthData>>(
  (ref) => ref.watch(healthRepoProvider).watchDaily(),
);

/// Watch numbers for one session (by session id).
final sessionHealthProvider = StreamProvider.autoDispose.family<SessionHealthData?, int>(
  (ref, sessionId) => ref.watch(healthRepoProvider).watchSession(sessionId),
);

/// Heart-rate samples for a span, read live (not cached).
final heartRateProvider = FutureProvider.autoDispose.family<List<(DateTime, int)>, Window>((ref, w) async {
  try {
    return await ref.read(healthServiceProvider).heartRate(w.start, w.end);
  } on Object {
    return const [];
  }
});

/// "Samsung Health" for com.sec.android.app.shealth, and so on.
final healthAppNameProvider = FutureProvider.family<String, String>((ref, package) async {
  String? label;
  try {
    label = await ref.read(healthServiceProvider).appLabel(package);
  } on Object {
    label = null;
  }
  return healthAppName(package, label: label);
});

/// Keeps GYMTRX and Health Connect in step. Reads happen when the app opens
/// or comes back, when a month is shown and when a day is opened; writes
/// follow edits a moment later. Everything is skipped quietly when Health
/// Connect is off, unavailable or not allowed. The state counts finished
/// syncs.
class HealthSync extends Notifier<int> {
  static const _writtenKey = 'healthWritten';

  final _fetchedMonths = <int, DateTime>{};
  var _running = false;
  Timer? _pushTimer;

  HealthService get _hc => ref.read(healthServiceProvider);
  HealthRepository get _repo => ref.read(healthRepoProvider);
  AppDatabase get _db => ref.read(databaseProvider);
  AppSettings get _s => ref.read(settingsProvider);

  @override
  int build() {
    ref.onDispose(() => _pushTimer?.cancel());
    ref.listen(
      settingsProvider.select(
        (s) => (s.healthOn, s.healthWatch, s.healthHeart, s.healthSleep, s.healthWeightsIn, s.healthWrite),
      ),
      (_, _) {
        _fetchedMonths.clear();
        syncAll();
      },
    );
    ref.listen(summariesProvider, (_, _) => _schedulePush());
    ref.listen(bodyWeightsProvider, (_, _) => _schedulePush());
    return 0;
  }

  /// Everything: recent days, recent sessions, weigh-ins, then writes.
  Future<void> syncAll() async {
    if (!_s.healthOn || _running) return;
    _running = true;
    try {
      final today = DayKeys.today();
      await _daily(DayKeys.addDays(today, -35), DayKeys.addDays(today, 1));
      if (_s.watchHealth) {
        if (_s.healthWeightsIn) await _importWeights();
        if (_s.healthHeart) await _sessions();
        if (_s.healthWrite) await _push();
      }
      state++;
    } on Object {
      // Quiet: the next open tries again.
    } finally {
      _running = false;
    }
  }

  /// Steps (and sleep) for a month being looked at, at most once an hour.
  Future<void> ensureMonth(YearMonth month) async {
    if (!_s.healthOn) return;
    final today = DayKeys.today();
    if (month.startKey > today) return;
    final last = _fetchedMonths[month.startKey];
    if (last != null && DateTime.now().difference(last) < const Duration(hours: 1)) return;
    _fetchedMonths[month.startKey] = DateTime.now();
    try {
      final end = DayKeys.addDays(month.endKey, 1);
      await _daily(month.startKey, end < DayKeys.addDays(today, 1) ? end : DayKeys.addDays(today, 1));
    } on Object {
      _fetchedMonths.remove(month.startKey);
    }
  }

  /// Fresh watch numbers for one day's session (when its details are opened).
  Future<void> refreshDay(int dayKey) async {
    if (!_s.watchHealth || !_s.healthHeart) return;
    final session = await (_db.select(_db.sessions)..where((x) => x.dayKey.equals(dayKey))).getSingleOrNull();
    if (session == null) return;
    try {
      final day = logicalDayWindow(dayKey, _s.dayStartHour);
      await _session(session, await _hc.workouts(day.start, day.end));
    } on Object {
      // Keep what's cached.
    }
  }

  Future<void> _daily(int fromDay, int toDay) async {
    if (toDay <= fromDay) return;
    final steps = await _hc.dailySteps(fromDay, toDay);
    Map<int, int>? sleep;
    if (_s.watchHealth && _s.healthSleep) {
      final from = DayKeys.toDate(fromDay).subtract(const Duration(hours: 12));
      try {
        sleep = sleepByMorning(await _hc.sleep(from, DayKeys.toDate(toDay)));
      } on Object {
        sleep = null;
      }
    }
    await _repo.putDaily(
      steps: steps,
      sleep: sleep,
      days: [for (var d = fromDay; d < toDay; d = DayKeys.addDays(d, 1)) d],
    );
  }

  Future<void> _sessions() async {
    final entries = ref.read(summariesProvider).value ?? const <EntrySummary>[];
    final today = DayKeys.today();
    final recent = [
      for (final e in entries)
        if (e.dayKey >= DayKeys.addDays(today, -30)) e,
    ];
    if (recent.isEmpty) return;
    final cached = await _repo.sessionsById();
    final hour = _s.dayStartHour;
    // Newest first: one read covers them all.
    final workouts = await _hc.workouts(
      logicalDayWindow(recent.last.dayKey, hour).start,
      logicalDayWindow(recent.first.dayKey, hour).end,
    );
    for (final e in recent) {
      // Older days are settled once read; the last few may still be syncing from the watch.
      if (cached.containsKey(e.sessionId) && e.dayKey < DayKeys.addDays(today, -2)) continue;
      final session = await (_db.select(_db.sessions)..where((x) => x.id.equals(e.sessionId))).getSingleOrNull();
      if (session != null) await _session(session, workouts);
    }
  }

  Future<void> _session(Session session, List<HealthWorkout> workouts) async {
    final day = logicalDayWindow(session.dayKey, _s.dayStartHour);
    final workout = pickWorkout(workouts, day, startedAt: session.startedAt);
    final window = sessionWindow(workout: workout, startedAt: session.startedAt, durationMin: session.durationMin);
    if (window == null) {
      await _repo.removeSession(session.id);
      return;
    }
    // The watch knows when the session was: fill in what wasn't typed.
    if (workout != null && (session.startedAt == null || session.durationMin == null)) {
      await (_db.update(_db.sessions)..where((x) => x.id.equals(session.id))).write(
        SessionsCompanion(
          startedAt: session.startedAt == null ? Value(workout.start) : const Value.absent(),
          durationMin: session.durationMin == null
              ? Value(workout.end.difference(workout.start).inMinutes)
              : const Value.absent(),
        ),
      );
    }
    final stats = await _hc.sessionStats(window.start, window.end);
    await _repo.putSession(
      SessionHealthCompanion.insert(
        sessionId: Value(session.id),
        startAt: window.start,
        endAt: window.end,
        avgHr: Value(stats.avgHr),
        maxHr: Value(stats.maxHr),
        activeKcal: Value(stats.kcal),
        source: Value(workout?.origin),
        fetchedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _importWeights() async {
    final readings = await _hc.weights(DateTime.now().subtract(const Duration(days: 60)));
    // The latest reading of each day.
    final byDay = <int, ({DateTime time, double kg, String origin})>{};
    for (final r in readings) {
      final day = DayKeys.of(r.time);
      if (byDay[day] == null || r.time.isAfter(byDay[day]!.time)) byDay[day] = r;
    }
    final repo = ref.read(bodyWeightRepoProvider);
    for (final MapEntry(key: day, value: r) in byDay.entries) {
      await repo.importFrom(r.origin, day, r.kg, r.time);
    }
  }

  void _schedulePush() {
    if (!_s.watchHealth || !_s.healthWrite) return;
    _pushTimer?.cancel();
    _pushTimer = Timer(const Duration(seconds: 3), () async {
      try {
        await _push();
      } on Object {
        // Retried on the next change or open.
      }
    });
  }

  /// Writes sessions with a start time (unless a watch already recorded that
  /// workout) and weigh-ins typed in GYMTRX; deletes what no longer exists.
  Future<void> _push() async {
    final prefs = ref.read(prefsProvider);
    final written = <String, int>{
      for (final MapEntry(:key, :value) in ((jsonDecode(prefs.getString(_writtenKey) ?? '{}') as Map)).entries)
        key as String: value as int,
    };
    final since = DayKeys.addDays(DayKeys.today(), -60);
    final health = await _repo.sessionsById();
    final groups = ref.read(groupsByIdProvider);
    final entries = {for (final e in ref.read(summariesProvider).value ?? const <EntrySummary>[]) e.sessionId: e};

    final wanted = <String, int>{};
    final sessions = await (_db.select(
      _db.sessions,
    )..where((x) => x.dayKey.isBiggerOrEqualValue(since) & x.startedAt.isNotNull())).get();
    for (final s in sessions) {
      if (health[s.id]?.source != null) continue; // the watch already has it
      final id = 'gymtrx-session-${s.dayKey}';
      final version = s.updatedAt.millisecondsSinceEpoch;
      wanted[id] = version;
      if (written[id] == version) continue;
      final names = [for (final g in entries[s.id]?.groupIds ?? const <int>[]) ?groups[g]]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      await _hc.upsertWorkout(
        id: id,
        version: version,
        start: s.startedAt!,
        end: s.startedAt!.add(Duration(minutes: s.durationMin ?? 60)),
        title: names.isEmpty ? 'Gym session' : names.map((g) => g.name).join(' · '),
        notes: s.note,
      );
    }

    final weights = await (_db.select(
      _db.bodyWeights,
    )..where((w) => w.dayKey.isBiggerOrEqualValue(since) & w.source.isNull())).get();
    for (final w in weights) {
      final id = 'gymtrx-weight-${w.dayKey}';
      final version = w.recordedAt.millisecondsSinceEpoch;
      wanted[id] = version;
      if (written[id] == version) continue;
      // Logged that day: keep its time. Logged later (or earlier): morning of that day.
      final time = DayKeys.of(w.recordedAt) == w.dayKey
          ? w.recordedAt
          : DayKeys.toDate(w.dayKey).add(const Duration(hours: 8));
      await _hc.upsertWeight(id: id, version: version, time: time, kg: w.weightKg);
    }

    final gone = [
      for (final id in written.keys)
        if (!wanted.containsKey(id)) id,
    ];
    await _hc.delete('workout', [
      for (final id in gone)
        if (id.startsWith('gymtrx-session-')) id,
    ]);
    await _hc.delete('weight', [
      for (final id in gone)
        if (id.startsWith('gymtrx-weight-')) id,
    ]);
    await prefs.setString(_writtenKey, jsonEncode(wanted));
  }

  /// Forgets everything read from Health Connect and stops syncing.
  Future<void> disconnect() async {
    _fetchedMonths.clear();
    await _repo.clear();
    await ref.read(prefsProvider).remove(_writtenKey);
  }
}

final healthSyncProvider = NotifierProvider<HealthSync, int>(HealthSync.new);
