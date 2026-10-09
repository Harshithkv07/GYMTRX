import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
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
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _ExercisePicker(dayKey: dayKey, groupIds: groupIds, write: write),
  );
}

class _ExercisePicker extends ConsumerStatefulWidget {
  const _ExercisePicker({required this.dayKey, required this.groupIds, required this.write});

  final int dayKey;
  final Set<int> groupIds;
  final SheetWrite write;

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
    setState(() => _added.add(exerciseId));
    widget.write((r, d) async => await r.addExercise(d, exerciseId));
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
    final c = context.c;
    final all = [for (final e in ref.watch(exercisesProvider).value ?? const <Exercise>[]) if (!e.hidden) e];
    final groups = ref.watch(groupsProvider).value ?? const <MuscleGroup>[];
    final inEntry = <int>{
      for (final e in ref.watch(entryProvider(widget.dayKey)).value?.exercises ?? const <ExerciseEntry>[]) e.exercise.id,
    };
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
        rows.add(_GroupHeader(g.name));
        rows.addAll(list.map((e) => _row(e, inEntry)));
      }
      final other = all.where((e) => e.groupId == null).toList();
      if (other.isNotEmpty) {
        rows.add(const _GroupHeader('Other'));
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
                  Expanded(child: Text('Add exercises', style: GtText.title)),
                  Pressable(
                    onTap: () => Navigator.pop(context),
                    scale: 0.92,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(color: c.ink, shape: const StadiumBorder()),
                      child: Text('Done', style: GtText.label.sized(15).weight(600).colored(c.accentOnInk)),
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
                  prefixIcon: Icon(GtIcons.search, size: 18, color: c.text2),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(GtIcons.close, size: 16, color: c.text2),
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
    final c = context.c;
    final done = inEntry.contains(e.id) || _added.contains(e.id);
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
              child: Text(e.name, style: GtText.body.colored(done ? c.text2 : c.text1)),
            ),
            AnimatedSwitcher(
              duration: GtMotion.of(context, GtMotion.medium),
              transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
              child: done
                  ? Container(
                      key: const ValueKey(true),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                      child: Icon(GtIcons.check, size: 13, color: c.onAccent),
                    )
                  : Icon(GtIcons.add, key: const ValueKey(false), size: 16, color: c.text3),
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
    final c = context.c;
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.xs),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          decoration: ShapeDecoration(color: c.ink, shape: const StadiumBorder()),
          child: Row(
            children: [
              Icon(GtIcons.add, size: 16, color: c.accentOnInk),
              const SizedBox(width: GtSpace.md),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Create '),
                      TextSpan(text: '“$name”', style: GtText.body.weight(600)),
                    ],
                  ),
                  style: GtText.body.colored(c.onInk),
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

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xl, GtSpace.gutter, GtSpace.xs),
      child: Text(name.toUpperCase(), style: context.tx.tag),
    );
  }
}
