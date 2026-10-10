import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';

/// Floating frosted pill with the three tabs, plus a detached accent ＋
/// button. The active tab widens to show its label; the others are icons.
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
                    // Inactive tabs take one unit, the active one two.
                    final w = c.maxWidth / (_tabs.length + 1);
                    return Stack(
                      children: [
                        AnimatedPositioned(
                          duration: GtMotion.of(context, const Duration(milliseconds: 360)),
                          curve: GtMotion.emphasized,
                          left: index * w,
                          top: 0,
                          bottom: 0,
                          width: w * 2,
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
                              for (var i = 0; i < _tabs.length; i++)
                                _NavItem(
                                  label: _tabs[i].label,
                                  icon: _tabs[i].icon,
                                  activeIcon: _tabs[i].activeIcon,
                                  active: index == i,
                                  width: index == i ? w * 2 : w,
                                  onTap: () => onChanged(i),
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

const _tabs = [
  (label: 'Calendar', icon: GtIcons.calendar, activeIcon: GtIcons.calendarActive),
  (label: 'Progress', icon: GtIcons.progress, activeIcon: GtIcons.progressActive),
  (label: 'Insights', icon: GtIcons.insights, activeIcon: GtIcons.insightsActive),
];

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.width,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? GtColors.text1 : GtColors.text2;
    final duration = GtMotion.of(context, const Duration(milliseconds: 360));
    return AnimatedContainer(
      duration: duration,
      curve: GtMotion.emphasized,
      width: width,
      child: Pressable(
        onTap: active ? null : onTap,
        haptic: PressHaptic.selection,
        scale: 0.94,
        semanticLabel: label,
        child: ClipRect(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: GtMotion.fast,
                child: Icon(active ? activeIcon : icon, key: ValueKey(active), size: 20, color: color),
              ),
              // Large system text shrinks the label to fit rather than overflowing the pill.
              Flexible(
                child: AnimatedSize(
                  duration: duration,
                  curve: GtMotion.emphasized,
                  child: active
                      ? Padding(
                          padding: const EdgeInsets.only(left: GtSpace.sm),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label,
                              maxLines: 1,
                              style: GtText.label.sized(14).weight(600).colored(color),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
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
