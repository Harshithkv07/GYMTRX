import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/haptics.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/navigation_providers.dart';
import '../../logic/providers/widget_sync_provider.dart';
import '../calendar/calendar_screen.dart';
import '../insights/insights_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => ref.read(todayProvider.notifier).refresh());
    WidgetsBinding.instance.addPostFrameCallback((_) => _launch.start());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _launch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final tab = ref.watch(shellTabProvider);
    ref.watch(widgetSyncProvider);
    ref.listen(lockStateProvider, (_, _) => _launch.flush());
    return Scaffold(
      backgroundColor: GtColors.bg,
      resizeToAvoidBottomInset: false,
      // One backdrop group so the header and nav blurs share a single read.
      body: BackdropGroup(
        child: Stack(
          children: [
            _TabStack(index: tab, children: const [CalendarScreen(), InsightsScreen()]),
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
                index: tab,
                onChanged: (i) => ref.read(shellTabProvider.notifier).show(i),
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

/// Keeps both tabs alive (scroll positions survive) and cross-fades with a
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
