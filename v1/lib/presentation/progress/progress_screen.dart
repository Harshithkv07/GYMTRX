import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../../logic/features.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/progress_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../../logic/streaks.dart';
import '../photos/photo_views.dart';
import '../settings/settings_screen.dart';
import '../share/share_actions.dart';
import '../shell/glass_nav_bar.dart';
import '../widgets/controls.dart';
import '../widgets/large_title_header.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';
import '../widgets/toast.dart';
import 'goal_sheets.dart';
import 'goal_widgets.dart';
import 'program_editor.dart';
import 'records_screen.dart';
import 'streak_hero.dart';

/// Streak, goals, records, the weekly program and progress photos: each only
/// when its feature is on.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.paddingOf(context);
    final photoCount = ref.watch(photosProvider.select((p) => p.value?.length ?? 0));
    final features = ref.watch(settingsProvider.select((s) => s.features));
    bool on(AppFeature f) => features.contains(f);

    // Milestones (4, 8, 12, 26, 52 weeks…) get one celebration each. The tab
    // stays mounted, so this hears every change, not only while it's shown.
    ref.listen(streakProvider, (prev, next) {
      if (prev == null || prev.weekStartKey == 0 || next.current <= prev.current) return;
      if (!ref.read(settingsProvider).has(AppFeature.streak)) return;
      if (!isStreakMilestone(next.current) || next.current <= ref.read(settingsProvider).streakCelebrated) return;
      ref.read(settingsProvider.notifier).markStreakCelebrated(next.current);
      // After the "Logged" toast that usually comes with it.
      Future.delayed(const Duration(milliseconds: 4200), () {
        if (!context.mounted) return;
        Haptics.celebrate();
        Toasts.show(
          '${next.current}-week streak. Keep it burning!',
          actionLabel: 'Share',
          onAction: () => shareStreak(context, ref, next),
          duration: const Duration(seconds: 6),
        );
      });
    });

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: LargeTitleHeader(
            title: 'Progress',
            topPadding: padding.top,
            trailing: GtIconButton(
              icon: GtIcons.settings,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
              color: Colors.transparent,
              iconSize: 22,
              semanticLabel: 'Settings',
            ),
          ),
        ),
        SliverList.list(
          children: [
            if (on(AppFeature.streak))
              Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.sm, GtSpace.lg, 0),
                child: StreakHero(onShare: (s) => shareStreak(context, ref, s)),
              ),
            if (on(AppFeature.goals)) ...[
              SectionHeader(
                'Goals',
                trailing: _AddLink(label: 'ADD', semanticLabel: 'Add a goal', onTap: () => addGoal(context, ref)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: GtSpace.lg),
                child: GoalsCard(),
              ),
            ],
            if (on(AppFeature.program)) ...[
              const SectionHeader('This week'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: GtSpace.lg),
                child: ProgramWeekCard(),
              ),
            ],
            if (on(AppFeature.records)) ...[
              const SectionHeader('Records'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
                child: RecentRecordsCard(
                  onShare: (r) => sharePr(context, ref, r),
                  onShareFromList: (c, r) => sharePr(c, ref, r),
                ),
              ),
            ],
            if (on(AppFeature.photos)) ...[
              SectionHeader(
                'Photos',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (photoCount >= 2) ...[
                      _AddLink(label: 'COMPARE', icon: GtIcons.compare, onTap: () => openPhotoCompare(context)),
                      const SizedBox(width: GtSpace.lg),
                    ],
                    if (photoCount > 0)
                      _AddLink(label: 'ALL', icon: GtIcons.images, onTap: () => openPhotoGallery(context)),
                  ],
                ),
              ),
              const ProgressPhotosCard(),
            ],
            SizedBox(height: padding.bottom + GlassNavBar.height + 48),
          ],
        ),
      ],
    );
  }
}

class _AddLink extends StatelessWidget {
  const _AddLink({required this.label, required this.onTap, this.icon = GtIcons.add, this.semanticLabel});

  final String label;
  final IconData icon;
  final String? semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      semanticLabel: semanticLabel ?? label,
      child: Row(
        children: [
          Icon(icon, size: 12, color: context.accent),
          const SizedBox(width: 4),
          Text(label, style: GtText.overline.colored(context.accent)),
        ],
      ),
    );
  }
}
