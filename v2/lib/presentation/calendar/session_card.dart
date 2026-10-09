import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../art/dot_body.dart';
import '../body_map/muscle_regions.dart';
import '../log/log_actions.dart';
import '../widgets/controls.dart';
import '../widgets/labels.dart';
import '../widgets/surface.dart';

/// One logged day, like the workout rows in the reference: a dot-body
/// thumbnail, the muscle groups as a coral overline, the date, and what was
/// recorded. Entries with only muscle groups offer a "+" for the late-night
/// details.
class SessionCard extends ConsumerWidget {
  const SessionCard({super.key, required this.entry, required this.heroScope});

  final EntrySummary entry;

  /// Where the card lives ("home", "calendar"). Every tab stays built, so the
  /// same day can be on screen twice; the scope keeps their Heroes apart.
  final String heroScope;

  String get _heroTag => 'entry-body-$heroScope-${entry.dayKey}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final groups = ref.watch(groupsByIdProvider);
    final label = groupLabel(entry.groupIds, groups);
    final dayGroups = [for (final id in entry.groupIds) ?groups[id]];

    return GtCard(
      onTap: () => openEntry(context, entry.dayKey, heroTag: _heroTag),
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      radius: GtRadius.lg,
      child: Row(
        children: [
          SessionThumb(heroTag: _heroTag, groups: dayGroups),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.isEmpty ? 'LOGGED' : label.toUpperCase(),
                  style: context.tx.tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _title(entry.dayKey),
                  style: GtText.titleSmall.sized(16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _Meta(entry: entry),
              ],
            ),
          ),
          const SizedBox(width: GtSpace.sm),
          if (entry.needsDetails)
            CircleButton(
              icon: GtIcons.add,
              size: 38,
              iconSize: 16,
              solid: true,
              semanticLabel: 'Add details',
              onTap: () => openLogSheet(context, ref, dayKey: entry.dayKey),
            )
          else
            CircleButton(
              icon: GtIcons.open,
              size: 38,
              iconSize: 16,
              solid: true,
              iconColor: c.text2,
              semanticLabel: 'Open',
              onTap: () => openEntry(context, entry.dayKey, heroTag: _heroTag),
            ),
        ],
      ),
    );
  }

  /// "Wednesday, 8 Oct"
  static String _title(int dayKey) => '${Fmt.weekdayLong(dayKey)}, ${Fmt.dayMonth(dayKey)}';
}

/// The dot body for one day, lit where that day's groups train. Flies into
/// the entry detail as a Hero.
class SessionThumb extends StatelessWidget {
  const SessionThumb({super.key, required this.heroTag, required this.groups, this.size = 64});

  final String heroTag;
  final List<MuscleGroup> groups;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ArtTile(
      size: size,
      color: c.surface2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: heroTag,
            child: DotBody(
              strength: regionsForGroups(groups),
              height: size * 0.9,
              spacing: 2.0,
              reveal: false,
              glow: false,
            ),
          ),
          if (includesCardio(groups))
            Positioned(
              right: 5,
              bottom: 5,
              child: Icon(GtIcons.cardio, size: 12, color: c.tag),
            ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.entry});

  final EntrySummary entry;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final style = GtText.caption.colored(c.text2);
    final parts = <(IconData, String)>[
      if (entry.durationMin != null) (GtIcons.duration, Fmt.duration(entry.durationMin!)),
      if (entry.exerciseCount > 0) (GtIcons.exercise, Fmt.plural(entry.exerciseCount, 'exercise')),
      if (entry.setCount > 0) (GtIcons.sets, Fmt.plural(entry.setCount, 'set')),
    ];
    if (parts.isEmpty) {
      return Text(entry.hasNote ? 'Note added' : 'Muscle groups only', style: style.colored(c.text3));
    }
    return Wrap(
      spacing: 10,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (icon, text) in parts)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: c.text3),
              const SizedBox(width: 4),
              Text(text, style: style),
            ],
          ),
        if (entry.hasNote) Icon(GtIcons.note, size: 13, color: c.text3),
      ],
    );
  }
}
