import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../log/day_picker_sheet.dart';
import '../log/log_actions.dart';
import '../log/weigh_in_sheet.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';

/// Long-press on ＋: a small popover growing out of the button.
Future<void> showPlusMenu(BuildContext context, WidgetRef ref, Rect anchor) async {
  final action = await Navigator.of(context, rootNavigator: true).push<_PlusAction>(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: GtMotion.of(context, const Duration(milliseconds: 320)),
      reverseTransitionDuration: GtMotion.of(context, GtMotion.medium),
      pageBuilder: (context, animation, _) => _PlusMenu(anchor: anchor),
      transitionsBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: GtMotion.emphasized,
          reverseCurve: GtMotion.accelerate,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.0).animate(curved),
            alignment: Alignment.bottomRight,
            child: child,
          ),
        );
      },
    ),
  );
  if (!context.mounted || action == null) return;
  switch (action) {
    case _PlusAction.otherDay:
      final day = await pickDay(context, ref, selected: logicalToday(ref), title: 'Log which day?');
      if (day != null && context.mounted) await openLogSheet(context, ref, dayKey: day);
    case _PlusAction.weighIn:
      await showWeighInSheet(context, ref, dayKey: logicalToday(ref));
  }
}

enum _PlusAction { otherDay, weighIn }

class _PlusMenu extends StatelessWidget {
  const _PlusMenu({required this.anchor});

  final Rect anchor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned(
            right: size.width - anchor.right,
            bottom: size.height - anchor.top + GtSpace.md,
            width: 230,
            child: Glass(
              radius: GtRadius.lg,
              shadow: true,
              tint: context.c.isDark ? context.c.surface2.withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.9),
              child: Padding(
                padding: const EdgeInsets.all(GtSpace.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MenuItem(
                      icon: GtIcons.calendarPlus,
                      label: 'Log another day',
                      onTap: () => Navigator.pop(context, _PlusAction.otherDay),
                    ),
                    _MenuItem(
                      icon: GtIcons.weight,
                      label: 'Add weigh-in',
                      onTap: () => Navigator.pop(context, _PlusAction.weighIn),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.c.text1),
            const SizedBox(width: GtSpace.md),
            Text(label, style: GtText.body.weight(500)),
          ],
        ),
      ),
    );
  }
}
