import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../calendar/month_grid.dart';
import '../calendar/month_pager.dart';
import '../widgets/controls.dart';
import '../widgets/gt_chip.dart';

/// A compact calendar for choosing a past day (logging, weigh-ins).
Future<int?> pickDay(BuildContext context, WidgetRef ref, {required int selected, String title = 'Choose a day'}) {
  return showModalBottomSheet<int>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _DayPickerSheet(selected: selected, title: title),
  );
}

class _DayPickerSheet extends ConsumerStatefulWidget {
  const _DayPickerSheet({required this.selected, required this.title});

  final int selected;
  final String title;

  @override
  ConsumerState<_DayPickerSheet> createState() => _DayPickerSheetState();
}

class _DayPickerSheetState extends ConsumerState<_DayPickerSheet> {
  late YearMonth _month = yearMonthOf(widget.selected);

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final weekStart = ref.watch(settingsProvider.select((s) => s.weekStart));
    final entries = ref.watch(summariesByDayProvider);
    final yesterday = DayKeys.addDays(today, -1);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.md, 0, GtSpace.md, GtSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(GtSpace.sm, GtSpace.xs, GtSpace.sm, GtSpace.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: Text(widget.title, style: GtText.title)),
                  AnimatedSwitcher(
                    duration: GtMotion.medium,
                    child: Text(
                      '${Fmt.monthShort(_month.month)} ${_month.year}',
                      key: ValueKey(_month),
                      style: GtText.mono.colored(GtColors.text2),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.sm),
              child: Row(
                children: [
                  GtChip(
                    label: 'Today',
                    height: 34,
                    selected: widget.selected == today,
                    onTap: () => Navigator.pop(context, today),
                  ),
                  const SizedBox(width: GtSpace.sm),
                  GtChip(
                    label: 'Yesterday',
                    height: 34,
                    selected: widget.selected == yesterday,
                    onTap: () => Navigator.pop(context, yesterday),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GtSpace.md),
            MonthPager(
              current: yearMonthOf(today),
              initial: _month,
              weekStart: weekStart,
              onChanged: (m) => setState(() => _month = m),
              builder: (context, m) => MonthGrid(
                month: m,
                weekStart: weekStart,
                today: today,
                entries: entries,
                selectedDay: widget.selected,
                onDayTap: (d) => Navigator.pop(context, d),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
