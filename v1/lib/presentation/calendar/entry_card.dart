import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../log/log_actions.dart';
import '../widgets/labels.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';

/// One day in the month's list. Entries with only muscle groups offer a
/// direct "+ Details" shortcut, for the late-night fill-in.
class EntryCard extends ConsumerWidget {
  const EntryCard({super.key, required this.entry});

  final EntrySummary entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsByIdProvider);
    final label = groupLabel(entry.groupIds, groups);
    final meta = entryMeta(entry);

    return GtCard(
      onTap: () => openEntry(context, entry.dayKey),
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, 14, GtSpace.md, 14),
      child: Row(
        children: [
          Hero(
            tag: 'entry-date-${entry.dayKey}',
            child: Material(type: MaterialType.transparency, child: DateBlock(dayKey: entry.dayKey)),
          ),
          const SizedBox(width: GtSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.isEmpty ? 'Logged' : label,
                  style: GtText.titleSmall.sized(16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta.isNotEmpty || entry.hasNote) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (meta.isNotEmpty) Flexible(child: Text(meta, style: GtText.caption, maxLines: 1)),
                      if (entry.hasNote) ...[
                        if (meta.isNotEmpty) const SizedBox(width: 6),
                        const Icon(GtIcons.note, size: 13, color: GtColors.text2),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: GtSpace.sm),
          if (entry.needsDetails)
            _DetailsPill(onTap: () => openLogSheet(context, ref, dayKey: entry.dayKey))
          else
            const Icon(GtIcons.chevronRight, size: 16, color: GtColors.text3),
        ],
      ),
    );
  }
}

/// Day number over a short weekday, used in cards and the detail header.
class DateBlock extends StatelessWidget {
  const DateBlock({super.key, required this.dayKey, this.large = false});

  final int dayKey;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: large ? null : 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: large ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            '${DayKeys.day(dayKey)}',
            style: large ? GtText.monoDisplay.sized(64) : GtText.monoTitle.sized(24),
          ),
          SizedBox(height: large ? 6 : 2),
          Text(Fmt.weekdayShort(dayKey).toUpperCase(), style: GtText.overline.colored(GtColors.text3)),
        ],
      ),
    );
  }
}

class _DetailsPill extends StatelessWidget {
  const _DetailsPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      semanticLabel: 'Add details',
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.md),
        decoration: ShapeDecoration(color: context.gt.accentMuted, shape: squircle(16)),
        alignment: Alignment.center,
        child: Text('+ Details', style: GtText.label.weight(600).colored(context.accent)),
      ),
    );
  }
}
