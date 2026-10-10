import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/day_key.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../data/models/progress.dart';
import '../../data/repositories/body_weight_repository.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/repositories/photo_repository.dart';
import '../../data/repositories/program_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/services/photo_store.dart';
import 'settings_provider.dart';

/// Overridden in main() (and in tests with an in-memory database).
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError());

final sessionRepoProvider = Provider((ref) => SessionRepository(ref.watch(databaseProvider)));
final libraryRepoProvider = Provider((ref) => LibraryRepository(ref.watch(databaseProvider)));
final bodyWeightRepoProvider = Provider((ref) => BodyWeightRepository(ref.watch(databaseProvider)));
final goalRepoProvider = Provider((ref) => GoalRepository(ref.watch(databaseProvider)));
final programRepoProvider = Provider((ref) => ProgramRepository(ref.watch(databaseProvider)));

/// Overridden in main() (and in tests with a temp directory).
final photoStoreProvider = Provider<PhotoStore>((ref) => throw UnimplementedError());
final photoRepoProvider = Provider(
  (ref) => PhotoRepository(ref.watch(databaseProvider), ref.watch(photoStoreProvider)),
);

/// Today's calendar day, refreshed at midnight and whenever the app resumes.
class TodayNotifier extends Notifier<int> {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    _schedule();
    return DayKeys.today();
  }

  void _schedule() {
    _timer?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    _timer = Timer(next.difference(now), refresh);
  }

  void refresh() {
    final today = DayKeys.today();
    if (today != state) state = today;
    _schedule();
  }
}

final todayProvider = NotifierProvider<TodayNotifier, int>(TodayNotifier.new);

/// The day new entries belong to, honouring the "day starts at" setting.
/// Streaks, goals, program days and reminders all count against this.
class LogicalTodayNotifier extends Notifier<int> {
  Timer? _timer;

  int get _hour => ref.read(settingsProvider).dayStartHour;

  @override
  int build() {
    ref.watch(settingsProvider.select((s) => s.dayStartHour));
    ref.onDispose(() => _timer?.cancel());
    _schedule();
    return DayKeys.logicalToday(dayStartHour: _hour);
  }

  void _schedule() {
    _timer?.cancel();
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, _hour, 0, 1);
    if (!next.isAfter(now)) next = DateTime(now.year, now.month, now.day + 1, _hour, 0, 1);
    _timer = Timer(next.difference(now), refresh);
  }

  void refresh() {
    final today = DayKeys.logicalToday(dayStartHour: _hour);
    if (today != state) state = today;
    _schedule();
  }
}

final logicalTodayProvider = NotifierProvider<LogicalTodayNotifier, int>(LogicalTodayNotifier.new);

// ------------------------------------------------------------------ entries

final summariesProvider = StreamProvider<List<EntrySummary>>(
  (ref) => ref.watch(sessionRepoProvider).watchSummaries(),
);

/// Entries keyed by day for O(1) calendar lookups.
final summariesByDayProvider = Provider<Map<int, EntrySummary>>((ref) {
  final list = ref.watch(summariesProvider).value ?? const <EntrySummary>[];
  return {for (final e in list) e.dayKey: e};
});

final entryProvider = StreamProvider.autoDispose.family<EntryDetail?, int>(
  (ref, dayKey) => ref.watch(sessionRepoProvider).watchEntry(dayKey),
);

/// Every logged set, oldest first, feeding personal-record detection.
final setRecordsProvider = StreamProvider<List<SetRecordRow>>(
  (ref) => ref.watch(sessionRepoProvider).watchSetRecords(),
);

// ------------------------------------------------------------------ progress

final goalsProvider = StreamProvider<List<Goal>>((ref) => ref.watch(goalRepoProvider).watchAll());

/// Progress photos, newest first.
final photosProvider = StreamProvider<List<ProgressPhoto>>((ref) => ref.watch(photoRepoProvider).watchAll());

final photosByDayProvider = Provider<Map<int, List<ProgressPhoto>>>((ref) {
  final map = <int, List<ProgressPhoto>>{};
  for (final p in ref.watch(photosProvider).value ?? const <ProgressPhoto>[]) {
    map.putIfAbsent(p.dayKey, () => []).add(p);
  }
  return map;
});

/// Training days keyed by ISO weekday; empty when there's no program.
final programProvider = StreamProvider<Map<int, ProgramDayPlan>>(
  (ref) => ref.watch(programRepoProvider).watchProgram(),
);

// ------------------------------------------------------------------ library

final groupsProvider = StreamProvider<List<MuscleGroup>>((ref) => ref.watch(libraryRepoProvider).watchGroups());

final groupsByIdProvider = Provider<Map<int, MuscleGroup>>((ref) {
  final groups = ref.watch(groupsProvider).value ?? const <MuscleGroup>[];
  return {for (final g in groups) g.id: g};
});

final visibleGroupsProvider = Provider<List<MuscleGroup>>((ref) {
  final groups = ref.watch(groupsProvider).value ?? const <MuscleGroup>[];
  return [for (final g in groups) if (!g.hidden) g];
});

final exercisesProvider = StreamProvider<List<Exercise>>((ref) => ref.watch(libraryRepoProvider).watchExercises());

final exercisesByIdProvider = Provider<Map<int, Exercise>>((ref) {
  final list = ref.watch(exercisesProvider).value ?? const <Exercise>[];
  return {for (final e in list) e.id: e};
});

/// Exercises the user has logged, most recently done first.
final exerciseStatsProvider = StreamProvider<List<ExerciseStat>>((ref) {
  final byId = ref.watch(exercisesByIdProvider);
  return ref.watch(sessionRepoProvider).watchExerciseUsage().map(
    (rows) => [
      for (final r in rows)
        if (byId[r.exerciseId] case final ex?) ExerciseStat(exercise: ex, count: r.count, lastDayKey: r.lastDayKey),
    ],
  );
});

final exerciseHistoryProvider = StreamProvider.autoDispose.family<List<ExerciseHistoryItem>, int>(
  (ref, exerciseId) => ref.watch(sessionRepoProvider).watchExerciseHistory(exerciseId),
);

// ------------------------------------------------------------------ body weight

final bodyWeightsProvider = StreamProvider<List<BodyWeight>>((ref) => ref.watch(bodyWeightRepoProvider).watchAll());

final bodyWeightByDayProvider = Provider<Map<int, BodyWeight>>((ref) {
  final list = ref.watch(bodyWeightsProvider).value ?? const <BodyWeight>[];
  return {for (final w in list) w.dayKey: w};
});

/// Up to [limit] distinct muscle-group combinations from the latest entries,
/// offered as one-tap chips when logging (e.g. "Chest · Triceps").
List<List<int>> recentGroupCombos(List<EntrySummary> newestFirst, Map<int, MuscleGroup> groups, {int limit = 4}) {
  final seen = <String>{};
  final out = <List<int>>[];
  for (final e in newestFirst) {
    final ids = [for (final id in e.groupIds) if (groups[id] != null) id]
      ..sort((a, b) => groups[a]!.sortOrder.compareTo(groups[b]!.sortOrder));
    if (ids.isEmpty || !seen.add(ids.join(','))) continue;
    out.add(ids);
    if (out.length == limit) break;
  }
  return out;
}
