import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../calendar/month_grid.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';

/// The whole year as twelve mini months: a heatmap that is readable on a
/// phone. Tapping a month opens it in the calendar.
class YearView extends StatelessWidget {
  const YearView({
    super.key,
    required this.year,
    required this.minYear,
    required this.today,
    required this.weekStart,
    required this.days,
    required this.onYearChanged,
    required this.onMonthTap,
  });

  final int year;
  final int minYear;
  final int today;
  final int weekStart;
  final Set<int> days;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<YearMonth> onMonthTap;

  @override
  Widget build(BuildContext context) {
    final maxYear = DayKeys.year(today);
    final count = days.where((d) => DayKeys.year(d) == year).length;
    return GtCard(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Arrow(icon: GtIcons.chevronLeft, onTap: year > minYear ? () => onYearChanged(year - 1) : null),
              Expanded(
                child: AnimatedSwitcher(
                  duration: GtMotion.of(context, GtMotion.medium),
                  child: Column(
                    key: ValueKey(year),
                    children: [
                      Text('$year', style: GtText.dotFigure(26)),
                      const SizedBox(height: 2),
                      Text(Fmt.plural(count, 'session'), style: context.tx.caption),
                    ],
                  ),
                ),
              ),
              _Arrow(icon: GtIcons.chevronRight, onTap: year < maxYear ? () => onYearChanged(year + 1) : null),
            ],
          ),
          const SizedBox(height: GtSpace.lg),
          AnimatedSwitcher(
            duration: GtMotion.of(context, const Duration(milliseconds: 320)),
            child: RepaintBoundary(
              key: ValueKey(year),
              child: LayoutBuilder(
                builder: (context, c) {
                  const gap = GtSpace.md;
                  final w = (c.maxWidth - gap * 2) / 3;
                  return Wrap(
                    spacing: gap,
                    runSpacing: GtSpace.lg,
                    children: [
                      for (var m = 1; m <= 12; m++)
                        SizedBox(
                          width: w,
                          child: _MiniMonth(
                            month: (year: year, month: m),
                            today: today,
                            weekStart: weekStart,
                            days: days,
                            onTap: () => onMonthTap((year: year, month: m)),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMonth extends StatelessWidget {
  const _MiniMonth({
    required this.month,
    required this.today,
    required this.weekStart,
    required this.days,
    required this.onTap,
  });

  final YearMonth month;
  final int today;
  final int weekStart;
  final Set<int> days;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final future = month.startKey > today;
    return Pressable(
      onTap: future ? null : onTap,
      haptic: PressHaptic.selection,
      scale: 0.95,
      semanticLabel: '${Fmt.monthName(month.month)} ${month.year}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Fmt.monthShort(month.month).toUpperCase(),
            style: GtText.overline.sized(10).colored(future ? context.c.text3 : context.c.text2),
          ),
          const SizedBox(height: 6),
          AspectRatio(
            aspectRatio: 7 / 6,
            child: CustomPaint(
              painter: _MiniMonthPainter(
                month: month,
                today: today,
                weekStart: weekStart,
                days: days,
                on: context.c.isDark ? context.c.accent : context.c.accentStrong,
                off: context.c.dotOff,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMonthPainter extends CustomPainter {
  _MiniMonthPainter({
    required this.month,
    required this.today,
    required this.weekStart,
    required this.days,
    required this.on,
    required this.off,
  });

  final YearMonth month;
  final int today;
  final int weekStart;
  final Set<int> days;
  final Color on;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 7;
    final blanks = MonthLayout.leadingBlanks(month, weekStart);
    final total = DayKeys.daysInMonth(month.year, month.month);
    final lit = Paint()..color = on;
    final unlit = Paint()..color = off;
    final future = Paint()..color = off.withValues(alpha: off.a * 0.4);
    for (var d = 1; d <= total; d++) {
      final i = blanks + d - 1;
      final key = month.startKey + d - 1;
      final center = Offset((i % 7 + 0.5) * cell, (i ~/ 7 + 0.5) * cell);
      final logged = days.contains(key);
      canvas.drawCircle(
        center,
        cell * (logged ? 0.42 : 0.26),
        logged
            ? lit
            : key > today
            ? future
            : unlit,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniMonthPainter old) =>
      old.month != month || old.today != today || old.weekStart != weekStart || old.on != on || old.off != off || old.days != days;
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: GtMotion.fast,
      opacity: onTap == null ? 0.25 : 1,
      child: CircleButton(icon: icon, onTap: onTap, iconSize: 15, size: 36, solid: true),
    );
  }
}
