import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/motion/motion.dart';
import 'core/theme/app_theme.dart';
import 'logic/providers/settings_provider.dart';
import 'presentation/lock/lock_gate.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/shell/app_shell.dart';
import 'presentation/widgets/toast.dart';

const gtOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
);

final rootNavigatorKey = GlobalKey<NavigatorState>();

class GymtrxApp extends ConsumerWidget {
  const GymtrxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(settingsProvider.select((s) => s.accent));
    final onboarded = ref.watch(settingsProvider.select((s) => s.onboardingDone));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: gtOverlayStyle,
      child: MaterialApp(
        title: 'GYMTRX',
        debugShowCheckedModeBanner: false,
        navigatorKey: rootNavigatorKey,
        theme: buildGtTheme(accent.color),
        // A new accent tweens through the whole app instead of snapping.
        themeAnimationDuration: const Duration(milliseconds: 500),
        themeAnimationCurve: GtMotion.emphasized,
        scrollBehavior: const GtScrollBehavior(),
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: ToastHost(child: LockGate(child: child!)),
        ),
        // First launch asks which features to use; afterwards straight to the app.
        home: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: GtMotion.emphasized,
          child: onboarded ? const AppShell() : const OnboardingScreen(),
        ),
      ),
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
