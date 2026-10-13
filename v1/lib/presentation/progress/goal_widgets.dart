import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../logic/features.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/progress_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/progress_ring.dart';
import '../widgets/surface.dart';
import 'goal_sheets.dart';

/// Monthly sessions, lift targets and the body-weight target.
class GoalsCard extends ConsumerWidget {
  const GoalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showBodyGoal = ref.watch(settingsProvider.select((s) => s.has(AppFeature.bodyWeight)));
    final goals = [
      for (final g in ref.watch(goalProgressProvider))
        if (showBodyGoal || g.goal.kind != GoalKind.bodyWeight) g,
    ];
    final month = ref.watch(monthProgressProvider);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final today = ref.watch(logicalTodayProvider);

    if (goals.isEmpty && month.goal == 0) {
      return GtCard(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set a target', style: GtText.titleSmall),
            const SizedBox(height: GtSpace.xs),
            Text(
              'A lift to hit, a body weight to reach or sessions per month. Progress fills in as you log.',
              style: GtText.body.colored(GtColors.text2),
            ),
            const SizedBox(height: GtSpace.lg),
            GtButton(
              label: 'Add a goal',
              icon: GtIcons.target,
              kind: GtButtonKind.secondary,
              height: 44,
              onTap: () => addGoal(context, ref),
            ),
          ],
        ),
      );
    }

    final rows = <Widget>[
      if (month.goal > 0)
        _GoalRow(
          icon: GtIcons.calendar,
          title: '${Fmt.monthName(DayKeys.month(today))} sessions',
          subtitle: month.count >= month.goal
              ? '${month.count} logged · goal reached'
              : '${month.count} of ${month.goal} · ${month.goal - month.count} to go',
          value: month.count / month.goal,
          achieved: month.count >= month.goal,
          trailing: '${month.count}/${month.goal}',
          onTap: () => editMonthlyGoal(context, ref),
        ),
      for (final g in goals)
        switch (g.goal.kind) {
          GoalKind.lift => _GoalRow(
            icon: GtIcons.exercise,
            title: g.exercise?.name ?? 'Lift',
            subtitle: _liftSubtitle(g, unit),
            value: g.fraction,
            achieved: g.achieved,
            trailing: '${(g.fraction * 100).floor()}%',
            onTap: () => editLiftGoal(context, ref, existing: g.goal),
          ),
          GoalKind.bodyWeight => _GoalRow(
            icon: GtIcons.weight,
            title: 'Body weight · ${Units.format(g.goal.targetKg, unit, maxDecimals: 1)}',
            subtitle: _bodySubtitle(g, unit),
            value: g.fraction,
            achieved: g.achieved,
            trailing: '${(g.fraction * 100).floor()}%',
            onTap: () => editBodyWeightGoal(context, ref, existing: g.goal),
          ),
        },
    ];

    return GtCard(
      padding: const EdgeInsets.symmetric(vertical: GtSpace.xs),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(indent: GtSpace.lg + 40 + GtSpace.md),
            rows[i],
          ],
        ],
      ),
    );
  }

  static String _liftSubtitle(GoalProgress g, WeightUnit unit) {
    final reps = g.goal.targetReps;
    final target = '${Units.format(g.goal.targetKg, unit)}${reps == null ? '' : ' × $reps'}';
    if (g.achieved) return '$target · reached ${Fmt.dayMonth(g.achievedDay!)}';
    final best = g.currentKg;
    return best == null ? '$target · no sets yet' : '$target · best ${Units.format(best, unit)}';
  }

  static String _bodySubtitle(GoalProgress g, WeightUnit unit) {
    final current = g.currentKg;
    if (current == null) return 'Add a weigh-in to start';
    if (g.achieved) return 'Reached · now ${Units.format(current, unit, maxDecimals: 1)}';
    final toGo = (g.goal.targetKg - current).abs();
    return 'Now ${Units.format(current, unit, maxDecimals: 1)} · ${Units.format(toGo, unit, maxDecimals: 1)} to go';
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.achieved,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final bool achieved;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = achieved ? GtColors.gold : context.accent;
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: achieved ? GtColors.goldMuted : context.gt.accentMuted,
                shape: squircle(GtRadius.sm),
              ),
              child: Icon(achieved ? GtIcons.trophy : icon, size: 18, color: color),
            ),
            const SizedBox(width: GtSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GtText.body.weight(500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: GtSpace.sm),
                      Text(
                        trailing,
                        style: GtText.monoSmall.sized(12).colored(achieved ? GtColors.gold : GtColors.text2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GtText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: GtSpace.sm),
                  ProgressBar(value: value, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
