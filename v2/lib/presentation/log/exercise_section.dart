import 'dart:ui' show lerpDouble;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../data/repositories/session_repository.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/autosave_field.dart';
import '../widgets/controls.dart';
import '../widgets/pressable.dart';
import '../widgets/toast.dart';
import 'exercise_picker_sheet.dart';
import 'log_sheet.dart';

/// Optional exercises. Each is just a name until tapped; sets live inside.
class ExerciseSection extends ConsumerStatefulWidget {
  const ExerciseSection({super.key, required this.dayKey, required this.entry, required this.write});

  final int dayKey;
  final EntryDetail? entry;
  final SheetWrite write;

  @override
  ConsumerState<ExerciseSection> createState() => _ExerciseSectionState();
}

class _ExerciseSectionState extends ConsumerState<ExerciseSection> {
  late final SessionRepository _repo;
  final _expanded = <int>{};
  // Optimistic UI: hidden/reordered immediately, reconciled with the stream.
  final _removed = <int>{};
  List<int>? _pendingOrder;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(sessionRepoProvider);
  }

  void _add(Exercise e) {
    Haptics.selection();
    widget.write((r, d) async => await r.addExercise(d, e.id));
  }

  void _remove(ExerciseEntry e) {
    setState(() => _removed.add(e.row.id));
    Haptics.light();
    widget.write((r, d) => r.removeExercise(e.row.id));
    final day = widget.dayKey;
    final repo = _repo;
    Toasts.show(
      'Removed ${e.exercise.name}',
      actionLabel: 'Undo',
      onAction: () => repo.restoreExercise(day, e),
    );
  }

  void _reorder(List<ExerciseEntry> shown, int from, int to) {
    if (to > from) to -= 1;
    final ids = [for (final e in shown) e.row.id];
    ids.insert(to, ids.removeAt(from));
    setState(() => _pendingOrder = ids);
    _repo.reorderExercises(ids);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final exercises = widget.entry?.exercises ?? const <ExerciseEntry>[];
    final ids = [for (final e in exercises) e.row.id];
    _removed.retainWhere(ids.contains);
    if (_pendingOrder != null && listEquals(_pendingOrder, ids)) _pendingOrder = null;

    final shown = [for (final e in exercises) if (!_removed.contains(e.row.id)) e];
    if (_pendingOrder case final order?) {
      int rank(ExerciseEntry e) {
        final i = order.indexOf(e.row.id);
        return i < 0 ? order.length : i;
      }

      shown.sort((a, b) => rank(a).compareTo(rank(b)));
    }

    final suggestions = _suggestions(
      all: ref.watch(exercisesProvider).value ?? const [],
      stats: ref.watch(exerciseStatsProvider).value ?? const [],
      groupIds: widget.entry.selectedGroupIds,
      added: {for (final e in shown) e.exercise.id},
    );

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            'Exercises',
            padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xxl, GtSpace.gutter, GtSpace.md),
            trailing: Text('Optional', style: GtText.caption.colored(c.text3)),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSize(
            duration: GtMotion.of(context, GtMotion.medium),
            curve: GtMotion.emphasized,
            alignment: Alignment.topCenter,
            child: suggestions.isEmpty
                ? const SizedBox(width: double.infinity)
                : SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, GtSpace.md),
                      itemCount: suggestions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: GtSpace.sm),
                      itemBuilder: (context, i) => _SuggestionChip(
                        key: ValueKey(suggestions[i].id),
                        label: suggestions[i].name,
                        onTap: () => _add(suggestions[i]),
                      ),
                    ),
                  ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          sliver: SliverReorderableList(
            itemCount: shown.length,
            onReorder: (from, to) => _reorder(shown, from, to),
            onReorderStart: (_) => Haptics.medium(),
            proxyDecorator: (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Transform.scale(
                scale: lerpDouble(1, 1.03, Curves.easeOut.transform(animation.value)),
                child: Material(
                  color: Colors.transparent,
                  elevation: 10 * animation.value,
                  shadowColor: c.shadow.withValues(alpha: 0.4),
                  shape: squircle(GtRadius.lg),
                  child: child,
                ),
              ),
              child: child,
            ),
            itemBuilder: (context, i) {
              final e = shown[i];
              return ReorderableDelayedDragStartListener(
                key: ValueKey(e.row.id),
                index: i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey('dismiss-${e.row.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _remove(e),
                    background: const _DeleteBackground(),
                    child: ExerciseCard(
                      entry: e,
                      dayKey: widget.dayKey,
                      expanded: _expanded.contains(e.row.id),
                      onToggle: () => setState(() {
                        if (!_expanded.remove(e.row.id)) _expanded.add(e.row.id);
                      }),
                      repo: _repo,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
            child: _AddExerciseButton(
              onTap: () => showExercisePicker(
                context,
                dayKey: widget.dayKey,
                groupIds: widget.entry.selectedGroupIds,
                write: widget.write,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Exercises from the chosen groups, most-used first, alternating between
  /// groups when usage ties (Chest, Triceps, Chest, …). With no group chosen,
  /// the user's own most-used exercises.
  static List<Exercise> _suggestions({
    required List<Exercise> all,
    required List<ExerciseStat> stats,
    required Set<int> groupIds,
    required Set<int> added,
  }) {
    final usage = {for (final s in stats) s.exercise.id: s.count};
    final pool = [
      for (final e in all)
        if (!e.hidden &&
            !added.contains(e.id) &&
            (groupIds.isEmpty ? (usage[e.id] ?? 0) > 0 : groupIds.contains(e.groupId)))
          e,
    ]..sort((a, b) => a.id.compareTo(b.id));
    // Position of each exercise within its own group (seed order).
    final rankInGroup = <int, int>{};
    final seen = <int?, int>{};
    for (final e in pool) {
      rankInGroup[e.id] = seen[e.groupId] = (seen[e.groupId] ?? -1) + 1;
    }
    pool.sort((a, b) {
      final byUse = (usage[b.id] ?? 0).compareTo(usage[a.id] ?? 0);
      if (byUse != 0) return byUse;
      final byRank = rankInGroup[a.id]!.compareTo(rankInGroup[b.id]!);
      return byRank != 0 ? byRank : a.id.compareTo(b.id);
    });
    return pool.take(10).toList();
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Pressable(
      onTap: onTap,
      haptic: PressHaptic.none,
      scale: 0.94,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
        alignment: Alignment.center,
        decoration: ShapeDecoration(color: c.surface, shape: StadiumBorder(side: BorderSide(color: c.hairlineStrong))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
              child: Icon(GtIcons.add, size: 11, color: c.onAccent),
            ),
            const SizedBox(width: 8),
            Text(label, style: GtText.label.sized(14)),
          ],
        ),
      ),
    );
  }
}

class _AddExerciseButton extends StatelessWidget {
  const _AddExerciseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        height: 54,
        decoration: ShapeDecoration(
          color: c.surface.withValues(alpha: c.isDark ? 0.5 : 0.6),
          shape: StadiumBorder(side: BorderSide(color: c.hairlineStrong)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(GtIcons.search, size: 18, color: c.text2),
            const SizedBox(width: GtSpace.sm),
            Text('Add exercise', style: GtText.label.sized(15).weight(600).colored(c.text2)),
          ],
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: GtSpace.xxl),
      decoration: ShapeDecoration(color: c.danger.withValues(alpha: 0.12), shape: squircle(GtRadius.lg)),
      child: Icon(GtIcons.delete, color: c.danger, size: 20),
    );
  }
}

/// "3 sets · 60 kg × 8", "25 min · 3.2 km" … or empty.
String setSummary(Exercise exercise, List<ExerciseSet> sets, WeightUnit unit) {
  if (sets.isEmpty) return '';
  final count = Fmt.plural(sets.length, 'set');
  switch (exercise.kind) {
    case ExerciseKind.strength:
      final withWeight = sets.where((s) => s.weightKg != null).toList();
      if (withWeight.isEmpty) {
        final reps = sets.map((s) => s.reps).nonNulls;
        return reps.isEmpty ? count : '$count · ${reps.join(', ')} reps';
      }
      final top = withWeight.reduce((a, b) => b.weightKg! > a.weightKg! ? b : a);
      return '$count · ${Units.format(top.weightKg!, unit)}${top.reps == null ? '' : ' × ${top.reps}'}';
    case ExerciseKind.bodyweight:
      final reps = sets.map((s) => s.reps).nonNulls;
      return reps.isEmpty ? count : '$count · ${reps.join(', ')} reps';
    case ExerciseKind.cardio:
      final minutes = sets.map((s) => s.durationSec ?? 0).fold(0, (a, b) => a + b) ~/ 60;
      final km = sets.map((s) => s.distanceKm ?? 0).fold(0.0, (a, b) => a + b);
      return [
        if (minutes > 0) Fmt.duration(minutes),
        if (km > 0) '${Fmt.number(km)} km',
      ].join(' · ');
    case ExerciseKind.timed:
      final times = sets.map((s) => s.durationSec).nonNulls.map(Fmt.clock);
      return times.isEmpty ? count : '$count · ${times.join(', ')}';
  }
}

class ExerciseCard extends ConsumerWidget {
  const ExerciseCard({
    super.key,
    required this.entry,
    required this.dayKey,
    required this.expanded,
    required this.onToggle,
    required this.repo,
  });

  final ExerciseEntry entry;
  final int dayKey;
  final bool expanded;
  final VoidCallback onToggle;
  final SessionRepository repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final group = ref.watch(groupsByIdProvider)[entry.exercise.groupId];
    final summary = setSummary(entry.exercise, entry.sets, unit);
    final note = entry.row.note;
    final subtitle = [if (summary.isNotEmpty) summary, ?note].join(' · ');

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: c.surface,
        shape: squircle(GtRadius.lg, side: c.isDark ? BorderSide(color: c.hairline) : BorderSide.none),
        shadows: c.cardShadow,
      ),
      child: Column(
        children: [
          Pressable(
            onTap: onToggle,
            haptic: PressHaptic.selection,
            scale: 0.98,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.lg, 14, GtSpace.md, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (group != null) ...[
                          Text(group.name.toUpperCase(), style: context.tx.tag),
                          const SizedBox(height: 3),
                        ],
                        Text(entry.exercise.name, style: GtText.titleSmall.sized(16)),
                        AnimatedSize(
                          duration: GtMotion.of(context, GtMotion.medium),
                          curve: GtMotion.emphasized,
                          alignment: Alignment.topLeft,
                          child: expanded || subtitle.isEmpty
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    subtitle,
                                    style: GtText.caption.colored(c.text2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: ShapeDecoration(color: c.surface2, shape: const CircleBorder()),
                    child: AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: GtMotion.of(context, GtMotion.medium),
                      curve: GtMotion.emphasized,
                      child: Icon(GtIcons.chevronDown, size: 13, color: c.text2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: GtMotion.of(context, GtMotion.medium),
            curve: GtMotion.emphasized,
            alignment: Alignment.topCenter,
            child: expanded
                ? _ExpandedBody(entry: entry, dayKey: dayKey, unit: unit, repo: repo)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ExpandedBody extends StatefulWidget {
  const _ExpandedBody({required this.entry, required this.dayKey, required this.unit, required this.repo});

  final ExerciseEntry entry;
  final int dayKey;
  final WeightUnit unit;
  final SessionRepository repo;

  @override
  State<_ExpandedBody> createState() => _ExpandedBodyState();
}

class _ExpandedBodyState extends State<_ExpandedBody> {
  late final Future<LastPerformance?> _last = widget.repo.lastPerformance(widget.entry.exercise.id, widget.dayKey);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final e = widget.entry;
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.sm, GtSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder(
            future: _last,
            builder: (context, snap) {
              final last = snap.data;
              if (last == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: GtSpace.md, right: GtSpace.sm),
                child: Row(
                  children: [
                    Icon(GtIcons.undo, size: 13, color: c.text3),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Last time · ${Fmt.dayMonth(last.dayKey)} · ${setSummary(e.exercise, last.sets, widget.unit)}',
                        style: GtText.caption.colored(c.text2),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          for (var i = 0; i < e.sets.length; i++)
            SetRow(
              key: ValueKey(e.sets[i].id),
              index: i + 1,
              set: e.sets[i],
              kind: e.exercise.kind,
              unit: widget.unit,
              repo: widget.repo,
            ),
          Row(
            children: [
              Pressable(
                onTap: () => widget.repo.addSet(e.row.id),
                haptic: PressHaptic.selection,
                scale: 0.94,
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(color: c.ink, shape: const StadiumBorder()),
                  child: Text(
                    e.sets.isEmpty ? '+ Add set' : '+ Set',
                    style: GtText.label.weight(600).colored(c.accentOnInk),
                  ),
                ),
              ),
              const SizedBox(width: GtSpace.sm),
              Expanded(
                child: AutosaveField(
                  value: e.row.note ?? '',
                  hint: 'Note',
                  onSave: (t) => widget.repo.setExerciseNote(e.row.id, t),
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: GtSpace.sm, vertical: 10),
                  style: GtText.label.sized(14),
                  semanticLabel: '${e.exercise.name} note',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One set. Every field is optional; which ones appear depends on the kind.
class SetRow extends StatelessWidget {
  const SetRow({
    super.key,
    required this.index,
    required this.set,
    required this.kind,
    required this.unit,
    required this.repo,
  });

  final int index;
  final ExerciseSet set;
  final ExerciseKind kind;
  final WeightUnit unit;
  final SessionRepository repo;

  Future<void> _update(ExerciseSetsCompanion values) => repo.updateSet(set.id, values);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fields = switch (kind) {
      ExerciseKind.strength => [
        _NumField(
          value: set.weightKg == null ? '' : Units.format(set.weightKg!, unit, withUnit: false),
          suffix: unit.name,
          decimal: true,
          label: 'Weight',
          onSave: (v) => _update(ExerciseSetsCompanion(weightKg: Value(v == null ? null : Units.toKg(v, unit)))),
        ),
        Text('×', style: GtText.label.colored(c.text3)),
        _NumField(
          value: set.reps?.toString() ?? '',
          suffix: 'reps',
          label: 'Reps',
          onSave: (v) => _update(ExerciseSetsCompanion(reps: Value(v?.round()))),
        ),
      ],
      ExerciseKind.bodyweight => [
        _NumField(
          value: set.reps?.toString() ?? '',
          suffix: 'reps',
          label: 'Reps',
          onSave: (v) => _update(ExerciseSetsCompanion(reps: Value(v?.round()))),
        ),
      ],
      ExerciseKind.cardio => [
        _NumField(
          value: set.durationSec == null ? '' : '${set.durationSec! ~/ 60}',
          suffix: 'min',
          label: 'Minutes',
          onSave: (v) => _update(ExerciseSetsCompanion(durationSec: Value(v == null ? null : (v * 60).round()))),
        ),
        _NumField(
          value: set.distanceKm == null ? '' : Fmt.number(set.distanceKm!),
          suffix: 'km',
          decimal: true,
          label: 'Distance',
          onSave: (v) => _update(ExerciseSetsCompanion(distanceKm: Value(v))),
        ),
      ],
      ExerciseKind.timed => [
        _NumField(
          value: set.durationSec?.toString() ?? '',
          suffix: 'sec',
          label: 'Seconds',
          onSave: (v) => _update(ExerciseSetsCompanion(durationSec: Value(v?.round()))),
        ),
      ],
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: GtSpace.sm),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 10),
            decoration: ShapeDecoration(color: c.surface2, shape: const CircleBorder()),
            child: Text('$index', style: GtText.monoSmall.colored(c.text2)),
          ),
          for (final f in fields) ...[f, const SizedBox(width: GtSpace.sm)],
          const Spacer(),
          Pressable(
            onTap: () => repo.removeSet(set.id),
            haptic: PressHaptic.selection,
            scale: 0.85,
            semanticLabel: 'Remove set $index',
            child: Padding(
              padding: const EdgeInsets.all(GtSpace.sm),
              child: Icon(GtIcons.close, size: 16, color: c.text3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.value,
    required this.suffix,
    required this.label,
    required this.onSave,
    this.decimal = false,
  });

  final String value;
  final String suffix;
  final String label;
  final bool decimal;
  final ValueChanged<double?> onSave;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          child: AutosaveField(
            value: value,
            hint: '–',
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            inputFormatters: decimal ? decimalInput : integerInput,
            textAlign: TextAlign.center,
            style: GtText.mono.sized(15),
            fillColor: c.surface2,
            radius: GtRadius.sm,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
            textInputAction: TextInputAction.next,
            semanticLabel: label,
            onSave: (t) => onSave(parseNumber(t)),
          ),
        ),
        const SizedBox(width: 4),
        Text(suffix, style: GtText.caption.colored(c.text3)),
      ],
    );
  }
}
