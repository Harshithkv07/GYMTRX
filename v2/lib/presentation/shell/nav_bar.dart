import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/typography.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';

/// Floating frosted pill with the three tabs, plus a detached round ink ＋.
class GtNavBar extends StatelessWidget {
  const GtNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.onAdd,
    required this.onAddLongPress,
  });

  static const height = 66.0;

  static const _items = [
    ('Home', GtIcons.home, GtIcons.homeActive),
    ('Calendar', GtIcons.calendar, GtIcons.calendarActive),
    ('Insights', GtIcons.insights, GtIcons.insightsActive),
  ];

  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;
  final void Function(Rect anchor) onAddLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        Expanded(
          child: Glass(
            radius: height / 2,
            tint: c.isDark ? c.surface.withValues(alpha: 0.82) : Colors.white.withValues(alpha: 0.78),
            shadow: true,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final w = box.maxWidth / _items.length;
                    return Stack(
                      children: [
                        AnimatedPositioned(
                          duration: GtMotion.of(context, const Duration(milliseconds: 380)),
                          curve: GtMotion.emphasized,
                          left: index * w,
                          top: 0,
                          bottom: 0,
                          width: w,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              color: c.isDark ? c.surface3.withValues(alpha: 0.7) : c.bg,
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            children: [
                              for (var i = 0; i < _items.length; i++)
                                _NavItem(
                                  label: _items[i].$1,
                                  icon: _items[i].$2,
                                  activeIcon: _items[i].$3,
                                  active: index == i,
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
        const SizedBox(width: 10),
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
    final c = context.c;
    final color = active ? c.text1 : c.text3;
    return Expanded(
      child: Pressable(
        onTap: active ? null : onTap,
        haptic: PressHaptic.selection,
        scale: 0.92,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: GtMotion.fast,
              child: Icon(active ? activeIcon : icon, key: ValueKey(active), size: 21, color: color),
            ),
            const SizedBox(height: 3),
            // Large system text shrinks the label to fit rather than overflowing the pill.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: GtMotion.fast,
                style: GtText.caption.sized(11).weight(active ? 600 : 500).colored(color),
                child: Text(label, maxLines: 1),
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
    final c = context.c;
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
        width: GtNavBar.height,
        height: GtNavBar.height,
        decoration: ShapeDecoration(
          color: c.ink,
          shape: CircleBorder(side: c.isDark ? BorderSide(color: c.hairlineStrong) : BorderSide.none),
          shadows: [
            BoxShadow(color: c.ink.withValues(alpha: c.isDark ? 0.5 : 0.3), blurRadius: 22, offset: const Offset(0, 8)),
          ],
        ),
        child: Icon(GtIcons.add, size: 26, color: c.accentOnInk),
      ),
    );
  }
}
