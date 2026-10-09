import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/entry.dart';
import '../../data/repositories/session_repository.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../art/mist_background.dart';
import '../widgets/autosave_field.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/toast.dart';
import 'day_picker_sheet.dart';
import 'exercise_section.dart';
import 'log_sections.dart';

/// Logging and editing a day, in one stacked sheet. Every change is written
/// straight away; closing the sheet (Done, swipe down or back) is all it takes.
class LogSheet extends ConsumerStatefulWidget {
  const LogSheet({super.key, required this.initialDayKey});

  final int initialDayKey;

  @override
  ConsumerState<LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends ConsumerState<LogSheet> {
  late int _day = widget.initialDayKey;
  // Read eagerly: dispose() needs it, and ref is unusable by then.
  late final SessionRepository _repo;
  final _flush = FlushController();
  final _scroll = ScrollController();
  final _existedAtOpen = <int, bool>{};
  final _touched = <int>{};
  bool _scrolled = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(sessionRepoProvider);
    _noteExisting(_day);
    _scroll.addListener(() {
      final scrolled = _scroll.offset > 2;
      if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    });
  }

  void _noteExisting(int day) =>
      _existedAtOpen.putIfAbsent(day, () => ref.read(summariesByDayProvider).containsKey(day));

  /// Runs a write against the current day and remembers it was touched.
  Future<void> _write(Future<void> Function(SessionRepository repo, int day) op) {
    _touched.add(_day);
    return op(_repo, _day);
  }

  Future<void> _changeDay() async {
    final picked = await pickDay(context, ref, selected: _day, title: 'Change day');
    if (picked == null || picked == _day || !mounted) return;
    _flush.flushAll();
    final previous = _day;
    _noteExisting(picked);
    setState(() => _day = picked);
    await _repo.pruneIfEmpty(previous);
  }

  /// Called once, however the sheet closes. Pending text is flushed first so
  /// those writes are queued ahead of the empty-entry check.
  void _onClosed() {
    if (_closed) return;
    _closed = true;
    _flush.flushAll();
    _finish(_repo, _day, Set.of(_touched), _existedAtOpen[_day] ?? true);
  }

  static Future<void> _finish(SessionRepository repo, int day, Set<int> touched, bool existed) async {
    for (final d in touched) {
      if (d != day) await repo.pruneIfEmpty(d);
    }
    final pruned = await repo.pruneIfEmpty(day);
    if (pruned || existed || !touched.contains(day)) return;
    Haptics.medium();
    Toasts.show(
      'Logged ${Fmt.weekdayDayMonth(day)}',
      actionLabel: 'Undo',
      onAction: () => repo.deleteEntry(day),
    );
  }

  @override
  void dispose() {
    _onClosed();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final entry = ref.watch(entryProvider(_day)).value;
    final today = ref.watch(todayProvider);
    final settings = ref.watch(settingsProvider);
    final logicalToday = DayKeys.logicalToday(dayStartHour: settings.dayStartHour);
    final showLateNight = !settings.lateNightHintSeen && _day == logicalToday && logicalToday != today;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final keyboardOpen = keyboard > 0;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _onClosed();
      },
      child: FlushScope(
        controller: _flush,
        child: Material(
          color: c.bg,
          child: MistBackground(
            child: Stack(
              children: [
                Column(
                  children: [
                    _SheetHeader(
                      day: _day,
                      today: today,
                      isNew: !(_existedAtOpen[_day] ?? false),
                      elevated: _scrolled,
                      onPickDay: _changeDay,
                    ),
                    Expanded(
                      child: CustomScrollView(
                        controller: _scroll,
                        slivers: [
                          if (showLateNight)
                            SliverToBoxAdapter(
                              child: LateNightNote(
                                dayKey: _day,
                                onDismiss: () => ref.read(settingsProvider.notifier).markLateNightHintSeen(),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: GroupsSection(
                              key: ValueKey('groups-$_day'),
                              dayKey: _day,
                              entry: entry,
                              onToggle: (id, selected) => _write((r, d) => r.setGroupSelected(d, id, selected)),
                              onCombo: (ids) {
                                Haptics.medium();
                                _write((r, d) => r.setGroups(d, ids));
                              },
                            ),
                          ),
                          ExerciseSection(
                            key: ValueKey('exercises-$_day'),
                            dayKey: _day,
                            entry: entry,
                            write: _write,
                          ),
                          SliverToBoxAdapter(
                            child: NoteSection(
                              key: ValueKey('note-$_day'),
                              note: entry?.session.note ?? '',
                              onSave: (text) => _write((r, d) => r.setNote(d, text)),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: MoreSection(
                              key: ValueKey('more-$_day'),
                              dayKey: _day,
                              durationMin: entry?.session.durationMin,
                              onDuration: (min) => _write((r, d) => r.setDuration(d, min)),
                            ),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: keyboard + bottomPadding + 112)),
                        ],
                      ),
                    ),
                  ],
                ),
                // The pinned "Done" pill, like the reference's bottom button.
                // It steps aside while the keyboard is up.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: keyboardOpen,
                    child: AnimatedSlide(
                      duration: GtMotion.of(context, GtMotion.medium),
                      curve: GtMotion.emphasized,
                      offset: keyboardOpen ? const Offset(0, 1.2) : Offset.zero,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(GtSpace.gutter, 28, GtSpace.gutter, bottomPadding + GtSpace.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [c.bg.withValues(alpha: 0), c.bg.withValues(alpha: 0.95)],
                            stops: const [0, 0.45],
                          ),
                        ),
                        child: GtButton(
                          label: 'Done',
                          expand: true,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.day,
    required this.today,
    required this.isNew,
    required this.elevated,
    required this.onPickDay,
  });

  final int day;
  final int today;
  final bool isNew;
  final bool elevated;
  final VoidCallback onPickDay;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedContainer(
      duration: GtMotion.medium,
      decoration: BoxDecoration(
        color: elevated ? c.bg.withValues(alpha: 0.96) : c.bg.withValues(alpha: 0),
        border: Border(bottom: BorderSide(color: elevated ? c.hairline : Colors.transparent)),
      ),
      child: Column(
        children: [
          const SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.gutter - 4, 2, GtSpace.gutter, GtSpace.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Pressable(
                onTap: onPickDay,
                haptic: PressHaptic.selection,
                scale: 0.96,
                semanticLabel: 'Change day',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isNew ? 'NEW ENTRY' : 'EDITING', style: context.tx.tag),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: AnimatedSwitcher(
                              duration: GtMotion.medium,
                              child: Text(
                                Fmt.sheetDate(day, today),
                                key: ValueKey(day),
                                style: GtText.title.sized(22),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: ShapeDecoration(color: c.surface, shape: CircleBorder(side: BorderSide(color: c.hairline))),
                            child: Icon(GtIcons.chevronDown, size: 12, color: c.text2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains the 4 AM rule the first time it applies.
class LateNightNote extends StatelessWidget {
  const LateNightNote({super.key, required this.dayKey, required this.onDismiss});

  final int dayKey;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.sm, GtSpace.lg, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.sm, GtSpace.md),
        decoration: ShapeDecoration(color: c.ink, shape: squircle(GtRadius.md)),
        child: Row(
          children: [
            Icon(GtIcons.night, size: 18, color: c.accentOnInk),
            const SizedBox(width: GtSpace.md),
            Expanded(
              child: Text(
                "It's after midnight, so this goes to ${Fmt.weekdayDayMonth(dayKey)}. "
                'You can change when a day starts in Settings.',
                style: GtText.label.colored(c.onInk),
              ),
            ),
            Pressable(
              onTap: onDismiss,
              child: Padding(
                padding: const EdgeInsets.all(GtSpace.sm),
                child: Text('Got it', style: GtText.label.weight(600).colored(c.accentOnInk)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exposed for the exercise section's "write" callback.
typedef SheetWrite = Future<void> Function(Future<void> Function(SessionRepository repo, int day) op);

extension EntryGroups on EntryDetail? {
  Set<int> get selectedGroupIds => this?.groupIds ?? const {};
}
