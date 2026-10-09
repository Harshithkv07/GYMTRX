import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';

/// Floating frosted pill with the two tabs, plus a detached accent ＋ button.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.onAdd,
    required this.onAddLongPress,
  });

  static const height = 64.0;

  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;
  final void Function(Rect anchor) onAddLongPress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Glass(
            radius: height / 2,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth / 2;
                    return Stack(
                      children: [
                        AnimatedPositioned(
                          duration: GtMotion.of(context, const Duration(milliseconds: 360)),
                          curve: GtMotion.emphasized,
                          left: index * w,
                          top: 0,
                          bottom: 0,
                          width: w,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: squircle((height - 12) / 2),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            children: [
                              _NavItem(
                                label: 'Calendar',
                                icon: GtIcons.calendar,
                                activeIcon: GtIcons.calendarActive,
                                active: index == 0,
                                onTap: () => onChanged(0),
                              ),
                              _NavItem(
                                label: 'Insights',
                                icon: GtIcons.insights,
                                activeIcon: GtIcons.insightsActive,
                                active: index == 1,
                                onTap: () => onChanged(1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: GtSpace.md),
        _AddButton(onTap: onAdd, onLongPress: onAddLongPress),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? GtColors.text1 : GtColors.text2;
    return Expanded(
      child: Pressable(
        onTap: active ? null : onTap,
        haptic: PressHaptic.selection,
        scale: 0.94,
        semanticLabel: label,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: GtMotion.fast,
              child: Icon(active ? activeIcon : icon, key: ValueKey(active), size: 20, color: color),
            ),
            const SizedBox(width: GtSpace.sm),
            // Large system text shrinks the label to fit rather than overflowing the pill.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: GtMotion.fast,
                  style: GtText.label.sized(14).weight(active ? 600 : 500).colored(color),
                  child: Text(label, maxLines: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap, required this.onLongPress});

  final VoidCallback onTap;
  final void Function(Rect anchor) onLongPress;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    return Pressable(
      onTap: onTap,
      onLongPress: () {
        final box = context.findRenderObject()! as RenderBox;
        onLongPress(box.localToGlobal(Offset.zero) & box.size);
      },
      haptic: PressHaptic.medium,
      scale: 0.9,
      semanticLabel: 'Log a session',
      child: Container(
        width: GlassNavBar.height,
        height: GlassNavBar.height,
        decoration: ShapeDecoration(
          color: accent,
          shape: squircle(GlassNavBar.height / 2),
          shadows: [BoxShadow(color: accent.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 6))],
        ),
        child: const Icon(GtIcons.add, size: 26, color: GtColors.onAccent),
      ),
    );
  }
}
