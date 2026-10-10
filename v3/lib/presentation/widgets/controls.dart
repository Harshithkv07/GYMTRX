import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'pressable.dart';

/// Small uppercase mono label that introduces a section.
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
        children: [
          Expanded(child: Text(title.toUpperCase(), style: GtText.overline)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Segmented control with a sliding indicator.
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
    const inset = 3.0;
    return Container(
      height: height,
      padding: const EdgeInsets.all(inset),
      decoration: ShapeDecoration(color: GtColors.s2, shape: squircle(height / 2)),
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
                  decoration: ShapeDecoration(color: GtColors.s3, shape: squircle((height - inset * 2) / 2)),
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
                            style: GtText.label.colored(v == selected ? GtColors.text1 : GtColors.text2),
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

/// Accent switch with a spring-eased thumb.
class GtSwitch extends StatelessWidget {
  const GtSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
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
        decoration: ShapeDecoration(color: value ? context.accent : GtColors.s3, shape: squircle(15)),
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
              color: value ? GtColors.onAccent : GtColors.text2,
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
        decoration: ShapeDecoration(color: GtColors.s3, shape: squircle(3)),
      ),
    );
  }
}
