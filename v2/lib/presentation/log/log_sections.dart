import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../art/dot_body.dart';
import '../body_map/muscle_regions.dart';
import '../widgets/autosave_field.dart';
import '../widgets/controls.dart';
import '../widgets/gt_chip.dart';
import '../widgets/labels.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';
import 'log_sheet.dart';

const _sheetSectionPadding = EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xxl, GtSpace.gutter, GtSpace.md);

/// "Same as before" combos plus the muscle-group tiles: the 3-second quick
/// capture.
class GroupsSection extends ConsumerStatefulWidget {
  const GroupsSection({
    super.key,
    required this.dayKey,
    required this.entry,
    required this.onToggle,
    required this.onCombo,
  });

  final int dayKey;
  final EntryDetail? entry;
  final Future<void> Function(int groupId, bool selected) onToggle;
  final void Function(List<int> groupIds) onCombo;

  @override
  ConsumerState<GroupsSection> createState() => _GroupsSectionState();
}

class _GroupsSectionState extends ConsumerState<GroupsSection> {
  // Tiles flip instantly; these overrides last until the database agrees.
  final _optimistic = <int, bool>{};

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider).value ?? const <MuscleGroup>[];
    final byId = ref.watch(groupsByIdProvider);
    final stored = widget.entry.selectedGroupIds;
    _optimistic.removeWhere((id, selected) => stored.contains(id) == selected);
    bool isSelected(int id) => _optimistic[id] ?? stored.contains(id);

    final shown = [for (final g in groups) if (!g.hidden || stored.contains(g.id)) g];
    final anySelected = shown.any((g) => isSelected(g.id));
    final summaries = ref.watch(summariesProvider).value ?? const <EntrySummary>[];
    final combos = recentGroupCombos([for (final e in summaries) if (e.dayKey != widget.dayKey) e], byId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          child: LayoutBuilder(
            builder: (context, box) {
              const gap = 10.0;
              final w = (box.maxWidth - gap * 2) / 3;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final g in shown)
                    SizedBox(
                      width: w,
                      child: GroupTile(
                        group: g,
                        selected: isSelected(g.id),
                        onTap: () {
                          final next = !isSelected(g.id);
                          setState(() => _optimistic[g.id] = next);
                          widget.onToggle(g.id, next);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// One muscle group: a tiny dot body with its muscles lit, and its name.
/// Selected tiles turn ink with accent dots.
class GroupTile extends StatelessWidget {
  const GroupTile({super.key, required this.group, required this.selected, required this.onTap});

  final MuscleGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final regions = regionsForGroups([group]);
    final cardio = group.slug == 'cardio';
    final duration = GtMotion.of(context, GtMotion.medium);
    final fg = selected ? c.onInk : c.text1;

    return Semantics(
      label: '${group.name}${selected ? ', selected' : ''}',
      button: true,
      selected: selected,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        haptic: PressHaptic.selection,
        scale: 0.94,
        child: AnimatedContainer(
          duration: duration,
          curve: GtMotion.emphasized,
          height: 112,
          decoration: ShapeDecoration(
            color: selected ? c.ink : c.surface,
            shape: squircle(
              GtRadius.lg,
              side: !c.isDark
                  ? BorderSide.none
                  : BorderSide(color: selected ? c.accent.withValues(alpha: 0.55) : c.hairline, width: selected ? 1.4 : 1),
            ),
            shadows: selected || c.isDark ? null : c.cardShadow,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: Center(
                        child: cardio
                            ? Icon(GtIcons.cardio, size: 30, color: selected ? c.accentOnInk : c.tag)
                            : DotBody(
                                strength: regions,
                                height: 62,
                                spacing: 1.9,
                                reveal: false,
                                glow: false,
                                litColor: selected ? c.accent : c.accentStrong,
                                offColor: selected ? c.onInk.withValues(alpha: 0.24) : null,
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
                      child: AnimatedDefaultTextStyle(
                        duration: duration,
                        style: GtText.label.weight(600).colored(fg),
                        child: Text(group.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedScale(
                  duration: duration,
                  curve: GtMotion.emphasized,
                  scale: selected ? 1 : 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                    child: Icon(GtIcons.check, size: 11, color: c.onAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          child: AutosaveField(
            value: note,
            onSave: onSave,
            hint: 'Anything to remember',
            minLines: 2,
            maxLines: 6,
            radius: GtRadius.lg,
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
    final c = context.c;
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
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          child: GtCard(
            padding: EdgeInsets.zero,
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
                    fillColor: c.surface2,
                    contentPadding: const EdgeInsets.symmetric(horizontal: GtSpace.md, vertical: 10),
                    semanticLabel: 'Duration in minutes',
                    onSave: (t) => onDuration(int.tryParse(t)),
                  ),
                ),
                Divider(height: 1, indent: GtSpace.lg, endIndent: GtSpace.lg, color: c.hairline),
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
                    fillColor: c.surface2,
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
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, 10, GtSpace.md, 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: ShapeDecoration(color: c.surface2, shape: const CircleBorder()),
            child: Icon(icon, size: 17, color: c.text2),
          ),
          const SizedBox(width: GtSpace.md),
          Expanded(child: Text(label, style: GtText.body)),
          SizedBox(width: 92, child: field),
          SizedBox(
            width: 34,
            child: Text(suffix, textAlign: TextAlign.end, style: GtText.label.colored(c.text2)),
          ),
        ],
      ),
    );
  }
}
