import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/motion/motion.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'logic/providers/settings_provider.dart';
import 'presentation/art/hero_art.dart';
import 'presentation/lock/lock_gate.dart';
import 'presentation/shell/app_shell.dart';
import 'presentation/welcome/welcome_screen.dart';
import 'presentation/widgets/toast.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class GymtrxApp extends ConsumerWidget {
  const GymtrxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(settingsProvider.select((s) => s.accent));
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp(
      title: 'GYMTRX',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: buildGtTheme(GtColors.light(accent)),
      darkTheme: buildGtTheme(GtColors.dark(accent)),
      themeMode: mode,
      // A new accent or theme tweens through the whole app instead of snapping.
      themeAnimationDuration: const Duration(milliseconds: 500),
      themeAnimationCurve: GtMotion.emphasized,
      scrollBehavior: const GtScrollBehavior(),
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: gtOverlayStyle(Theme.of(context).brightness),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: ToastHost(child: LockGate(child: child!)),
        ),
      ),
      home: const _RootGate(),
    );
  }
}

/// First launch shows the welcome page; afterwards the app opens straight
/// into the shell. Cross-fades between the two.
class _RootGate extends ConsumerStatefulWidget {
  const _RootGate();

  @override
  ConsumerState<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<_RootGate> {
  var _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      GtArt.precache(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seen = ref.watch(settingsProvider.select((s) => s.welcomeSeen));
    return AnimatedSwitcher(
      duration: GtMotion.of(context, const Duration(milliseconds: 650)),
      switchInCurve: GtMotion.emphasized,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: Tween(begin: 1.03, end: 1.0).animate(animation), child: child),
      ),
      child: seen ? const AppShell(key: ValueKey('shell')) : const WelcomeScreen(key: ValueKey('welcome')),
    );
  }
}

/// Rubber-band scrolling everywhere, no glow.
class GtScrollBehavior extends MaterialScrollBehavior {
  const GtScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
