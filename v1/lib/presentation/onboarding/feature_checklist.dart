import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../logic/features.dart';
import '../widgets/controls.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';
import 'feature_catalog.dart';

/// Every optional feature as a tickable row, grouped, with logging shown as
/// always on. Used by onboarding and Settings → Features.
class FeatureChecklist extends StatelessWidget {
  const FeatureChecklist({super.key, required this.selected, required this.onChanged});

  final Set<AppFeature> selected;
  final void Function(AppFeature feature, bool on) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Always on'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: GtSpace.lg),
          child: GtCard(
            padding: EdgeInsets.zero,
            child: _Row(
              icon: GtIcons.calendar,
              title: 'Logging',
              line: 'The calendar, logging a session in seconds, exercises and sets, notes and backups.',
              trailing: _Tag('ALWAYS ON'),
            ),
          ),
        ),
        for (final (title, items) in featureSections) ...[
          SectionHeader(title),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
            child: GtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(indent: 64, endIndent: GtSpace.lg),
                    _FeatureRow(
                      info: items[i],
                      on: selected.contains(items[i].feature),
                      onChanged: (v) => onChanged(items[i].feature, v),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.info, required this.on, required this.onChanged});

  final FeatureInfo info;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => onChanged(!on),
      haptic: PressHaptic.selection,
      scale: 0.98,
      semanticLabel: '${info.title}. ${info.line}${on ? ', on' : ', off'}',
      child: _Row(
        icon: info.icon,
        title: info.title,
        line: info.line,
        tag: info.online ? 'USES INTERNET' : null,
        active: on,
        trailing: _Check(on: on),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.line,
    required this.trailing,
    this.tag,
    this.active = true,
  });

  final IconData icon;
  final String title;
  final String line;
  final String? tag;
  final bool active;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final duration = GtMotion.of(context, GtMotion.medium);
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md + 2, GtSpace.lg, GtSpace.md + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: duration,
            curve: GtMotion.emphasized,
            width: 34,
            height: 34,
            decoration: ShapeDecoration(color: active ? context.gt.accentMuted : GtColors.s2, shape: squircle(11)),
            child: Icon(icon, size: 18, color: active ? context.accent : GtColors.text2),
          ),
          const SizedBox(width: GtSpace.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: GtSpace.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(title, style: GtText.body.weight(600)),
                    if (tag != null) _Tag(tag!, quiet: true),
                  ],
                ),
                const SizedBox(height: 3),
                Text(line, style: GtText.caption),
              ],
            ),
          ),
          const SizedBox(width: GtSpace.md),
          Padding(padding: const EdgeInsets.only(top: 4), child: trailing),
        ],
      ),
    );
  }
}

/// A round tick that fills with the accent when on.
class _Check extends StatelessWidget {
  const _Check({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final duration = GtMotion.of(context, GtMotion.medium);
    return AnimatedContainer(
      duration: duration,
      curve: GtMotion.emphasized,
      width: 26,
      height: 26,
      decoration: ShapeDecoration(
        color: on ? context.accent : Colors.transparent,
        shape: CircleBorder(side: BorderSide(color: on ? context.accent : GtColors.text3, width: 1.5)),
      ),
      child: AnimatedScale(
        duration: duration,
        curve: GtMotion.emphasized,
        scale: on ? 1 : 0.4,
        child: AnimatedOpacity(
          duration: duration,
          opacity: on ? 1 : 0,
          child: const Icon(GtIcons.check, size: 14, color: GtColors.onAccent),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.quiet = false});

  final String text;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: ShapeDecoration(color: quiet ? GtColors.s2 : context.gt.accentMuted, shape: squircle(6)),
      child: Text(text, style: GtText.overline.sized(9).colored(quiet ? GtColors.text2 : context.accent)),
    );
  }
}
