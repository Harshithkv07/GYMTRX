import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../../logic/providers/settings_provider.dart';
import '../art/dot_text.dart';
import '../art/hero_art.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import 'name_sheet.dart';

/// First launch: the illustrated cover, then one question (a name).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final name = await showNameSheet(context, title: 'What should we call you?', skippable: true);
    if (name == null) return; // dismissed: stay on the cover
    final settings = ref.read(settingsProvider.notifier);
    if (name.isNotEmpty) settings.setUserName(name);
    Haptics.medium();
    settings.markWelcomeSeen();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final padding = MediaQuery.paddingOf(context);
    final reduced = GtMotion.reduced(context);
    Widget rise(Widget child, int ms) => reduced
        ? child
        : child
              .animate()
              .fadeIn(duration: 600.ms, delay: ms.ms)
              .moveY(begin: 14, end: 0, duration: 700.ms, delay: ms.ms, curve: GtMotion.emphasized);

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const HeroArt(asset: GtArt.welcome, fadeFrom: 0.5, fadeTo: 0.78, drift: true, streaks: true),
          // Tiny technical labels at the edges, as on the reference cover.
          Positioned(
            top: padding.top + 14,
            left: GtSpace.gutter,
            child: rise(_Hud(lines: const ['GYMTRX', 'LOGBOOK · 02'], color: c.text2), 200),
          ),
          Positioned(
            top: padding.top + 120,
            right: 14,
            child: rise(_Hud(lines: const ['DAYS', 'GROUPS', 'SETS', 'NOTES'], color: c.text2, align: TextAlign.end), 300),
          ),
          Positioned(
            top: padding.top + 260,
            left: 14,
            child: rise(_Hud(lines: const ['LOCAL', 'OFFLINE', 'PRIVATE'], color: c.text2), 400),
          ),
          Positioned(
            left: GtSpace.gutter + 4,
            right: GtSpace.gutter + 4,
            bottom: padding.bottom + GtSpace.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DotText(
                  'JUST\nTHE LOG',
                  style: GtText.dot(58, weight: 400, height: 1.04).colored(c.text1),
                  delay: const Duration(milliseconds: 350),
                  duration: const Duration(milliseconds: 1100),
                ),
                const SizedBox(height: GtSpace.lg),
                rise(
                  Text(
                    'A quiet logbook for the days you train and what you did. No streaks, no goals, no reminders.',
                    style: GtText.body.colored(c.text2),
                  ),
                  700,
                ),
                const SizedBox(height: GtSpace.xxl),
                rise(
                  GtButton(
                    label: 'Get started',
                    expand: true,
                    haptic: PressHaptic.light,
                    onTap: () => _start(context, ref),
                  ),
                  850,
                ),
                const SizedBox(height: GtSpace.md),
                rise(
                  Center(
                    child: Text('Everything stays on this phone.', style: GtText.caption.colored(c.text3)),
                  ),
                  950,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.lines, required this.color, this.align = TextAlign.start});

  final List<String> lines;
  final Color color;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: align == TextAlign.end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(width: 14, height: 1, color: color.withValues(alpha: 0.6)),
          const SizedBox(height: 4),
          Text(lines.join('\n'), textAlign: align, style: GtText.micro.colored(color.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}
