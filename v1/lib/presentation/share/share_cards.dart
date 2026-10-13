import 'package:flutter/material.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/models/entry.dart';
import '../body_map/body_map.dart';
import '../body_map/muscle_regions.dart';
import '../entry/entry_body_map.dart';
import '../widgets/brand_mark.dart';
import '../widgets/labels.dart';

/// Shared frame for every card: 4:5, dark, an accent glow and the wordmark.
class ShareFrame extends StatelessWidget {
  const ShareFrame({super.key, required this.child, this.glow});

  static const size = Size(360, 450);

  final Widget child;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final accent = glow ?? context.accent;
    // Opaque base first: a gradient replaces a BoxDecoration's colour, and the
    // exported PNG must not come out transparent.
    return SizedBox.fromSize(
      size: size,
      child: ColoredBox(
        color: GtColors.bg,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.9, -1.0),
              radius: 1.3,
              colors: [accent.withValues(alpha: 0.22), GtColors.bg.withValues(alpha: 0)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: child),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const BrandMark(size: 14),
                    const SizedBox(width: 8),
                    Text('GYMTRX', style: GtText.overline.colored(GtColors.text2)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A day: date, body map, stats and the top set of each exercise.
class DayShareCard extends StatelessWidget {
  const DayShareCard({super.key, required this.entry, required this.unit, required this.prSetIds});

  final EntryDetail entry;
  final WeightUnit unit;
  final Set<int> prSetIds;

  static const _maxExercises = 3;

  @override
  Widget build(BuildContext context) {
    final regions = regionsForGroups(entry.groups);
    final sets = entry.exercises.fold(0, (n, e) => n + e.sets.length);
    final prCount = {
      for (final e in entry.exercises)
        if (e.sets.any((s) => prSetIds.contains(s.id))) e.exercise.id,
    }.length;
    final groups = entry.groups.map((g) => g.name).join(' · ');
    final shown = entry.exercises.take(_maxExercises).toList();

    return ShareFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Fmt.weekdayLong(entry.dayKey).toUpperCase(), style: GtText.overline.colored(context.accent)),
          const SizedBox(height: 2),
          Text(
            '${DayKeys.day(entry.dayKey)} ${Fmt.monthName(DayKeys.month(entry.dayKey))}',
            style: GtText.display.sized(32),
          ),
          if (groups.isNotEmpty)
            Text(groups, style: GtText.label.colored(GtColors.text2), maxLines: 1, overflow: TextOverflow.ellipsis),
          Expanded(
            child: Center(
              child: regions.isNotEmpty
                  ? FittedBox(child: BodyMap(strength: regions, height: 150))
                  : includesCardio(entry.groups)
                  ? const CardioPill()
                  : const SizedBox.shrink(),
            ),
          ),
          for (final e in shown)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      e.exercise.name,
                      style: GtText.label.weight(600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (e.sets.any((s) => prSetIds.contains(s.id))) ...[
                    const SizedBox(width: 6),
                    const Icon(GtIcons.trophy, size: 12, color: GtColors.gold),
                  ],
                  const SizedBox(width: 10),
                  if (_top(e) case final top?)
                    Text(top, style: GtText.caption, maxLines: 1),
                ],
              ),
            ),
          if (entry.exercises.length > _maxExercises)
            Text('+${entry.exercises.length - _maxExercises} more', style: GtText.caption),
          const SizedBox(height: 10),
          Row(
            children: [
              if (entry.exercises.isNotEmpty)
                _Stat('${entry.exercises.length}', entry.exercises.length == 1 ? 'exercise' : 'exercises'),
              if (sets > 0) _Stat('$sets', sets == 1 ? 'set' : 'sets'),
              if (entry.session.durationMin case final m?) _Stat('$m', 'min'),
              if (prCount > 0) _Stat('$prCount', prCount == 1 ? 'PR' : 'PRs', color: GtColors.gold),
            ],
          ),
        ],
      ),
    );
  }

  /// "85 kg × 5" or "3 sets · top 85 kg × 5".
  String? _top(ExerciseEntry e) {
    if (e.sets.isEmpty) return null;
    final withWeight = e.sets.where((s) => s.weightKg != null).toList();
    final best = withWeight.isEmpty ? e.sets.first : withWeight.reduce((a, b) => b.weightKg! > a.weightKg! ? b : a);
    final text = formatSet(best, e.exercise.kind, unit);
    return e.sets.length > 1 ? '${Fmt.plural(e.sets.length, 'set')} · top $text' : text;
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, {this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GtText.monoTitle.sized(22).colored(color ?? GtColors.text1)),
          Text(label, style: GtText.caption),
        ],
      ),
    );
  }
}

/// A personal record: the lift, the number, the gain.
class PrShareCard extends StatelessWidget {
  const PrShareCard({
    super.key,
    required this.exercise,
    required this.value,
    required this.gain,
    required this.metric,
    required this.dayKey,
  });

  final String exercise;
  final String value;
  final String gain;
  final String metric;
  final int dayKey;

  @override
  Widget build(BuildContext context) {
    return ShareFrame(
      glow: GtColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: GtColors.goldMuted, shape: BoxShape.circle),
            child: const Icon(GtIcons.trophy, size: 28, color: GtColors.gold),
          ),
          const SizedBox(height: 18),
          Text('NEW PERSONAL RECORD', style: GtText.overline.colored(GtColors.gold)),
          const SizedBox(height: 6),
          Text(exercise, style: GtText.headline, maxLines: 2),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: GtText.figure.sized(54).weight(600)),
          ),
          const SizedBox(height: 4),
          Text('$gain · $metric', style: GtText.label.weight(600).colored(GtColors.gold)),
          const SizedBox(height: 10),
          Text(Fmt.fullDate(dayKey), style: GtText.caption),
        ],
      ),
    );
  }
}

/// The streak in weeks, with the flame.
class StreakShareCard extends StatelessWidget {
  const StreakShareCard({
    super.key,
    required this.weeks,
    required this.best,
    required this.goal,
    required this.sessions,
  });

  final int weeks;
  final int best;
  final int goal;

  /// Sessions logged this year.
  final int sessions;

  @override
  Widget build(BuildContext context) {
    return ShareFrame(
      glow: GtColors.flame,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(GtIcons.flame, size: 44, color: GtColors.flame),
          const Spacer(),
          // Shrinks rather than overflowing when the stats below need a second line.
          Flexible(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('$weeks', style: GtText.monoDisplay.sized(120).copyWith(height: 1)),
            ),
          ),
          Text(weeks == 1 ? 'week in a row' : 'weeks in a row', style: GtText.title.colored(GtColors.text2)),
          const SizedBox(height: 6),
          Text('${Fmt.plural(goal, 'session')} every week', style: GtText.label.weight(600).colored(GtColors.flame)),
          const Spacer(),
          Wrap(
            runSpacing: 6,
            children: [_Stat('$best', 'best streak'), _Stat('$sessions', 'sessions this year')],
          ),
        ],
      ),
    );
  }
}
