import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/navigation_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../log/log_actions.dart';
import '../settings/settings_screen.dart';
import '../shell/glass_nav_bar.dart';
import '../widgets/gt_chip.dart';
import '../widgets/labels.dart';
import 'calendar_header.dart';
import 'day_peek.dart';
import 'entry_card.dart';
import 'month_grid.dart';
import 'month_pager.dart';
import '../../logic/providers/progress_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  var _pagerKey = GlobalKey<MonthPagerState>();
  late YearMonth _current = yearMonthOf(ref.read(todayProvider));
  late YearMonth _month = _current;
  int? _filter;

  void _onDayTap(int dayKey, Map<int, EntrySummary> entries) {
    if (entries.containsKey(dayKey)) {
      openEntry(context, dayKey);
    } else {
      openLogSheet(context, ref, dayKey: dayKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final current = yearMonthOf(today);
    if (current != _current) {
      // The month rolled over while the app was open: restart the pager on it.
      _current = current;
      _month = current;
      _pagerKey = GlobalKey<MonthPagerState>();
    }

    // Another screen asked to show a particular month.
    ref.listen(calendarJumpProvider, (_, month) {
      if (month == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pagerKey.currentState?.animateTo(month);
        ref.read(calendarJumpProvider.notifier).consumed();
      });
    });

    final weekStart = ref.watch(settingsProvider.select((s) => s.weekStart));
    final entries = ref.watch(summariesByDayProvider);
    final groupsById = ref.watch(groupsByIdProvider);
    final planOf = ref.watch(planOfProvider);
    final loaded = ref.watch(summariesProvider).hasValue;

    final monthEntries = [for (final e in entries.values) if (_month.contains(e.dayKey)) e]
      ..sort((a, b) => b.dayKey.compareTo(a.dayKey));
    final visibleEntries = _filter == null
        ? monthEntries
        : [for (final e in monthEntries) if (e.groupIds.contains(_filter)) e];

    final padding = MediaQuery.paddingOf(context);
    final reduced = GtMotion.reduced(context);

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: CalendarHeaderDelegate(
            topPadding: padding.top,
            month: _month,
            count: monthEntries.length,
            isCurrentMonth: _month == current,
            accent: context.accent,
            onToday: () => _pagerKey.currentState?.animateTo(current),
            onSettings: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.md),
          sliver: SliverToBoxAdapter(
            child: MonthPager(
              key: _pagerKey,
              current: current,
              initial: _month,
              weekStart: weekStart,
              onChanged: (m) => setState(() {
                _month = m;
                _filter = null;
              }),
              builder: (context, m) => MonthGrid(
                month: m,
                weekStart: weekStart,
                today: today,
                entries: entries,
                highlightGroupId: m == _month ? _filter : null,
                onDayTap: (d) => _onDayTap(d, entries),
                onDayPeek: (d, rect) =>
                    DayPeek.show(context, anchor: rect, entry: entries[d]!, groups: groupsById),
                onPeekEnd: DayPeek.hide,
                semanticsFor: (d) => daySemantics(d, entries[d], groupsById, plan: planOf(d)),
                planOf: planOf,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _GroupFilter(
            entries: monthEntries,
            groups: groupsById,
            selected: _filter,
            onChanged: (id) => setState(() => _filter = id),
          ),
        ),
        if (loaded && visibleEntries.isEmpty)
          SliverToBoxAdapter(
            child: _EmptyMonth(month: _month, anyEntries: entries.isNotEmpty),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
            sliver: SliverList.separated(
              itemCount: visibleEntries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final card = EntryCard(key: ValueKey(visibleEntries[i].dayKey), entry: visibleEntries[i]);
                if (reduced) return card;
                return card
                    .animate(key: ValueKey('${visibleEntries[i].dayKey}-$_month'))
                    .fadeIn(duration: 320.ms, delay: (35 * i.clamp(0, 8)).ms)
                    .moveY(begin: 10, end: 0, duration: 420.ms, delay: (35 * i.clamp(0, 8)).ms, curve: GtMotion.emphasized);
              },
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: padding.bottom + GlassNavBar.height + 48)),
      ],
    );
  }
}

/// Muscle groups trained this month as filter chips; picking one mutes
/// every other gym day ("when did I train legs?").
class _GroupFilter extends StatelessWidget {
  const _GroupFilter({required this.entries, required this.groups, required this.selected, required this.onChanged});

  final List<EntrySummary> entries;
  final Map<int, MuscleGroup> groups;
  final int? selected;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final used = {for (final e in entries) ...e.groupIds}.map((id) => groups[id]).nonNulls.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return AnimatedSize(
      duration: GtMotion.of(context, GtMotion.medium),
      curve: GtMotion.emphasized,
      alignment: Alignment.topCenter,
      child: entries.length < 2 || used.length < 2
          ? const SizedBox(width: double.infinity, height: GtSpace.lg)
          : SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.lg),
                itemCount: used.length,
                separatorBuilder: (_, _) => const SizedBox(width: GtSpace.sm),
                itemBuilder: (context, i) {
                  final g = used[i];
                  return GtChip(
                    label: g.name,
                    height: 34,
                    horizontalPadding: 14,
                    selected: selected == g.id,
                    onTap: () => onChanged(selected == g.id ? null : g.id),
                  );
                },
              ),
            ),
    );
  }
}

class _EmptyMonth extends StatelessWidget {
  const _EmptyMonth({required this.month, required this.anyEntries});

  final YearMonth month;
  final bool anyEntries;

  @override
  Widget build(BuildContext context) {
    final text = anyEntries
        ? 'Nothing logged in ${Fmt.monthName(month.month)}.'
        : 'Your gym days will appear here.\nTap ＋ after a session to log it.';
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.x4, GtSpace.x3, GtSpace.x4, 0),
      child: Text(text, textAlign: TextAlign.center, style: GtText.body.colored(GtColors.text2)),
    );
  }
}
