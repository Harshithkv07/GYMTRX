import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'pressable.dart';

/// A plain title that introduces a section ("Recent sessions"), with an
/// optional trailing action or label.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.padding});

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.x3, GtSpace.gutter, GtSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(title, style: GtText.titleSmall.sized(16))),
          ?trailing,
        ],
      ),
    );
  }
}

/// A small text action for section headers ("See all").
class LinkAction extends StatelessWidget {
  const LinkAction(this.label, {super.key, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: PressHaptic.selection,
      scale: 0.94,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Text(label, style: GtText.label.weight(600).colored(context.c.text2)),
      ),
    );
  }
}

/// Segmented control: a white thumb sliding on a soft track.
class GtSegmented<T> extends StatelessWidget {
  const GtSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.height = 38,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const inset = 3.0;
    return Container(
      height: height,
      padding: const EdgeInsets.all(inset),
      decoration: ShapeDecoration(color: c.surface3.withValues(alpha: c.isDark ? 1 : 0.7), shape: const StadiumBorder()),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth / values.length;
          final index = values.indexOf(selected);
          return Stack(
            children: [
              AnimatedPositioned(
                duration: GtMotion.of(context, GtMotion.medium),
                curve: GtMotion.emphasized,
                left: index * w,
                top: 0,
                bottom: 0,
                width: w,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: c.isDark ? c.surface2 : c.surface,
                    shape: const StadiumBorder(),
                    shadows: c.isDark
                        ? null
                        : [BoxShadow(color: c.shadow.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final v in values)
                    Expanded(
                      child: Pressable(
                        onTap: v == selected ? null : () => onChanged(v),
                        haptic: PressHaptic.selection,
                        scale: 0.95,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: GtMotion.fast,
                            style: GtText.label.weight(v == selected ? 600 : 500).colored(v == selected ? c.text1 : c.text2),
                            child: Text(labelOf(v), maxLines: 1),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Underlined text tabs, as above the stat cards in the reference.
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({super.key, required this.labels, required this.index, required this.onChanged});

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Positioned(left: 0, right: 0, bottom: 0, child: Container(height: 1, color: c.hairline)),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Pressable(
                    onTap: i == index ? null : () => onChanged(i),
                    haptic: PressHaptic.selection,
                    scale: 0.96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: GtMotion.fast,
                          style: GtText.label.sized(14).weight(i == index ? 600 : 500).colored(i == index ? c.text1 : c.text3),
                          child: Text(labels[i]),
                        ),
                        Positioned(
                          bottom: 0,
                          child: AnimatedContainer(
                            duration: GtMotion.of(context, GtMotion.medium),
                            curve: GtMotion.emphasized,
                            height: 2,
                            width: i == index ? 44 : 0,
                            decoration: ShapeDecoration(color: c.text1, shape: const StadiumBorder()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Switch: an ink track with an accent knob when on.
class GtSwitch extends StatelessWidget {
  const GtSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final duration = GtMotion.of(context, GtMotion.medium);
    return Pressable(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      haptic: PressHaptic.selection,
      scale: 0.94,
      child: AnimatedContainer(
        duration: duration,
        curve: GtMotion.emphasized,
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: ShapeDecoration(color: value ? c.ink : c.surface3, shape: const StadiumBorder()),
        child: AnimatedAlign(
          duration: duration,
          curve: GtMotion.emphasized,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: duration,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? c.accent : (c.isDark ? c.text3 : Colors.white),
              boxShadow: value || c.isDark
                  ? null
                  : [BoxShadow(color: c.shadow.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

/// Grab handle at the top of sheets.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 5,
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        decoration: ShapeDecoration(color: context.c.text3.withValues(alpha: 0.4), shape: const StadiumBorder()),
      ),
    );
  }
}

/// A rounded square that frames the dot body in lists, like the thumbnails
/// in the reference.
class ArtTile extends StatelessWidget {
  const ArtTile({super.key, required this.child, this.size = 64, this.color});

  final Widget child;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        gradient: color != null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: c.isDark ? [c.surface2, c.surface3] : [c.mistA, c.mistB],
              ),
        color: color,
        shape: squircle(size * 0.28),
      ),
      child: child,
    );
  }
}
