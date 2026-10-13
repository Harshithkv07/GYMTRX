import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../../data/database/app_database.dart';
import '../../logic/providers/data_providers.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/gt_chip.dart';
import '../widgets/large_title_header.dart';
import '../widgets/pressable.dart';
import 'settings_widgets.dart';
import '../../logic/features.dart';
import '../../logic/providers/settings_provider.dart';
import '../guide/exercise_guide_sheet.dart';
import '../guide/guide_browser_screen.dart';
import '../widgets/surface.dart';

/// Show, hide, rename, reorder and add muscle groups. Hiding never touches
/// past entries.
class GroupsLibraryScreen extends ConsumerStatefulWidget {
  const GroupsLibraryScreen({super.key});

  @override
  ConsumerState<GroupsLibraryScreen> createState() => _GroupsLibraryScreenState();
}

class _GroupsLibraryScreenState extends ConsumerState<GroupsLibraryScreen> {
  List<int>? _pendingOrder;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(libraryRepoProvider);
    var groups = ref.watch(groupsProvider).value ?? const <MuscleGroup>[];
    if (_pendingOrder case final order?) {
      if (order.length == groups.length && order.indexed.every((p) => groups[p.$1].id == p.$2)) {
        _pendingOrder = null;
      } else {
        groups = [...groups]..sort((a, b) => order.indexOf(a.id).compareTo(order.indexOf(b.id)));
      }
    }
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(title: 'Muscle groups', topPadding: padding.top, showBack: true),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
              child: Text(
                'Hidden groups don’t appear when logging; past entries keep them. Hold and drag to reorder.',
                style: GtText.caption,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
            sliver: SliverReorderableList(
              itemCount: groups.length,
              onReorderStart: (_) => Haptics.medium(),
              onReorder: (from, to) {
                if (to > from) to -= 1;
                final ids = [for (final g in groups) g.id];
                ids.insert(to, ids.removeAt(from));
                setState(() => _pendingOrder = ids);
                repo.reorderGroups(ids);
              },
              proxyDecorator: (child, _, _) => Material(color: Colors.transparent, child: child),
              itemBuilder: (context, i) {
                final g = groups[i];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(g.id),
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: GtSpace.sm),
                    child: DecoratedBox(
                      decoration: ShapeDecoration(color: GtColors.s1, shape: squircle(GtRadius.md)),
                      child: SettingsRow(
                        icon: g.hidden ? GtIcons.eyeOff : GtIcons.drag,
                        title: g.name,
                        subtitle: g.hidden ? 'Hidden' : null,
                        onTap: () async {
                          final name = await showTextInputSheet(context, title: 'Rename', initial: g.name);
                          if (name != null) repo.renameGroup(g.id, name);
                        },
                        trailing: GtSwitch(value: !g.hidden, onChanged: (v) => repo.setGroupHidden(g.id, !v)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, padding.bottom + GtSpace.x4),
              child: GtButton(
                label: 'Add muscle group',
                icon: GtIcons.add,
                kind: GtButtonKind.secondary,
                expand: true,
                onTap: () async {
                  final name = await showTextInputSheet(
                    context,
                    title: 'New muscle group',
                    hint: 'e.g. Hamstrings',
                    action: 'Add',
                  );
                  if (name != null) repo.addGroup(name);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Every exercise, including hidden ones. Tap to rename, regroup, change the
/// kind of sets it records, or hide it.
class ExercisesLibraryScreen extends ConsumerStatefulWidget {
  const ExercisesLibraryScreen({super.key});

  @override
  ConsumerState<ExercisesLibraryScreen> createState() => _ExercisesLibraryScreenState();
}

class _ExercisesLibraryScreenState extends ConsumerState<ExercisesLibraryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider).value ?? const <Exercise>[];
    final groups = ref.watch(groupsByIdProvider);
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty ? exercises : exercises.where((e) => e.name.toLowerCase().contains(q)).toList();
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(
              title: 'Exercises',
              topPadding: padding.top,
              showBack: true,
              trailing: Pressable(
                onTap: () async {
                  final name = await showTextInputSheet(
                    context,
                    title: 'New exercise',
                    hint: 'e.g. Cable Y-Raise',
                    action: 'Add',
                  );
                  if (name == null) return;
                  final id = await ref.read(libraryRepoProvider).addExercise(name);
                  final created = (await ref.read(exercisesProvider.future)).where((e) => e.id == id).firstOrNull;
                  if (created != null && context.mounted) showExerciseEditor(context, created);
                },
                scale: 0.9,
                semanticLabel: 'New exercise',
                child: const Padding(padding: EdgeInsets.all(GtSpace.sm), child: Icon(GtIcons.add, size: 22)),
              ),
            ),
          ),
          if (ref.watch(settingsProvider.select((s) => s.has(AppFeature.guide))))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, GtSpace.md),
                child: GtCard(
                  onTap: () => openGuideBrowser(context),
                  padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.md, GtSpace.md),
                  child: Row(
                    children: [
                      Icon(GtIcons.guide, size: 20, color: context.accent),
                      const SizedBox(width: GtSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Browse the exercise guide', style: GtText.body.weight(600)),
                            Text('800+ exercises with pictures. Add any to your list.', style: GtText.caption),
                          ],
                        ),
                      ),
                      const Icon(GtIcons.chevronRight, size: 14, color: GtColors.text3),
                    ],
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, GtSpace.lg),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: GtText.body,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(GtIcons.search, size: 18, color: GtColors.text2),
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: shown.length,
            itemBuilder: (context, i) {
              final e = shown[i];
              final group = groups[e.groupId]?.name;
              return Pressable(
                onTap: () => showExerciseEditor(context, e),
                scale: 0.98,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e.name, style: GtText.body.colored(e.hidden ? GtColors.text3 : GtColors.text1)),
                      ),
                      Text(
                        e.hidden ? 'Hidden' : group ?? '',
                        style: GtText.caption.colored(e.hidden ? GtColors.text3 : GtColors.text2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom + GtSpace.x4)),
        ],
      ),
    );
  }
}

Future<void> showExerciseEditor(BuildContext context, Exercise exercise) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _ExerciseEditor(exerciseId: exercise.id),
  );
}

class _ExerciseEditor extends ConsumerWidget {
  const _ExerciseEditor({required this.exerciseId});

  final int exerciseId;

  static String kindLabel(ExerciseKind k) => switch (k) {
    ExerciseKind.strength => 'Weight × reps',
    ExerciseKind.bodyweight => 'Reps',
    ExerciseKind.cardio => 'Time · distance',
    ExerciseKind.timed => 'Seconds',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(libraryRepoProvider);
    final e = ref.watch(exercisesByIdProvider)[exerciseId];
    final groups = ref.watch(groupsProvider).value ?? const <MuscleGroup>[];
    if (e == null) return const SizedBox(height: 200);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: GtSpace.xs),
            Row(
              children: [
                Expanded(child: Text(e.name, style: GtText.title)),
                Pressable(
                  onTap: () async {
                    final name = await showTextInputSheet(context, title: 'Rename', initial: e.name);
                    if (name != null) repo.updateExercise(e.id, name: name);
                  },
                  child: const Padding(padding: EdgeInsets.all(GtSpace.sm), child: Icon(GtIcons.edit, size: 20)),
                ),
              ],
            ),
            const SectionHeader('Muscle group', padding: EdgeInsets.fromLTRB(0, GtSpace.xl, 0, GtSpace.md)),
            Wrap(
              spacing: GtSpace.sm,
              runSpacing: GtSpace.sm,
              children: [
                for (final g in groups)
                  GtChip(
                    label: g.name,
                    height: 36,
                    selected: g.id == e.groupId,
                    onTap: () => repo.updateExercise(e.id, groupId: Value(g.id == e.groupId ? null : g.id)),
                  ),
              ],
            ),
            const SectionHeader('Records', padding: EdgeInsets.fromLTRB(0, GtSpace.xl, 0, GtSpace.md)),
            Wrap(
              spacing: GtSpace.sm,
              runSpacing: GtSpace.sm,
              children: [
                for (final k in ExerciseKind.values)
                  GtChip(
                    label: kindLabel(k),
                    height: 36,
                    selected: k == e.kind,
                    onTap: () => repo.updateExercise(e.id, kind: k),
                  ),
              ],
            ),
            if (ref.watch(settingsProvider.select((s) => s.has(AppFeature.guide)))) ...[
              const SizedBox(height: GtSpace.xl),
              DecoratedBox(
                decoration: ShapeDecoration(color: GtColors.s2, shape: squircle(GtRadius.md)),
                child: SettingsRow(
                  icon: GtIcons.guide,
                  title: 'Exercise guide',
                  subtitle: e.guideId == null ? 'Not linked yet: tap to find it' : 'Pictures, muscles and steps',
                  onTap: () => showExerciseGuide(context, e),
                ),
              ),
            ],
            const SizedBox(height: GtSpace.sm),
            DecoratedBox(
              decoration: ShapeDecoration(color: GtColors.s2, shape: squircle(GtRadius.md)),
              child: SettingsRow(
                icon: e.hidden ? GtIcons.eyeOff : GtIcons.eye,
                title: 'Show when logging',
                subtitle: 'Past entries always keep it',
                trailing: GtSwitch(value: !e.hidden, onChanged: (v) => repo.setExerciseHidden(e.id, !v)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
