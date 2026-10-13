import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../widgets/gt_button.dart';
import '../widgets/surface.dart';
import 'tour_target.dart';

/// One stop on the home tour.
typedef TourStep = ({TourSpot spot, String title, String body});

/// The stops, in order. [extraTabs] are the labels of the tabs besides the
/// calendar that this person has turned on; without any, the tab bar is
/// skipped.
List<TourStep> homeTourSteps({required List<String> extraTabs}) => [
  (
    spot: TourSpot.add,
    title: 'Log a session',
    body: 'Tap ＋ after the gym and pick what you trained. Hold it for more ways to log.',
  ),
  (
    spot: TourSpot.calendar,
    title: 'Your month',
    body: 'Every session lands here. Tap a day to see it or add exercises, sets and a note. Swipe for other months.',
  ),
  if (extraTabs.isNotEmpty)
    (
      spot: TourSpot.tabs,
      title: extraTabs.join(' and '),
      body: extraTabs.length == 1
          ? '${extraTabs.single} lives down here, next to the calendar.'
          : 'They live down here, next to the calendar.',
    ),
  (
    spot: TourSpot.settings,
    title: 'Settings',
    body: 'Features, accent colours, reminders and backups. Replay this tour from here any time.',
  ),
];

/// Walks through the home screen with a spotlight on each part. Returns once
/// it's finished or skipped.
Future<void> showHomeTour(BuildContext context, {required List<String> extraTabs}) async {
  final steps = [
    for (final s in homeTourSteps(extraTabs: extraTabs))
      if (tourRectOf(s.spot) != null) s,
  ];
  if (steps.isEmpty) return;
  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: GtMotion.of(context, GtMotion.slow),
      reverseTransitionDuration: GtMotion.of(context, GtMotion.medium),
      pageBuilder: (_, _, _) => HomeTour(steps: steps),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}

class HomeTour extends StatefulWidget {
  const HomeTour({super.key, required this.steps});

  final List<TourStep> steps;

  @override
  State<HomeTour> createState() => _HomeTourState();
}

class _HomeTourState extends State<HomeTour> with SingleTickerProviderStateMixin {
  late final _move = AnimationController(vsync: this);
  var _index = 0;

  /// The spotlight animates from [_from] to [_to].
  _Hole? _from;
  late _Hole _to = _holeFor(widget.steps.first, fallback: Rect.zero);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _move.duration = GtMotion.of(context, GtMotion.slow);
    // The first spotlight closes in from the whole screen.
    if (_from == null) {
      final screen = Offset.zero & MediaQuery.sizeOf(context);
      _from = (rect: screen.inflate(screen.shortestSide / 2), radius: GtRadius.xl);
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  /// The spotlight for [step]; [fallback] if its target has gone.
  _Hole _holeFor(TourStep step, {required Rect fallback}) {
    // The calendar is nearly full width, so its ring hugs it to stay on screen.
    final rect = tourRectOf(step.spot)?.inflate(step.spot == TourSpot.calendar ? 2 : 8) ?? fallback;
    // Pills and round buttons stay round; the calendar gets a card's corners.
    final radius = step.spot == TourSpot.calendar ? GtRadius.xl : rect.shortestSide / 2;
    return (rect: rect, radius: radius);
  }

  _Hole get _current {
    final t = GtMotion.emphasized.transform(_move.value);
    return (rect: Rect.lerp(_from!.rect, _to.rect, t)!, radius: _lerp(_from!.radius, _to.radius, t));
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  void _next() {
    if (_index == widget.steps.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    Haptics.selection();
    setState(() {
      _from = _current;
      _index++;
      _to = _holeFor(widget.steps[_index], fallback: _to.rect);
    });
    _move.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final step = widget.steps[_index];
    final last = _index == widget.steps.length - 1;
    // The card sits on whichever side of the spotlight has more room.
    final below = _to.rect.center.dy < size.height / 2;

    final card = GtCard(
      color: GtColors.s2,
      padding: const EdgeInsets.fromLTRB(GtSpace.xl, GtSpace.lg, GtSpace.lg, GtSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_index + 1} of ${widget.steps.length}', style: GtText.overline.colored(context.accent)),
          const SizedBox(height: GtSpace.sm),
          Text(step.title, style: GtText.title),
          const SizedBox(height: GtSpace.xs + 2),
          Text(step.body, style: GtText.body.colored(GtColors.text2)),
          const SizedBox(height: GtSpace.lg),
          Row(
            children: [
              if (!last)
                GtButton(label: 'Skip', kind: GtButtonKind.ghost, height: 44, onTap: () => Navigator.of(context).pop()),
              const Spacer(),
              GtButton(label: last ? 'Done' : 'Next', height: 44, onTap: _next),
            ],
          ),
        ],
      ),
    );

    return BlockSemantics(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _next,
                child: AnimatedBuilder(
                  animation: _move,
                  builder: (context, _) {
                    final hole = _current;
                    return CustomPaint(
                      painter: _ScrimPainter(hole: hole.rect, radius: hole.radius, ring: context.accent),
                    );
                  },
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: GtMotion.of(context, GtMotion.slow),
              switchInCurve: GtMotion.emphasized,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: Offset(0, below ? -0.04 : 0.04), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: SizedBox.expand(
                key: ValueKey(_index),
                child: Stack(
                  children: [
                    Positioned(
                      left: GtSpace.gutter,
                      right: GtSpace.gutter,
                      top: below ? math.min(_to.rect.bottom + GtSpace.lg, size.height - 240) : null,
                      bottom: below ? null : math.max(size.height - _to.rect.top + GtSpace.lg, GtSpace.lg),
                      child: Semantics(liveRegion: true, child: card),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _Hole = ({Rect rect, double radius});

/// Dims everything except a squircle around the current spot.
class _ScrimPainter extends CustomPainter {
  const _ScrimPainter({required this.hole, required this.radius, required this.ring});

  final Rect hole;
  final double radius;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final cut = squircle(radius).getOuterPath(hole);
    final scrim = Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), cut);
    canvas.drawPath(scrim, Paint()..color = Colors.black.withValues(alpha: 0.72));
    canvas.drawPath(
      cut,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = ring.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter old) => old.hole != hole || old.radius != radius || old.ring != ring;
}
