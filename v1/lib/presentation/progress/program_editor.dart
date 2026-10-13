import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/database/app_database.dart';
import '../../data/models/progress.dart';
import '../../logic/program_plan.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/progress_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../calendar/month_grid.dart';
import '../log/exercise_picker_sheet.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/gt_chip.dart';
import '../widgets/labels.dart';
import '../widgets/large_title_header.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';
import '../widgets/toast.dart';

/// Saves (or clears, with null) one weekday of the program. Missed days are
/// counted from the day the set of training weekdays last changed, so a new
/// schedule never paints old weeks red.
Future<void> saveProgramDay(WidgetRef ref, int weekday, ProgramDayPlan? plan) async {
  final repo = ref.read(programRepoProvider);
  final before = (ref.read(programProvider).value ?? const {}).keys.toSet();
  if (plan == null) {
    await repo.clearDay(weekday);
  } else {
    await repo.saveDay(plan);
  }
  final after = {...before}..remove(weekday);
  if (plan != null) after.add(weekday);
  final settings = ref.read(settingsProvider.notifier);
  if (after.isEmpty) {
    settings.setProgramStart(null);
  } else if (after.length != before.length || !after.containsAll(before)) {
    settings.setProgramStart(ref.read(logicalTodayProvider));
  }
}

/// The week at a glance: one row per weekday, tap to plan it.
class ProgramEditorScreen extends ConsumerWidget {
  const ProgramEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programProvider).value ?? const <int, ProgramDayPlan>{};
    final weekStart = ref.watch(settingsProvider.select((s) => s.weekStart));
    final start = ref.watch(settingsProvider.select((s) => s.programStartDayKey));
    final byId = ref.watch(groupsByIdProvider);
    final padding = MediaQuery.paddingOf(context);
    final weekdays = MonthLayout.weekdays(weekStart);

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: LargeTitleHeader(title: 'Weekly program', topPadding: padding.top, showBack: true),
          ),
          SliverList.list(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
                child: Text(
                  'Pick the days you plan to train. Those days get a dot on the calendar, '
                  'turn red if they pass without a session, and fill the log in one tap.',
                  style: GtText.label.colored(GtColors.text2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
                child: GtCard(
                  padding: const EdgeInsets.symmetric(vertical: GtSpace.xs),
                  child: Column(
                    children: [
                      for (var i = 0; i < 7; i++) ...[
                        if (i > 0) const Divider(indent: GtSpace.lg),
                        _WeekdayRow(
                          weekday: weekdays[i],
                          plan: program[weekdays[i]],
                          detail: _detail(program[weekdays[i]], byId, ref),
                          onTap: () => showProgramDaySheet(context, ref, weekdays[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (start != null && program.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.md, GtSpace.gutter, 0),
                  child: Text('Missed days are counted from ${Fmt.dayMonthYear(start)}.', style: GtText.caption),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.xxl, GtSpace.lg, 0),
                  child: GtButton(
                    label: 'Clear program',
                    kind: GtButtonKind.ghost,
                    expand: true,
                    onTap: () async {
                      final saved = program.values.toList();
                      final savedStart = start;
                      await ref.read(programRepoProvider).clearAll();
                      ref.read(settingsProvider.notifier).setProgramStart(null);
                      Haptics.heavy();
                      Toasts.show(
                        'Program cleared',
                        actionLabel: 'Undo',
                        onAction: () async {
                          for (final p in saved) {
                            await ref.read(programRepoProvider).saveDay(p);
                          }
                          ref.read(settingsProvider.notifier).setProgramStart(savedStart);
                        },
                      );
                    },
                  ),
                ),
              ],
              SizedBox(height: padding.bottom + GtSpace.x4),
            ],
          ),
        ],
      ),
    );
  }

  static String _detail(ProgramDayPlan? plan, Map<int, MuscleGroup> byId, WidgetRef ref) {
    if (plan == null) return 'Rest';
    final groups = groupLabel(plan.groupIds, byId);
    final ex = plan.exerciseIds.isEmpty ? '' : Fmt.plural(plan.exerciseIds.length, 'exercise');
    return [if (groups.isNotEmpty) groups, if (ex.isNotEmpty) ex].join(' · ');
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.weekday, required this.plan, required this.detail, required this.onTap});

  final int weekday;
  final ProgramDayPlan? plan;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final training = plan != null;
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.md, GtSpace.md),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                Fmt.isoWeekdayShort(weekday).toUpperCase(),
                style: GtText.mono.weight(600).colored(training ? context.accent : GtColors.text3),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training ? plan!.label : 'Rest',
                    style: GtText.body.colored(training ? GtColors.text1 : GtColors.text3),
                  ),
                  if (training && detail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(detail, style: GtText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const Icon(GtIcons.chevronRight, size: 14, color: GtColors.text3),
          ],
        ),
      ),
    );
  }
}

Future<void> showProgramDaySheet(BuildContext context, WidgetRef ref, int weekday) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _ProgramDaySheet(weekday: weekday),
  );
}

const _labelSuggestions = ['Push', 'Pull', 'Legs', 'Upper', 'Lower', 'Full body', 'Cardio'];

class _ProgramDaySheet extends ConsumerStatefulWidget {
  const _ProgramDaySheet({required this.weekday});

  final int weekday;

  @override
  ConsumerState<_ProgramDaySheet> createState() => _ProgramDaySheetState();
}

class _ProgramDaySheetState extends ConsumerState<_ProgramDaySheet> {
  late final ProgramDayPlan? _existing = (ref.read(programProvider).value ?? const {})[widget.weekday];
  late bool _train = _existing != null;
  late final _label = TextEditingController(text: _existing?.label ?? '');
  late final _groups = <int>{...?_existing?.groupIds};
  late final _exercises = <int>[...?_existing?.exerciseIds];

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  String get _effectiveLabel {
    final t = _label.text.trim();
    if (t.isNotEmpty) return t;
    final byId = ref.read(groupsByIdProvider);
    final g = groupLabel(_groups.toList(), byId);
    return g.isEmpty ? 'Training' : g;
  }

  Future<void> _save() async {
    Haptics.medium();
    await saveProgramDay(
      ref,
      widget.weekday,
      _train
          ? ProgramDayPlan(
              weekday: widget.weekday,
              label: _effectiveLabel,
              groupIds: _groups.toList(),
              exerciseIds: List.of(_exercises),
            )
          : null,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(visibleGroupsProvider);
    final exercises = ref.watch(exercisesByIdProvider);
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetHandle(),
                const SizedBox(height: GtSpace.xs),
                Text(Fmt.isoWeekdayName(widget.weekday), style: GtText.title),
                const SizedBox(height: GtSpace.lg),
                GtSegmented<bool>(
                  values: const [false, true],
                  selected: _train,
                  labelOf: (t) => t ? 'Train' : 'Rest',
                  onChanged: (t) => setState(() => _train = t),
                ),
                if (_train) ...[
                  const SectionHeader('Name', padding: EdgeInsets.fromLTRB(0, GtSpace.xl, 0, GtSpace.sm)),
                  TextField(
                    controller: _label,
                    textCapitalization: TextCapitalization.words,
                    style: GtText.body,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(hintText: 'e.g. Push'),
                  ),
                  const SizedBox(height: GtSpace.sm),
                  Wrap(
                    spacing: GtSpace.sm,
                    runSpacing: GtSpace.sm,
                    children: [
                      for (final s in _labelSuggestions)
                        GtChip(
                          label: s,
                          height: 34,
                          horizontalPadding: 12,
                          selected: _label.text.trim() == s,
                          onTap: () => setState(() => _label.text = s),
                        ),
                    ],
                  ),
                  const SectionHeader('Muscle groups', padding: EdgeInsets.fromLTRB(0, GtSpace.xl, 0, GtSpace.sm)),
                  Wrap(
                    spacing: GtSpace.sm,
                    runSpacing: GtSpace.sm,
                    children: [
                      for (final g in groups)
                        GtChip(
                          label: g.name,
                          selected: _groups.contains(g.id),
                          onTap: () =>
                              setState(() => _groups.contains(g.id) ? _groups.remove(g.id) : _groups.add(g.id)),
                        ),
                    ],
                  ),
                  SectionHeader(
                    'Exercises',
                    padding: const EdgeInsets.fromLTRB(0, GtSpace.xl, 0, GtSpace.sm),
                    trailing: Text('OPTIONAL', style: GtText.overline.colored(GtColors.text3)),
                  ),
                  for (final id in _exercises)
                    Padding(
                      padding: const EdgeInsets.only(bottom: GtSpace.xs),
                      child: Row(
                        children: [
                          Expanded(child: Text(exercises[id]?.name ?? 'Exercise', style: GtText.body)),
                          Pressable(
                            onTap: () => setState(() => _exercises.remove(id)),
                            haptic: PressHaptic.selection,
                            scale: 0.85,
                            semanticLabel: 'Remove ${exercises[id]?.name ?? 'exercise'}',
                            child: const Padding(
                              padding: EdgeInsets.all(GtSpace.sm),
                              child: Icon(GtIcons.close, size: 16, color: GtColors.text3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GtButton(
                      label: 'Add exercises',
                      icon: GtIcons.add,
                      kind: GtButtonKind.secondary,
                      height: 40,
                      onTap: () => pickExercises(
                        context,
                        groupIds: _groups,
                        watchSelected: (_) => _exercises.toSet(),
                        onAdd: (id) => setState(() {
                          if (!_exercises.contains(id)) _exercises.add(id);
                        }),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: GtSpace.xxl),
                GtButton(
                  label: 'Save',
                  expand: true,
                  haptic: PressHaptic.none,
                  onTap: _train && _groups.isEmpty && _exercises.isEmpty && _label.text.trim().isEmpty ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// This week's program on the Progress tab: a pill per day, done, missed,
/// planned or rest, and what's next.
class ProgramWeekCard extends ConsumerWidget {
  const ProgramWeekCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programProvider).value ?? const <int, ProgramDayPlan>{};
    void open() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProgramEditorScreen()));

    if (program.isEmpty) {
      return GtCard(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Plan your week', style: GtText.titleSmall),
            const SizedBox(height: GtSpace.xs),
            Text(
              'Set which days you train and what. Missed days show up red on the calendar.',
              style: GtText.body.colored(GtColors.text2),
            ),
            const SizedBox(height: GtSpace.lg),
            GtButton(
              label: 'Set up program',
              icon: GtIcons.program,
              kind: GtButtonKind.secondary,
              height: 44,
              onTap: open,
            ),
          ],
        ),
      );
    }

    final weekStart = ref.watch(settingsProvider.select((s) => s.weekStart));
    final today = ref.watch(logicalTodayProvider);
    final planOf = ref.watch(planOfProvider);
    final byId = ref.watch(groupsByIdProvider);
    final byDay = ref.watch(summariesByDayProvider);
    final first = DayKeys.weekStartOf(today, weekStart);
    final days = [for (var i = 0; i < 7; i++) DayKeys.addDays(first, i)];
    final todayPlan = program[DayKeys.weekday(today)];
    final missed = days.where((d) => planOf(d) == PlanStatus.missed).length;

    // The next training day from today on (today counts if not logged yet).
    String next() {
      for (var i = 0; i < 7; i++) {
        final d = DayKeys.addDays(today, i);
        final p = program[DayKeys.weekday(d)];
        if (p == null) continue;
        if (i == 0 && planOf(d) == PlanStatus.done) continue;
        final groups = groupLabel(p.groupIds, byId);
        final when = i == 0 ? 'Today' : (i == 1 ? 'Tomorrow' : Fmt.weekdayLong(d));
        return '$when · ${p.label}${groups.isEmpty || groups == p.label ? '' : ' · $groups'}';
      }
      return '';
    }

    return GtCard(
      onTap: open,
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.lg, GtSpace.lg, GtSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final d in days)
                Expanded(
                  child: _DayPill(
                    initial: Fmt.weekdayInitial(DayKeys.weekday(d)),
                    status: planOf(d),
                    training: program.containsKey(DayKeys.weekday(d)),
                    isToday: d == today,
                    logged: byDay.containsKey(d),
                  ),
                ),
            ],
          ),
          const SizedBox(height: GtSpace.lg),
          Row(
            children: [
              Icon(todayPlan != null ? GtIcons.program : GtIcons.calendar, size: 16, color: GtColors.text2),
              const SizedBox(width: GtSpace.sm),
              Expanded(
                child: Text(next(), style: GtText.label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (missed > 0) Text('$missed missed', style: GtText.label.weight(600).colored(GtColors.missed)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.initial,
    required this.status,
    required this.training,
    required this.isToday,
    required this.logged,
  });

  final String initial;
  final PlanStatus status;
  final bool training;
  final bool isToday;
  final bool logged;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    final (Color fill, Color border, Widget? mark) = switch (status) {
      PlanStatus.done => (accent, Colors.transparent, const Icon(GtIcons.check, size: 14, color: GtColors.onAccent)),
      PlanStatus.missed => (
        GtColors.missedMuted,
        GtColors.missed,
        const Icon(GtIcons.close, size: 13, color: GtColors.missed),
      ),
      PlanStatus.planned => (Colors.transparent, isToday ? accent : GtColors.hairlineStrong, null),
      PlanStatus.holiday => (
        GtColors.s2,
        Colors.transparent,
        const Icon(GtIcons.holiday, size: 14, color: GtColors.text2),
      ),
      PlanStatus.none =>
        logged
            ? (context.gt.accentMuted, Colors.transparent, Icon(GtIcons.check, size: 13, color: accent))
            : (Colors.transparent, Colors.transparent, null),
    };
    return Column(
      children: [
        Text(
          initial,
          style: GtText.monoSmall.weight(isToday ? 700 : 500).colored(isToday ? GtColors.text1 : GtColors.text3),
        ),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 32,
          decoration: ShapeDecoration(
            color: fill,
            shape: squircle(11, side: BorderSide(color: border, width: 1.5)),
          ),
          child: Center(
            child:
                mark ??
                (training
                    ? Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                      )
                    : Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: GtColors.s3, shape: BoxShape.circle),
                      )),
          ),
        ),
      ],
    );
  }
}
