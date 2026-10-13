import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/haptics.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/goal_watch_provider.dart';
import '../../logic/providers/health_providers.dart';
import '../../logic/providers/holiday_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../../logic/providers/navigation_providers.dart';
import '../../logic/providers/reminder_sync_provider.dart';
import '../../logic/providers/widget_sync_provider.dart';
import '../calendar/calendar_screen.dart';
import '../insights/insights_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/drive_actions.dart';
import '../tour/home_tour.dart';
import '../lock/lock_gate.dart';
import '../log/log_actions.dart';
import 'glass_nav_bar.dart';
import 'launch_actions.dart';
import 'plus_menu.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final AppLifecycleListener _lifecycle;
  late final LaunchActions _launch = LaunchActions(context, ref);
  Timer? _syncTimer;
  var _touring = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        ref.read(todayProvider.notifier).refresh();
        ref.read(logicalTodayProvider.notifier).refresh();
        _syncOut();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launch.start();
      _maybeStartTour();
      // Give the first frames room before talking to Health Connect or Drive.
      _syncTimer = Timer(const Duration(seconds: 2), _syncOut);
    });
  }

  /// The home tour, once on this phone or again when Settings asks for it.
  /// Waits out the fade in from onboarding, and never starts over the lock
  /// screen or a sheet a launch action opened.
  void _maybeStartTour() {
    Future<void>.delayed(const Duration(milliseconds: 700), () async {
      if (!mounted || _touring) return;
      if (ref.read(settingsProvider).tourSeen || ref.read(lockStateProvider)) return;
      if (ModalRoute.of(context)?.isCurrent == false) return;
      _touring = true;
      ref.read(shellTabProvider.notifier).show(ShellTab.calendar);
      // Let the calendar fade in before measuring it.
      await Future<void>.delayed(GtMotion.of(context, const Duration(milliseconds: 320)));
      if (mounted) {
        final extra = [for (final t in ref.read(visibleTabsProvider).skip(1)) _navTabFor(t).label];
        await showHomeTour(context, extraTabs: extra);
      }
      _touring = false;
      if (mounted) ref.read(settingsProvider.notifier).setTourSeen(true);
    });
  }

  /// Health Connect reads and the daily Drive backup, both quiet.
  void _syncOut() {
    if (!mounted) return;
    ref.read(healthSyncProvider.notifier).syncAll();
    if (ref.read(settingsProvider).holidayCalendarIds.isNotEmpty) ref.read(holidaysProvider.notifier).refresh();
    maybeAutoBackup(ref);
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _lifecycle.dispose();
    _launch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final tabs = ref.watch(visibleTabsProvider);
    // A tab whose features were all turned off falls back to the calendar.
    final index = tabs.indexOf(ref.watch(shellTabProvider)).clamp(0, tabs.length - 1);
    ref.watch(widgetSyncProvider);
    ref.watch(goalWatchProvider);
    ref.watch(reminderSyncProvider);
    ref.watch(healthSyncProvider);
    ref.listen(lockStateProvider, (_, locked) {
      _launch.flush();
      if (!locked) _maybeStartTour();
    });
    ref.listen(settingsProvider.select((s) => s.tourSeen), (_, seen) {
      if (!seen) _maybeStartTour();
    });
    return Scaffold(
      backgroundColor: GtColors.bg,
      resizeToAvoidBottomInset: false,
      // One backdrop group so the header and nav blurs share a single read.
      body: BackdropGroup(
        child: Stack(
          children: [
            _TabStack(index: index, children: [for (final t in tabs) _screenFor(t)]),
            // Soft fade so content dims before it slides under the nav.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomInset + 110,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [GtColors.bg.withValues(alpha: 0.85), GtColors.bg.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: GtSpace.lg,
              right: GtSpace.lg,
              bottom: bottomInset + GtSpace.md,
              child: GlassNavBar(
                tabs: [for (final t in tabs) _navTabFor(t)],
                index: index,
                onChanged: (i) => ref.read(shellTabProvider.notifier).show(tabs[i]),
                onAdd: () => openLogSheet(context, ref, dayKey: logicalToday(ref)),
                onAddLongPress: (anchor) {
                  Haptics.medium();
                  showPlusMenu(context, ref, anchor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _screenFor(int tab) => switch (tab) {
  ShellTab.progress => const ProgressScreen(key: ValueKey(ShellTab.progress)),
  ShellTab.insights => const InsightsScreen(key: ValueKey(ShellTab.insights)),
  _ => const CalendarScreen(key: ValueKey(ShellTab.calendar)),
};

NavTab _navTabFor(int tab) => switch (tab) {
  ShellTab.progress => GlassNavBar.progress,
  ShellTab.insights => GlassNavBar.insights,
  _ => GlassNavBar.calendar,
};

/// Keeps every tab alive (scroll positions survive) and cross-fades with a
/// slight scale, Material "fade through" style.
class _TabStack extends StatelessWidget {
  const _TabStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final duration = GtMotion.of(context, const Duration(milliseconds: 300));
    return Stack(
      children: [
        for (var i = 0; i < children.length; i++)
          IgnorePointer(
            // Keyed by screen, so a tab keeps its state when another one is
            // turned off and the list shifts.
            key: children[i].key,
            ignoring: i != index,
            // The fade itself must keep ticking; only the hidden tab's own
            // animations are paused.
            child: AnimatedOpacity(
              duration: duration,
              curve: i == index ? const Interval(0.3, 1, curve: Curves.easeOut) : const Interval(0, 0.4),
              opacity: i == index ? 1 : 0,
              child: AnimatedScale(
                duration: duration,
                curve: GtMotion.emphasized,
                scale: i == index ? 1 : 0.97,
                child: TickerMode(enabled: i == index, child: children[i]),
              ),
            ),
          ),
      ],
    );
  }
}
