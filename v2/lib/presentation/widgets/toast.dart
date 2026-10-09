import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'pressable.dart';

@immutable
class ToastData {
  const ToastData(this.id, this.message, this.actionLabel, this.onAction);

  final int id;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
}

/// One toast at a time, floating above the nav bar. Used for "Logged · Undo"
/// and "Deleted · Undo": undo replaces confirmation dialogs.
abstract final class Toasts {
  static final ValueNotifier<ToastData?> current = ValueNotifier(null);
  static Timer? _timer;
  static int _seq = 0;

  static void show(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _timer?.cancel();
    current.value = ToastData(++_seq, message, actionLabel, onAction);
    _timer = Timer(duration, hide);
  }

  static void hide() {
    _timer?.cancel();
    current.value = null;
  }
}

/// Hosts toasts above everything (sheets included). Lives in MaterialApp.builder.
class ToastHost extends StatelessWidget {
  const ToastHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottom = (mq.viewInsets.bottom > 0 ? mq.viewInsets.bottom : mq.viewPadding.bottom) + 96;
    // Sits above the Navigator, so it brings its own Material for text styling.
    return Stack(
      children: [
        child,
        Positioned(
          left: GtSpace.lg,
          right: GtSpace.lg,
          bottom: bottom,
          child: Material(
            type: MaterialType.transparency,
            child: ValueListenableBuilder<ToastData?>(
              valueListenable: Toasts.current,
              builder: (context, data, _) => AnimatedSwitcher(
                duration: GtMotion.of(context, const Duration(milliseconds: 360)),
                reverseDuration: GtMotion.of(context, GtMotion.medium),
                switchInCurve: GtMotion.emphasized,
                switchOutCurve: GtMotion.accelerate,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.35), end: Offset.zero).animate(animation),
                    child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(animation), child: child),
                  ),
                ),
                child: data == null ? const SizedBox.shrink() : _ToastPill(key: ValueKey(data.id), data: data),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToastPill extends StatelessWidget {
  const _ToastPill({super.key, required this.data});

  final ToastData data;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Pressable(
        onTap: Toasts.hide,
        haptic: PressHaptic.none,
        scale: 0.98,
        child: Container(
          padding: const EdgeInsets.fromLTRB(GtSpace.xl, 6, 6, 6),
          decoration: ShapeDecoration(color: c.ink, shape: const StadiumBorder(), shadows: c.floatShadow),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(data.message, style: GtText.label.sized(14).colored(c.onInk), maxLines: 2),
                ),
              ),
              if (data.actionLabel != null) ...[
                const SizedBox(width: GtSpace.md),
                Pressable(
                  onTap: () {
                    Toasts.hide();
                    data.onAction?.call();
                  },
                  scale: 0.92,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(color: c.onInk.withValues(alpha: 0.1), shape: const StadiumBorder()),
                    child: Text(data.actionLabel!, style: GtText.label.sized(14).weight(600).colored(c.accentOnInk)),
                  ),
                ),
              ] else
                const SizedBox(width: GtSpace.md),
            ],
          ),
        ),
      ),
    );
  }
}
