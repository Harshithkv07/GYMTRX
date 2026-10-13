import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/guide.dart';
import '../../logic/guide_mapping.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/guide_providers.dart';
import '../widgets/gt_button.dart';
import '../widgets/gt_chip.dart';
import '../widgets/large_title_header.dart';
import '../widgets/pressable.dart';
import '../widgets/toast.dart';
import 'exercise_guide_sheet.dart';

Future<void> openGuideBrowser(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GuideBrowserScreen()));

/// Every exercise in the guide: search, filter by muscle group or equipment,
/// and add any of them to your library.
class GuideBrowserScreen extends ConsumerStatefulWidget {
  const GuideBrowserScreen({super.key});

  @override
  ConsumerState<GuideBrowserScreen> createState() => _GuideBrowserScreenState();
}

class _GuideBrowserScreenState extends ConsumerState<GuideBrowserScreen> {
  String _query = '';
  String? _group;
  String? _equipment;

  static const _equipmentOrder = [
    'barbell',
    'dumbbell',
    'machine',
    'cable',
    'body only',
    'kettlebells',
    'bands',
    'e-z curl bar',
  ];

  Future<void> _add(GuideExercise g) async {
    final idBySlug = {for (final gr in ref.read(groupsProvider).value ?? const []) ?gr.slug: gr.id};
    await ref
        .read(libraryRepoProvider)
        .addExercise(g.name, groupId: idBySlug[guideGroupSlug(g)], kind: guideKind(g), guideId: g.id);
    Haptics.medium();
    Toasts.show('${g.name} added to your exercises');
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(guideCatalogProvider);
    final mine = {for (final e in ref.watch(exercisesProvider).value ?? const []) ?e.guideId};
    final groups = ref.watch(visibleGroupsProvider);
    final padding = MediaQuery.paddingOf(context);

    final all = catalog.value?.values.toList() ?? const <GuideExercise>[];
    final q = _query.trim();
    var shown = q.isEmpty ? ([...all]..sort((a, b) => a.name.compareTo(b.name))) : guideMatches(q, all, limit: 200);
    shown = [
      for (final g in shown)
        if ((_group == null || guideGroupSlug(g) == _group) && (_equipment == null || g.equipment == _equipment)) g,
    ];

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(title: 'Exercise guide', topPadding: padding.top, showBack: true),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, GtSpace.md),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: GtText.body,
                decoration: const InputDecoration(
                  hintText: 'Search 800+ exercises',
                  prefixIcon: Icon(GtIcons.search, size: 18, color: GtColors.text2),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
                children: [
                  for (final g in groups)
                    if (g.slug != null && g.slug != 'full_body')
                      Padding(
                        padding: const EdgeInsets.only(right: GtSpace.sm),
                        child: GtChip(
                          label: g.name,
                          height: 34,
                          horizontalPadding: 14,
                          selected: _group == g.slug,
                          onTap: () => setState(() => _group = _group == g.slug ? null : g.slug),
                        ),
                      ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.sm, GtSpace.lg, 0),
                children: [
                  for (final eq in _equipmentOrder)
                    Padding(
                      padding: const EdgeInsets.only(right: GtSpace.sm),
                      child: GtChip(
                        label: guideEquipmentLabel(eq),
                        height: 34,
                        horizontalPadding: 14,
                        selected: _equipment == eq,
                        onTap: () => setState(() => _equipment = _equipment == eq ? null : eq),
                      ),
                    ),
                ],
              ),
            ),
          ),
          switch (catalog) {
            AsyncError() => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(GtSpace.x3),
                child: Column(
                  children: [
                    Text('Connect once to load the guide', style: GtText.titleSmall),
                    const SizedBox(height: GtSpace.lg),
                    GtButton(
                      label: 'Try again',
                      kind: GtButtonKind.secondary,
                      onTap: () => ref.invalidate(guideCatalogProvider),
                    ),
                  ],
                ),
              ),
            ),
            AsyncData() => SliverList.builder(
              itemCount: shown.length,
              itemBuilder: (context, i) {
                final g = shown[i];
                final have = mine.contains(g.id);
                return Pressable(
                  onTap: () => showGuideEntry(
                    context,
                    g,
                    action: have
                        ? null
                        : GtButton(
                            label: 'Add to my exercises',
                            icon: GtIcons.add,
                            expand: true,
                            onTap: () {
                              Navigator.pop(context);
                              _add(g);
                            },
                          ),
                  ),
                  scale: 0.98,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter, vertical: 11),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: GtText.body),
                              Text(
                                [
                                  ...g.primaryMuscles,
                                  if (g.equipment case final eq?) guideEquipmentLabel(eq),
                                ].join(' · '),
                                style: GtText.caption,
                              ),
                            ],
                          ),
                        ),
                        if (have)
                          Text('IN YOUR LIST', style: GtText.overline.colored(context.accent))
                        else
                          const Icon(GtIcons.chevronRight, size: 14, color: GtColors.text3),
                      ],
                    ),
                  ),
                );
              },
            ),
            _ => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(GtSpace.x4),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          },
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom + GtSpace.x4)),
        ],
      ),
    );
  }
}
