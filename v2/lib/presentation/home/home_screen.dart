import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/navigation_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../art/dot_text.dart';
import '../art/hero_art.dart';
import '../calendar/session_card.dart';
import '../log/log_actions.dart';
import '../log/weigh_in_sheet.dart';
import '../settings/settings_screen.dart';
import '../shell/nav_bar.dart';
import '../widgets/controls.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';
import 'home_bento.dart';
import 'week_strip.dart';

/// The first tab: a greeting over the illustrated header, this week, a few
/// neutral numbers and the latest sessions.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();
  var _yearView = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openSettings() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final summaries = ref.watch(summariesProvider);
    final recent = [for (final e in summaries.value ?? const <EntrySummary>[]) if (e.dayKey <= today) e].take(5).toList();
    final padding = MediaQuery.paddingOf(context);
    final reduced = GtMotion.reduced(context);

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverToBoxAdapter(
          child: _Header(scroll: _scroll, topPadding: padding.top, onSettings: _openSettings),
        ),
        const SliverToBoxAdapter(child: WeekStrip()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.lg, GtSpace.gutter, GtSpace.md),
            child: UnderlineTabs(
              labels: const ['This month', 'This year'],
              index: _yearView ? 1 : 0,
              onChanged: (i) => setState(() => _yearView = i == 1),
            ),
          ),
        ),
        SliverToBoxAdapter(child: HomeBento(yearView: _yearView)),
        SliverToBoxAdapter(
          child: SectionHeader(
            'Recent sessions',
            trailing: recent.isEmpty
                ? null
                : LinkAction('See all', onTap: () => ref.read(shellTabProvider.notifier).show(1)),
          ),
        ),
        if (summaries.hasValue && recent.isEmpty)
          const SliverToBoxAdapter(child: _EmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
            sliver: SliverList.separated(
              itemCount: recent.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final card = SessionCard(key: ValueKey(recent[i].dayKey), entry: recent[i], heroScope: 'home');
                if (reduced) return card;
                return card
                    .animate(key: ValueKey('home-${recent[i].dayKey}'))
                    .fadeIn(duration: 320.ms, delay: (40 * i).ms)
                    .moveY(begin: 10, end: 0, duration: 420.ms, delay: (40 * i).ms, curve: GtMotion.emphasized);
              },
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: padding.bottom + GtNavBar.height + 52)),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.scroll, required this.topPadding, required this.onSettings});

  final ScrollController scroll;
  final double topPadding;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final name = ref.watch(settingsProvider.select((s) => s.userName));
    final height = topPadding + 312;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // The art drifts at a third of the scroll speed: a quiet parallax.
          Positioned.fill(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: scroll,
                builder: (context, child) {
                  final offset = scroll.hasClients ? scroll.offset.clamp(0.0, height) : 0.0;
                  return Transform.translate(offset: Offset(0, offset * 0.35), child: child);
                },
                child: const HeroArt(
                  asset: GtArt.homeHeader,
                  alignment: Alignment(0.3, -0.55),
                  fadeFrom: 0.3,
                  fadeTo: 0.9,
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 6,
            left: GtSpace.lg,
            right: GtSpace.lg,
            child: Row(
              children: [
                _Avatar(name: name, onTap: onSettings),
                const Spacer(),
                CircleButton(
                  icon: GtIcons.weight,
                  semanticLabel: 'Add weigh-in',
                  onTap: () => showWeighInSheet(context, ref, dayKey: logicalToday(ref)),
                ),
                const SizedBox(width: GtSpace.sm),
                CircleButton(icon: GtIcons.settings, semanticLabel: 'Settings', onTap: onSettings),
              ],
            ),
          ),
          Positioned(
            left: GtSpace.gutter,
            right: GtSpace.gutter,
            bottom: GtSpace.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty) ...[
                  Text('Hey, $name', style: GtText.label.sized(15).weight(500).colored(c.text2)),
                  const SizedBox(height: 6),
                ],
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: DotText(
                    'WELCOME BACK',
                    style: GtText.dot(40, weight: 400).colored(c.text1),
                    maxLines: 1,
                    delay: const Duration(milliseconds: 150),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A round monogram of the user's name; opens Settings.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final initial = name.isEmpty ? null : name.characters.first.toUpperCase();
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: 'Profile and settings',
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: c.ink,
          shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: c.isDark ? 0.12 : 0.7), width: 2)),
        ),
        child: initial == null
            ? Icon(GtIcons.user, size: 20, color: c.onInk)
            : Text(initial, style: GtText.label.sized(17).weight(600).colored(c.accentOnInk)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
      child: GtCard(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: Text(
          'Your gym days will appear here.\nTap ＋ after a session to log it.',
          style: GtText.body.colored(c.text2),
        ),
      ),
    );
  }
}
