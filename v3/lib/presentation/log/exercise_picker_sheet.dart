import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../widgets/controls.dart';
import '../widgets/pressable.dart';
import 'log_sheet.dart';

/// Search the library and add several exercises in one go. Unknown names
/// can be created on the spot.
Future<void> showExercisePicker(
  BuildContext context, {
  required int dayKey,
  required Set<int> groupIds,
  required SheetWrite write,
}) {
  return pickExercises(
    context,
    groupIds: groupIds,
    watchSelected: (ref) => {
      for (final e in ref.watch(entryProvider(dayKey)).value?.exercises ?? const <ExerciseEntry>[]) e.exercise.id,
    },
    onAdd: (id) => write((r, d) async => await r.addExercise(d, id)),
  );
}

/// The library picker. Lists [groupIds]' exercises first. With [single] it
/// returns the first tapped exercise; otherwise each tap calls [onAdd] and the
/// sheet stays open. [watchSelected] marks exercises that are already in.
Future<int?> pickExercises(
  BuildContext context, {
  String title = 'Add exercises',
  Set<int> groupIds = const {},
  Set<int> Function(WidgetRef ref)? watchSelected,
  void Function(int id)? onAdd,
  bool single = false,
}) {
  return showModalBottomSheet<int>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _ExercisePicker(
      title: title,
      groupIds: groupIds,
      watchSelected: watchSelected,
      onAdd: onAdd,
      single: single,
    ),
  );
}

class _ExercisePicker extends ConsumerStatefulWidget {
  const _ExercisePicker({
    required this.title,
    required this.groupIds,
    required this.watchSelected,
    required this.onAdd,
    required this.single,
  });

  final String title;
  final Set<int> groupIds;
  final Set<int> Function(WidgetRef ref)? watchSelected;
  final void Function(int id)? onAdd;
  final bool single;

  @override
  ConsumerState<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends ConsumerState<_ExercisePicker> {
  final _search = TextEditingController();
  final _added = <int>{};
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _add(int exerciseId) {
    Haptics.selection();
    if (widget.single) {
      Navigator.pop(context, exerciseId);
      return;
    }
    setState(() => _added.add(exerciseId));
    widget.onAdd?.call(exerciseId);
  }

  Future<void> _create(String name, List<MuscleGroup> groups) async {
    final groupId = groups.where((g) => widget.groupIds.contains(g.id)).firstOrNull?.id;
    final id = await ref.read(libraryRepoProvider).addExercise(name, groupId: groupId);
    _add(id);
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final all = [for (final e in ref.watch(exercisesProvider).value ?? const <Exercise>[]) if (!e.hidden) e];
    final groups = ref.watch(groupsProvider).value ?? const <MuscleGroup>[];
    final inEntry = widget.watchSelected?.call(ref) ?? const <int>{};
    final q = _query.trim().toLowerCase();

    final rows = <Widget>[];
    if (q.isEmpty) {
      // Chosen groups first, then the rest in chip order, then ungrouped.
      final ordered = [
        ...groups.where((g) => widget.groupIds.contains(g.id)),
        ...groups.where((g) => !widget.groupIds.contains(g.id)),
      ];
      for (final g in ordered) {
        final list = all.where((e) => e.groupId == g.id).toList();
        if (list.isEmpty) continue;
        rows.add(SectionHeader(g.name, padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xl, GtSpace.gutter, GtSpace.xs)));
        rows.addAll(list.map((e) => _row(e, inEntry)));
      }
      final other = all.where((e) => e.groupId == null).toList();
      if (other.isNotEmpty) {
        rows.add(const SectionHeader('Other', padding: EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xl, GtSpace.gutter, GtSpace.xs)));
        rows.addAll(other.map((e) => _row(e, inEntry)));
      }
    } else {
      final matches = all.where((e) => e.name.toLowerCase().contains(q)).toList()
        ..sort((a, b) {
          final aStarts = a.name.toLowerCase().startsWith(q) ? 0 : 1;
          final bStarts = b.name.toLowerCase().startsWith(q) ? 0 : 1;
          return aStarts != bStarts ? aStarts - bStarts : a.name.compareTo(b.name);
        });
      final exact = all.any((e) => e.name.toLowerCase() == q);
      if (!exact) rows.add(_CreateRow(name: _query.trim(), onTap: () => _create(_query.trim(), groups)));
      rows.addAll(matches.map((e) => _row(e, inEntry)));
    }

    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.86 - media.viewInsets.bottom * 0.5,
        child: Column(
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xs, GtSpace.lg, GtSpace.md),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title, style: GtText.title)),
                  Pressable(
                    onTap: () => Navigator.pop(context),
                    scale: 0.92,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: widget.single ? GtColors.s2 : context.accent,
                        shape: squircle(19),
                      ),
                      child: Text(
                        widget.single ? 'Cancel' : 'Done',
                        style: GtText.label
                            .sized(15)
                            .weight(600)
                            .colored(widget.single ? GtColors.text1 : GtColors.onAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                textCapitalization: TextCapitalization.words,
                style: GtText.body,
                decoration: InputDecoration(
                  hintText: 'Search or create',
                  prefixIcon: const Icon(GtIcons.search, size: 18, color: GtColors.text2),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(GtIcons.close, size: 16, color: GtColors.text2),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: media.viewPadding.bottom + GtSpace.xxl),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: rows,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(Exercise e, Set<int> inEntry) {
    final done = !widget.single && (inEntry.contains(e.id) || _added.contains(e.id));
    return Pressable(
      key: ValueKey(e.id),
      onTap: done ? null : () => _add(e.id),
      haptic: PressHaptic.none,
      scale: 0.98,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter),
        child: Row(
          children: [
            Expanded(
              child: Text(e.name, style: GtText.body.colored(done ? GtColors.text2 : GtColors.text1)),
            ),
            AnimatedSwitcher(
              duration: GtMotion.of(context, GtMotion.medium),
              transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
              child: done
                  ? Icon(GtIcons.check, key: const ValueKey(true), size: 18, color: context.accent)
                  : const Icon(GtIcons.add, key: ValueKey(false), size: 16, color: GtColors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateRow extends StatelessWidget {
  const _CreateRow({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.xs),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          decoration: ShapeDecoration(color: context.gt.accentMuted, shape: squircle(GtRadius.md)),
          child: Row(
            children: [
              Icon(GtIcons.add, size: 16, color: context.accent),
              const SizedBox(width: GtSpace.md),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Create '),
                      TextSpan(text: '“$name”', style: GtText.body.weight(600)),
                    ],
                  ),
                  style: GtText.body.colored(context.accent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
