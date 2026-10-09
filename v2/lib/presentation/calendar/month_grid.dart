import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/entry.dart';
import '../widgets/pressable.dart';

/// Geometry shared by the grid and the pager (which animates between heights).
abstract final class MonthLayout {
  static const headerHeight = 30.0;

  static int leadingBlanks(YearMonth m, int weekStart) => (DayKeys.weekday(m.startKey) - weekStart + 7) % 7;

  static int rows(YearMonth m, int weekStart) =>
      ((leadingBlanks(m, weekStart) + DayKeys.daysInMonth(m.year, m.month)) / 7).ceil();

  static double rowHeight(double width) => (width / 7).clamp(36.0, 52.0);

  static double height(YearMonth m, int weekStart, double width) =>
      headerHeight + rows(m, weekStart) * rowHeight(width);

  /// ISO weekdays in display order.
  static List<int> weekdays(int weekStart) => [for (var i = 0; i < 7; i++) (weekStart - 1 + i) % 7 + 1];
}

/// One month of day cells. Pure: everything it shows comes in as arguments.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.weekStart,
    required this.today,
    required this.entries,
    required this.onDayTap,
    this.onDayPeek,
    this.onPeekEnd,
    this.selectedDay,
    this.highlightGroupId,
    this.semanticsFor,
  });

  final YearMonth month;
  final int weekStart;
  final int today;
  final Map<int, EntrySummary> entries;
  final ValueChanged<int> onDayTap;

  /// Long-press preview; receives the cell's global rect.
  final void Function(int dayKey, Rect cell)? onDayPeek;
  final VoidCallback? onPeekEnd;

  /// Picker mode: ring around the chosen day.
  final int? selectedDay;

  /// Filter: gym days without this group are shown muted.
  final int? highlightGroupId;
  final String Function(int dayKey)? semanticsFor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final rowH = MonthLayout.rowHeight(width);
        final blanks = MonthLayout.leadingBlanks(month, weekStart);
        final days = DayKeys.daysInMonth(month.year, month.month);
        final rows = MonthLayout.rows(month, weekStart);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MonthLayout.headerHeight,
              child: Row(
                children: [
                  for (final wd in MonthLayout.weekdays(weekStart))
                    Expanded(
                      child: Center(
                        child: Text(Fmt.weekdayInitial(wd), style: GtText.monoSmall.colored(context.c.text3)),
                      ),
                    ),
                ],
              ),
            ),
            for (var r = 0; r < rows; r++)
              SizedBox(
                height: rowH,
                child: Row(
                  children: [
                    for (var c = 0; c < 7; c++)
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final dayNum = r * 7 + c - blanks + 1;
                            if (dayNum < 1 || dayNum > days) return const SizedBox.shrink();
                            final key = month.startKey + dayNum - 1;
                            final entry = entries[key];
                            return DayCell(
                              key: ValueKey(key),
                              dayKey: key,
                              entry: entry,
                              isToday: key == today,
                              isFuture: key > today,
                              selected: key == selectedDay,
                              muted: highlightGroupId != null && entry != null && !entry.groupIds.contains(highlightGroupId),
                              size: rowH - 6,
                              semanticLabel: semanticsFor?.call(key),
                              onTap: key > today ? null : () => onDayTap(key),
                              onPeek: entry == null || onDayPeek == null ? null : (rect) => onDayPeek!(key, rect),
                              onPeekEnd: onPeekEnd,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A single day as a circle. Gym days are filled with the accent; the fill
/// pops in with a spring when a day is first logged.
class DayCell extends StatefulWidget {
  const DayCell({
    super.key,
    required this.dayKey,
    required this.entry,
    required this.isToday,
    required this.isFuture,
    required this.size,
    this.selected = false,
    this.muted = false,
    this.onTap,
    this.onPeek,
    this.onPeekEnd,
    this.semanticLabel,
  });

  final int dayKey;
  final EntrySummary? entry;
  final bool isToday;
  final bool isFuture;
  final bool selected;
  final bool muted;
  final double size;
  final VoidCallback? onTap;
  final void Function(Rect cell)? onPeek;
  final VoidCallback? onPeekEnd;
  final String? semanticLabel;

  @override
  State<DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<DayCell> with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController.unbounded(vsync: this, value: 1);

  @override
  void didUpdateWidget(DayCell old) {
    super.didUpdateWidget(old);
    if (old.entry == null && widget.entry != null && !GtMotion.reduced(context)) {
      _pop.value = 0.7;
      _pop.animateWith(SpringSimulation(GtMotion.pop, 0.7, 1, 0));
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final logged = widget.entry != null;
    final filled = logged && !widget.muted;

    final Color fill;
    final Color textColor;
    if (filled) {
      fill = c.accent;
      textColor = c.onAccent;
    } else if (logged) {
      fill = c.surface3;
      textColor = c.text2;
    } else {
      fill = Colors.transparent;
      textColor = widget.isFuture
          ? c.text3.withValues(alpha: 0.6)
          : widget.isToday
          ? c.text1
          : c.text2;
    }

    final ringColor = widget.selected || widget.isToday ? c.text1 : Colors.transparent;

    final cell = AnimatedBuilder(
      animation: _pop,
      builder: (context, child) => Transform.scale(scale: _pop.value, child: child),
      child: AnimatedContainer(
        duration: GtMotion.of(context, GtMotion.medium),
        curve: GtMotion.emphasized,
        width: widget.size,
        height: widget.size,
        padding: const EdgeInsets.all(3),
        decoration: ShapeDecoration(
          shape: CircleBorder(side: BorderSide(color: ringColor, width: 1.6)),
        ),
        child: AnimatedContainer(
          duration: GtMotion.of(context, GtMotion.medium),
          curve: GtMotion.emphasized,
          decoration: ShapeDecoration(color: fill, shape: const CircleBorder()),
          alignment: Alignment.center,
          child: Text(
            '${DayKeys.day(widget.dayKey)}',
            style: GtText.mono.sized(14).weight(filled || widget.isToday ? 600 : 500).colored(textColor),
          ),
        ),
      ),
    );

    return Semantics(
      label: widget.semanticLabel,
      button: widget.onTap != null,
      excludeSemantics: true,
      child: GestureDetector(
        onLongPressStart: widget.onPeek == null
            ? null
            : (_) {
                Haptics.medium();
                final box = context.findRenderObject()! as RenderBox;
                widget.onPeek!(box.localToGlobal(Offset.zero) & box.size);
              },
        onLongPressEnd: widget.onPeek == null ? null : (_) => widget.onPeekEnd?.call(),
        child: Center(
          child: Pressable(onTap: widget.onTap, haptic: PressHaptic.selection, scale: 0.88, child: cell),
        ),
      ),
    );
  }
}
