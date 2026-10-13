import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/day_key.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../presentation/widgets/toast.dart';
import '../features.dart';
import 'data_providers.dart';
import 'progress_providers.dart';
import 'settings_provider.dart';

/// Records when a goal is reached (and un-records it if the set that reached
/// it is edited away). Celebrates only fresh ones, so restoring a backup or
/// opening the app after a while doesn't fire a stack of toasts. Watch this
/// provider once (the shell does) to start it.
final goalWatchProvider = Provider<void>((ref) {
  ref.listen(goalProgressProvider, (_, progress) {
    final loaded =
        ref.read(goalsProvider).hasValue &&
        ref.read(setRecordsProvider).hasValue &&
        ref.read(bodyWeightsProvider).hasValue;
    if (!loaded) return;
    final repo = ref.read(goalRepoProvider);
    final today = ref.read(logicalTodayProvider);
    final unit = ref.read(settingsProvider).unit;

    final celebrate = ref.read(settingsProvider).has(AppFeature.goals);

    for (final p in progress) {
      final stored = p.goal.achievedDayKey;
      if (p.achieved && stored == null) {
        repo.setAchieved(p.goal.id, p.achievedDay);
        if (celebrate && p.achievedDay! >= DayKeys.addDays(today, -1)) {
          Haptics.celebrate();
          final what = switch (p.goal.kind) {
            GoalKind.lift =>
              '${p.exercise?.name ?? 'Lift'} ${Units.format(p.goal.targetKg, unit)}'
                  '${p.goal.targetReps == null ? '' : ' × ${p.goal.targetReps}'}',
            GoalKind.bodyWeight => 'Body weight ${Units.format(p.goal.targetKg, unit, maxDecimals: 1)}',
          };
          Toasts.show('Goal reached · $what', duration: const Duration(seconds: 5));
        }
      } else if (!p.achieved && stored != null) {
        repo.setAchieved(p.goal.id, null);
      }
    }
  }, fireImmediately: true);
});
