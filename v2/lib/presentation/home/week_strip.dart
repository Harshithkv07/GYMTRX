import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/entry.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../calendar/day_peek.dart';
import '../log/log_actions.dart';
import '../widgets/labels.dart';
import '../widgets/pressable.dart';

/// Seven day chips for a week, swipeable back through earlier weeks (never
/// into the future). Gym days are filled with the accent; today has a ring.
class WeekStrip extends ConsumerStatefulWidget {
  const WeekStrip({super.key});

  @override
  ConsumerState<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends ConsumerState<WeekStrip> {
  // Index of the current week; earlier weeks count down from here.
  static const _origin = 1040;
  final _controller = PageController(initialPage: _origin);
  int _page = _origin;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final today = ref.watch(todayProvider);
    final weekStart = ref.watch(settingsProvider.select((s) => s.weekStart));
    final entries = ref.watch(summariesByDayProvider);
    final thisWeek = DayKeys.weekStartOf(today, weekStart);
    int startOf(int page) => DayKeys.addDays(thisWeek, (page - _origin) * 7);

    final shown = startOf(_page);
    final count = [for (var i = 0; i < 7; i++) DayKeys.addDays(shown, i)].where(entries.containsKey).length;
    final title = _page == _origin
        ? 'This week'
        : '${Fmt.dayMonth(shown)} – ${Fmt.dayMonth(DayKeys.addDays(shown, 6))}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, 10),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: GtMotion.of(context, GtMotion.medium),
                  layoutBuilder: (current, previous) =>
                      Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
                  child: Text(title, key: ValueKey(title), style: GtText.label.weight(600)),
                ),
              ),
              if (_page != _origin)
                Pressable(
                  onTap: () => _controller.animateToPage(
                    _origin,
                    duration: GtMotion.of(context, const Duration(milliseconds: 480)),
                    curve: GtMotion.emphasized,
                  ),
                  haptic: PressHaptic.selection,
                  child: Padding(
                    padding: const EdgeInsets.only(right: GtSpace.md),
                    child: Text('Today', style: GtText.label.weight(600).colored(c.text2)),
                  ),
                ),
              Text(Fmt.plural(count, 'session'), style: GtText.monoSmall.colored(c.text2)),
            ],
          ),
        ),
        SizedBox(
          height: 66 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.15),
          child: PageView.builder(
            controller: _controller,
            itemCount: _origin + 1,
            onPageChanged: (p) {
              Haptics.selection();
              setState(() => _page = p);
            },
            itemBuilder: (context, page) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _DayChip(
                        dayKey: DayKeys.addDays(startOf(page), i),
                        today: today,
                        entry: entries[DayKeys.addDays(startOf(page), i)],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayChip extends ConsumerWidget {
  const _DayChip({required this.dayKey, required this.today, required this.entry});

  final int dayKey;
  final int today;
  final EntrySummary? entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final logged = entry != null;
    final isToday = dayKey == today;
    final future = dayKey > today;
    final fill = logged
        ? c.accent
        : future
        ? c.surface.withValues(alpha: c.isDark ? 0.35 : 0.45)
        : c.surface;
    final fg = logged ? c.onAccent : (future ? c.text3 : c.text1);
    final groups = ref.watch(groupsByIdProvider);

    final chip = AnimatedContainer(
      duration: GtMotion.of(context, GtMotion.medium),
      curve: GtMotion.emphasized,
      decoration: ShapeDecoration(
        color: fill,
        shape: StadiumBorder(
          side: isToday
              ? BorderSide(color: c.text1, width: 1.6)
              : BorderSide(color: logged || future ? Colors.transparent : c.hairline),
        ),
        shadows: logged || future || c.isDark ? null : c.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${DayKeys.day(dayKey)}', style: GtText.mono.sized(16).weight(600).colored(fg)),
          const SizedBox(height: 2),
          Text(Fmt.weekdayShort(dayKey), style: GtText.caption.sized(10).colored(fg.withValues(alpha: 0.7))),
        ],
      ),
    );

    return Semantics(
      label: daySemantics(dayKey, entry, groups),
      button: !future,
      excludeSemantics: true,
      child: GestureDetector(
        onLongPressStart: entry == null
            ? null
            : (_) {
                Haptics.medium();
                final box = context.findRenderObject()! as RenderBox;
                DayPeek.show(context, anchor: box.localToGlobal(Offset.zero) & box.size, entry: entry!, groups: groups);
              },
        onLongPressEnd: entry == null ? null : (_) => DayPeek.hide(),
        child: Pressable(
          onTap: future
              ? null
              : () => logged ? openEntry(context, dayKey) : openLogSheet(context, ref, dayKey: dayKey),
          haptic: PressHaptic.selection,
          scale: 0.9,
          child: chip,
        ),
      ),
    );
  }
}
