import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../data/models/progress.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/autosave_field.dart';
import '../widgets/controls.dart';
import '../widgets/gt_chip.dart';
import '../widgets/labels.dart';
import '../widgets/pressable.dart';
import 'log_sheet.dart';

const _sheetSectionPadding = EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xxl, GtSpace.gutter, GtSpace.md);

/// "Same as before" combos plus the muscle-group chip grid: the 3-second
/// quick capture.
class GroupsSection extends ConsumerStatefulWidget {
  const GroupsSection({
    super.key,
    required this.dayKey,
    required this.entry,
    required this.onToggle,
    required this.onCombo,
    this.onProgram,
  });

  final int dayKey;
  final EntryDetail? entry;
  final Future<void> Function(int groupId, bool selected) onToggle;
  final void Function(List<int> groupIds) onCombo;

  /// Fills the day from its weekly-program plan.
  final void Function(ProgramDayPlan plan)? onProgram;

  @override
  ConsumerState<GroupsSection> createState() => _GroupsSectionState();
}

/// One tap fills the day's groups and exercises from the program.
class _ProgramChip extends StatelessWidget {
  const _ProgramChip({required this.plan, required this.byId, required this.onTap});

  final ProgramDayPlan plan;
  final Map<int, MuscleGroup> byId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final groups = groupLabel(plan.groupIds, byId);
    final detail = [
      if (groups.isNotEmpty && groups != plan.label) groups,
      if (plan.exerciseIds.isNotEmpty) Fmt.plural(plan.exerciseIds.length, 'exercise'),
    ].join(' · ');
    return Pressable(
      onTap: onTap,
      haptic: PressHaptic.medium,
      scale: 0.97,
      semanticLabel: 'Fill from program: ${plan.label}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.md, GtSpace.md),
        decoration: ShapeDecoration(
          color: context.gt.accentMuted,
          shape: squircle(GtRadius.md, side: BorderSide(color: context.gt.accentSoft)),
        ),
        child: Row(
          children: [
            Icon(GtIcons.program, size: 20, color: context.accent),
            const SizedBox(width: GtSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.label, style: GtText.body.weight(600).colored(context.accent)),
                  if (detail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(detail, style: GtText.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const SizedBox(width: GtSpace.sm),
            Text('FILL', style: GtText.overline.colored(context.accent)),
          ],
        ),
      ),
    );
  }
}

class _GroupsSectionState extends ConsumerState<GroupsSection> {
  // Chips flip instantly; these overrides last until the database agrees.
  final _optimistic = <int, bool>{};

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider).value ?? const [];
    final byId = ref.watch(groupsByIdProvider);
    final stored = widget.entry.selectedGroupIds;
    _optimistic.removeWhere((id, selected) => stored.contains(id) == selected);
    bool isSelected(int id) => _optimistic[id] ?? stored.contains(id);

    final shown = [for (final g in groups) if (!g.hidden || stored.contains(g.id)) g];
    final anySelected = shown.any((g) => isSelected(g.id));
    final summaries = ref.watch(summariesProvider).value ?? const <EntrySummary>[];
    final combos = recentGroupCombos([for (final e in summaries) if (e.dayKey != widget.dayKey) e], byId);
    final plan = (ref.watch(programProvider).value ?? const {})[DayKeys.weekday(widget.dayKey)];
    final showPlan = widget.onProgram != null && plan != null && (widget.entry?.exercises.isEmpty ?? true);
    final logicalToday = ref.watch(logicalTodayProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: GtMotion.of(context, GtMotion.slow),
          curve: GtMotion.emphasized,
          alignment: Alignment.topCenter,
          child: anySelected || !showPlan
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(
                      widget.dayKey == logicalToday
                          ? 'Today’s program'
                          : '${Fmt.weekdayShort(widget.dayKey)} program',
                      padding: _sheetSectionPadding,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter),
                      child: _ProgramChip(plan: plan, byId: byId, onTap: () => widget.onProgram!(plan)),
                    ),
                  ],
                ),
        ),
        AnimatedSize(
          duration: GtMotion.of(context, GtMotion.slow),
          curve: GtMotion.emphasized,
          alignment: Alignment.topCenter,
          child: anySelected || combos.isEmpty
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader('Same as before', padding: _sheetSectionPadding),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter),
                      child: Wrap(
                        spacing: GtSpace.sm,
                        runSpacing: GtSpace.sm,
                        children: [
                          for (final ids in combos)
                            GtChip(
                              label: groupLabel(ids, byId),
                              icon: GtIcons.undo,
                              selected: false,
                              onTap: () => widget.onCombo(ids),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        const SectionHeader('What did you train?', padding: _sheetSectionPadding),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter),
          child: Wrap(
            spacing: GtSpace.sm,
            runSpacing: GtSpace.sm,
            children: [
              for (final g in shown)
                GtChip(
                  label: g.name,
                  height: 42,
                  selected: isSelected(g.id),
                  onTap: () {
                    final next = !isSelected(g.id);
                    setState(() => _optimistic[g.id] = next);
                    widget.onToggle(g.id, next);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class NoteSection extends StatelessWidget {
  const NoteSection({super.key, required this.note, required this.onSave});

  final String note;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Note', padding: _sheetSectionPadding),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter),
          child: AutosaveField(
            value: note,
            onSave: onSave,
            hint: 'Anything to remember',
            minLines: 2,
            maxLines: 6,
            semanticLabel: 'Note',
          ),
        ),
      ],
    );
  }
}

/// Duration and body weight. A weigh-in belongs to the day, not the session,
/// so it never creates an entry on its own.
class MoreSection extends ConsumerWidget {
  const MoreSection({super.key, required this.dayKey, required this.durationMin, required this.onDuration});

  final int dayKey;
  final int? durationMin;
  final ValueChanged<int?> onDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final weights = ref.watch(bodyWeightsProvider).value ?? const [];
    final weightRepo = ref.read(bodyWeightRepoProvider);
    final todays = weights.where((w) => w.dayKey == dayKey).firstOrNull;
    final lastKnown = weights.where((w) => w.dayKey <= dayKey).lastOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('More', padding: _sheetSectionPadding),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter),
          child: DecoratedBox(
            decoration: ShapeDecoration(color: GtColors.s2, shape: squircle(GtRadius.lg)),
            child: Column(
              children: [
                _MoreRow(
                  icon: GtIcons.duration,
                  label: 'Duration',
                  suffix: 'min',
                  field: AutosaveField(
                    value: durationMin?.toString() ?? '',
                    hint: '–',
                    keyboardType: TextInputType.number,
                    inputFormatters: integerInput,
                    textAlign: TextAlign.end,
                    style: GtText.mono.sized(16),
                    fillColor: GtColors.s3,
                    contentPadding: const EdgeInsets.symmetric(horizontal: GtSpace.md, vertical: 10),
                    semanticLabel: 'Duration in minutes',
                    onSave: (t) => onDuration(int.tryParse(t)),
                  ),
                ),
                const Divider(height: 1, indent: GtSpace.lg, endIndent: GtSpace.lg),
                _MoreRow(
                  icon: GtIcons.weight,
                  label: 'Body weight',
                  suffix: unit.name,
                  field: AutosaveField(
                    value: todays == null ? '' : Units.format(todays.weightKg, unit, withUnit: false, maxDecimals: 1),
                    hint: lastKnown == null ? '–' : Units.format(lastKnown.weightKg, unit, withUnit: false, maxDecimals: 1),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: decimalInput,
                    textAlign: TextAlign.end,
                    style: GtText.mono.sized(16),
                    fillColor: GtColors.s3,
                    contentPadding: const EdgeInsets.symmetric(horizontal: GtSpace.md, vertical: 10),
                    semanticLabel: 'Body weight',
                    onSave: (t) {
                      final v = parseNumber(t);
                      if (v == null || v <= 0) {
                        weightRepo.remove(dayKey);
                      } else {
                        weightRepo.upsert(dayKey, Units.toKg(v, unit));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.icon, required this.label, required this.suffix, required this.field});

  final IconData icon;
  final String label;
  final String suffix;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.sm, GtSpace.md, GtSpace.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: GtColors.text2),
          const SizedBox(width: GtSpace.md),
          Expanded(child: Text(label, style: GtText.body)),
          SizedBox(width: 92, child: field),
          SizedBox(
            width: 34,
            child: Text(suffix, textAlign: TextAlign.end, style: GtText.label.colored(GtColors.text2)),
          ),
        ],
      ),
    );
  }
}
