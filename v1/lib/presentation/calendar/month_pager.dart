import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/haptics.dart';
import 'month_grid.dart';

/// Horizontally swipeable months ending at [current] (no future months).
/// The height follows the finger between 5- and 6-row months, so content
/// below never jumps.
class MonthPager extends StatefulWidget {
  const MonthPager({
    super.key,
    required this.current,
    required this.initial,
    required this.weekStart,
    required this.onChanged,
    required this.builder,
  });

  /// The latest month that can be shown (this month).
  final YearMonth current;
  final YearMonth initial;
  final int weekStart;
  final ValueChanged<YearMonth> onChanged;
  final Widget Function(BuildContext context, YearMonth month) builder;

  @override
  State<MonthPager> createState() => MonthPagerState();
}

class MonthPagerState extends State<MonthPager> {
  // Index of [widget.current]; earlier months count down from here.
  static const _origin = 1200;
  late final PageController _controller = PageController(
    initialPage: _origin + widget.initial.monthsSince(widget.current),
  );

  YearMonth _monthAt(int index) => widget.current.shift(index - _origin);

  /// Animates to [month] (e.g. tapping the title jumps back to this month).
  void animateTo(YearMonth month) {
    final target = _origin + month.monthsSince(widget.current);
    if (GtMotion.reduced(context)) {
      _controller.jumpToPage(target);
    } else {
      _controller.animateToPage(target, duration: const Duration(milliseconds: 520), curve: GtMotion.emphasized);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double heightAt(int index) => MonthLayout.height(_monthAt(index), widget.weekStart, width);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final page = _controller.hasClients && _controller.position.haveDimensions
                ? _controller.page!
                : _controller.initialPage.toDouble();
            final lower = page.floor();
            final t = page - lower;
            final height = lerpDouble(heightAt(lower), heightAt(lower + 1), t)!;
            return SizedBox(height: height, child: child);
          },
          child: PageView.builder(
            controller: _controller,
            itemCount: _origin + 1,
            onPageChanged: (i) {
              Haptics.selection();
              widget.onChanged(_monthAt(i));
            },
            // Mid-swipe the box can be shorter than a 6-row month; let the
            // grid overflow and be clipped instead of squashing it.
            itemBuilder: (context, i) => ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: RepaintBoundary(child: widget.builder(context, _monthAt(i))),
              ),
            ),
          ),
        );
      },
    );
  }
}
