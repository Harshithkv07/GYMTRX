import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/config.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../widgets/brand_mark.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';

/// The first thing a new install shows: a welcome and three short slides on
/// what GYMTRX is, before the setup steps. Swipe, tap Next, or Skip.
class IntroCarousel extends StatefulWidget {
  const IntroCarousel({
    super.key,
    this.initialPage = 0,
    required this.onPageChanged,
    required this.onStart,
    this.onRestore,
  });

  static const count = 4;

  final int initialPage;
  final ValueChanged<int> onPageChanged;

  /// Leaves the slides for the setup steps.
  final VoidCallback onStart;

  /// Restores a Drive backup instead; null hides the button.
  final VoidCallback? onRestore;

  @override
  State<IntroCarousel> createState() => _IntroCarouselState();
}

class _IntroCarouselState extends State<IntroCarousel> {
  late final _pages = PageController(initialPage: widget.initialPage);
  late var _page = widget.initialPage;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  bool get _last => _page == IntroCarousel.count - 1;

  void _next() {
    if (_last) {
      widget.onStart();
    } else if (GtMotion.reduced(context)) {
      _pages.jumpToPage(_page + 1);
    } else {
      _pages.animateToPage(_page + 1, duration: GtMotion.slow, curve: GtMotion.emphasized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final duration = GtMotion.of(context, GtMotion.medium);
    final slides = [
      _WelcomeSlide(active: _page == 0),
      _Slide(
        active: _page == 1,
        art: _LogArt(active: _page == 1),
        title: 'Log in seconds',
        body: 'Tap ＋ right after the gym and pick what you trained. Exercises, sets and notes can wait.',
      ),
      _Slide(
        active: _page == 2,
        art: _MonthArt(active: _page == 2),
        title: 'See it add up',
        body: 'Every session lands on the calendar. Streaks, goals and records too, if you want them.',
      ),
      _Slide(
        active: _page == 3,
        art: _PhoneArt(active: _page == 3),
        title: 'Yours, on this phone',
        body:
            'No account and no server. Your log stays on this phone. '
            '${driveConfigured ? 'Back it up to your own Google Drive if you like.' : 'Export a backup any time from Settings.'}',
      ),
    ];

    return Stack(
      children: [
        // A soft accent glow behind everything.
        Positioned(
          top: -120,
          left: -80,
          right: -80,
          height: 420,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [context.gt.accentGlow, context.gt.accentGlow.withValues(alpha: 0)]),
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const Spacer(),
                  AnimatedOpacity(
                    duration: duration,
                    opacity: _last ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: _last,
                      child: GtButton(label: 'Skip', kind: GtButtonKind.ghost, height: 40, onTap: widget.onStart),
                    ),
                  ),
                  const SizedBox(width: GtSpace.sm),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (p) {
                  Haptics.selection();
                  setState(() => _page = p);
                  widget.onPageChanged(p);
                },
                children: slides,
              ),
            ),
            _PageDots(count: IntroCarousel.count, index: _page),
            const SizedBox(height: GtSpace.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter),
              child: Column(
                children: [
                  GtButton(
                    label: _last ? 'Get started' : 'Next',
                    expand: true,
                    haptic: _last ? PressHaptic.medium : PressHaptic.light,
                    onTap: _next,
                  ),
                  AnimatedSize(
                    duration: duration,
                    curve: GtMotion.emphasized,
                    child: _page == 0 && widget.onRestore != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: GtSpace.sm),
                            child: GtButton(
                              label: 'Restore from Google Drive',
                              icon: GtIcons.cloud,
                              kind: GtButtonKind.ghost,
                              expand: true,
                              onTap: widget.onRestore,
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
            SizedBox(height: padding.bottom + GtSpace.lg),
          ],
        ),
      ],
    );
  }
}

/// Fades and lifts [child] in, [order] steps after the slide becomes current.
Widget _rise(BuildContext context, {required bool active, required int order, required Widget child}) {
  if (GtMotion.reduced(context)) return child;
  final delay = (90 * order).ms;
  return child
      .animate(target: active ? 1 : 0)
      .fadeIn(duration: 500.ms, delay: delay)
      .moveY(begin: 14, end: 0, duration: 600.ms, delay: delay, curve: GtMotion.emphasized);
}

/// Pops [child] in with a little overshoot.
Widget _pop(BuildContext context, {required bool active, required int order, required Widget child}) {
  if (GtMotion.reduced(context)) return child;
  final delay = (200 + 80 * order).ms;
  return child
      .animate(target: active ? 1 : 0)
      .fadeIn(duration: 300.ms, delay: delay)
      .scaleXY(begin: 0.6, end: 1, duration: 500.ms, delay: delay, curve: Curves.easeOutBack);
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    Widget rise(Widget w, int i) => _rise(context, active: active, order: i, child: w);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.xxl, GtSpace.gutter, GtSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rise(const BrandMark(size: 72), 0),
          const SizedBox(height: GtSpace.x3),
          rise(Text('GYMTRX', style: GtText.display), 1),
          const SizedBox(height: GtSpace.md),
          rise(Text('A gym log that stays out of your way.', style: GtText.title.colored(GtColors.text2)), 2),
          const SizedBox(height: GtSpace.xxl),
          rise(
            Text(
              'Log a session in a few taps right after the gym, and add the details later. '
              'Everything else is optional: you pick what you want next, and can change it any time.',
              style: GtText.body.colored(GtColors.text2),
            ),
            3,
          ),
        ],
      ),
    );
  }
}

/// An illustration above a title and a line of text.
class _Slide extends StatelessWidget {
  const _Slide({required this.active, required this.art, required this.title, required this.body});

  final bool active;
  final Widget art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GtSpace.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: FittedBox(fit: BoxFit.scaleDown, child: art),
            ),
          ),
          const SizedBox(height: GtSpace.xxl),
          _rise(
            context,
            active: active,
            order: 1,
            child: Text(title, style: GtText.headline),
          ),
          const SizedBox(height: GtSpace.md),
          _rise(
            context,
            active: active,
            order: 2,
            child: Text(body, style: GtText.body.colored(GtColors.text2)),
          ),
          const SizedBox(height: GtSpace.x3),
        ],
      ),
    );
  }
}

/// Muscle chips being picked, above the ＋ button.
class _LogArt extends StatelessWidget {
  const _LogArt({required this.active});

  final bool active;

  static const _chips = [('Chest', true), ('Triceps', true), ('Back', false), ('Legs', false)];

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 260,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: GtSpace.sm,
            runSpacing: GtSpace.sm,
            children: [
              for (var i = 0; i < _chips.length; i++)
                _pop(
                  context,
                  active: active,
                  order: i,
                  child: _Chip(label: _chips[i].$1, selected: _chips[i].$2),
                ),
            ],
          ),
        ),
        const SizedBox(height: GtSpace.x3),
        _pop(
          context,
          active: active,
          order: _chips.length,
          child: Container(
            width: 72,
            height: 72,
            decoration: ShapeDecoration(
              color: accent,
              shape: squircle(36),
              shadows: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 28, offset: const Offset(0, 8))],
            ),
            child: const Icon(GtIcons.add, size: 30, color: GtColors.onAccent),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
      decoration: ShapeDecoration(
        color: selected ? context.accent : GtColors.s2,
        shape: squircle(19, side: selected ? BorderSide.none : const BorderSide(color: GtColors.hairlineStrong)),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: GtText.label.sized(14).weight(600).colored(selected ? GtColors.onAccent : GtColors.text1),
        ),
      ),
    );
  }
}

/// A month of days filling in, with a streak and a record underneath.
class _MonthArt extends StatelessWidget {
  const _MonthArt({required this.active});

  final bool active;

  static const _logged = {1, 3, 5, 8, 10, 12, 15, 17, 22, 24, 26, 29};
  static const _record = 19;

  /// Days fill in one after another, in calendar order.
  static final _fillOrder = [..._logged, _record]..sort();

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    const cell = 26.0;
    const gap = 8.0;
    return GtCard(
      padding: const EdgeInsets.all(GtSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var row = 0; row < 5; row++)
            Padding(
              padding: EdgeInsets.only(top: row == 0 ? 0 : gap),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var col = 0; col < 7; col++)
                    Padding(
                      padding: EdgeInsets.only(left: col == 0 ? 0 : gap),
                      child: _day(context, row * 7 + col, accent, cell),
                    ),
                ],
              ),
            ),
          const SizedBox(height: GtSpace.lg),
          _rise(
            context,
            active: active,
            order: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(GtIcons.flame, size: 16, color: GtColors.flame),
                const SizedBox(width: GtSpace.xs),
                Text('4-week streak', style: GtText.caption.colored(GtColors.text1)),
                const SizedBox(width: GtSpace.lg),
                const Icon(GtIcons.trophy, size: 16, color: GtColors.gold),
                const SizedBox(width: GtSpace.xs),
                Text('New record', style: GtText.caption.colored(GtColors.text1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _day(BuildContext context, int i, Color accent, double size) {
    final logged = _logged.contains(i);
    final record = i == _record;
    final base = Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(color: GtColors.s3, shape: squircle(size * 0.32)),
    );
    if (!logged && !record) return base;
    final fill = Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(color: record ? GtColors.gold : accent, shape: squircle(size * 0.32)),
    );
    return Stack(
      children: [
        base,
        _pop(context, active: active, order: _fillOrder.indexOf(i) ~/ 2, child: fill),
      ],
    );
  }
}

/// A phone holding the log, with a lock, and Drive off to the side when it's
/// set up.
class _PhoneArt extends StatelessWidget {
  const _PhoneArt({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    return SizedBox(
      width: 220,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 128,
            height: 216,
            padding: const EdgeInsets.all(GtSpace.lg),
            decoration: ShapeDecoration(
              color: GtColors.s1,
              shape: squircle(28, side: const BorderSide(color: GtColors.hairlineStrong, width: 1.5)),
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: ShapeDecoration(color: GtColors.s3, shape: squircle(2)),
                ),
                const Spacer(),
                const BrandMark(size: 44),
                const SizedBox(height: GtSpace.md),
                for (final w in [72.0, 56.0, 64.0])
                  Padding(
                    padding: const EdgeInsets.only(top: GtSpace.sm),
                    child: Container(
                      width: w,
                      height: 6,
                      decoration: ShapeDecoration(color: GtColors.s3, shape: squircle(3)),
                    ),
                  ),
                // Room at the bottom for the lock that sits on the edge.
                const Spacer(flex: 2),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: _pop(
              context,
              active: active,
              order: 0,
              child: Container(
                width: 52,
                height: 52,
                decoration: ShapeDecoration(
                  color: accent,
                  shape: squircle(18),
                  shadows: [
                    BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(GtIcons.lock, size: 24, color: GtColors.onAccent),
              ),
            ),
          ),
          if (driveConfigured)
            Positioned(
              top: 12,
              right: 0,
              child: _pop(
                context,
                active: active,
                order: 2,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: GtColors.s2,
                    shape: squircle(16, side: const BorderSide(color: GtColors.hairlineStrong)),
                  ),
                  child: Icon(GtIcons.cloud, size: 22, color: accent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Which slide is showing, as a row of dots; the current one is a pill.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final duration = GtMotion.of(context, GtMotion.medium);
    return Semantics(
      label: 'Slide ${index + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: duration,
              curve: GtMotion.emphasized,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == index ? 20 : 6,
              height: 6,
              decoration: ShapeDecoration(
                color: i == index ? context.accent : GtColors.s3,
                shape: const StadiumBorder(),
              ),
            ),
        ],
      ),
    );
  }
}
