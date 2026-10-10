import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/units.dart';
import '../../data/database/app_database.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../log/exercise_picker_sheet.dart';
import '../widgets/autosave_field.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/option_sheet.dart';
import '../widgets/toast.dart';

Future<void> editWeeklyGoal(BuildContext context, WidgetRef ref) async {
  final s = ref.read(settingsProvider);
  final picked = await showOptionSheet<int>(
    context,
    title: 'Weekly goal',
    caption: 'Hit it every week to keep your streak going. Changes apply from this week on.',
    options: const [1, 2, 3, 4, 5, 6, 7],
    labelOf: (n) => '${Fmt.plural(n, 'session')} a week',
    selected: s.weeklyGoal,
  );
  if (picked == null) return;
  final week = DayKeys.weekStartOf(ref.read(logicalTodayProvider), s.weekStart);
  ref.read(settingsProvider.notifier).setWeeklyGoal(picked, weekStartKey: week);
  Haptics.medium();
}

Future<void> editMonthlyGoal(BuildContext context, WidgetRef ref) async {
  final picked = await showOptionSheet<int>(
    context,
    title: 'Monthly goal',
    caption: 'Sessions to reach each calendar month.',
    options: const [0, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24],
    labelOf: (n) => n == 0 ? 'Off' : '${Fmt.plural(n, 'session')} a month',
    selected: ref.read(settingsProvider).monthlyGoal,
  );
  if (picked == null) return;
  ref.read(settingsProvider.notifier).setMonthlyGoal(picked);
  Haptics.medium();
}

enum _NewGoal { lift, bodyWeight, monthly }

/// Asks which kind of goal to add, then opens its editor.
Future<void> addGoal(BuildContext context, WidgetRef ref) async {
  final hasBodyGoal = (ref.read(goalsProvider).value ?? const <Goal>[]).any((g) => g.kind == GoalKind.bodyWeight);
  final kind = await showOptionSheet<_NewGoal>(
    context,
    title: 'Add a goal',
    options: [
      _NewGoal.lift,
      if (!hasBodyGoal) _NewGoal.bodyWeight,
      if (ref.read(settingsProvider).monthlyGoal == 0) _NewGoal.monthly,
    ],
    labelOf: (k) => switch (k) {
      _NewGoal.lift => 'Lift target',
      _NewGoal.bodyWeight => 'Body-weight target',
      _NewGoal.monthly => 'Monthly sessions',
    },
  );
  if (kind == null || !context.mounted) return;
  switch (kind) {
    case _NewGoal.lift:
      await editLiftGoal(context, ref);
    case _NewGoal.bodyWeight:
      await editBodyWeightGoal(context, ref);
    case _NewGoal.monthly:
      await editMonthlyGoal(context, ref);
  }
}

/// Creates a lift goal (after picking the exercise) or edits [existing].
Future<void> editLiftGoal(BuildContext context, WidgetRef ref, {Goal? existing}) async {
  final exerciseId =
      existing?.exerciseId ?? await pickExercises(context, title: 'Goal for which lift?', single: true);
  if (exerciseId == null || !context.mounted) return;
  final exercise = ref.read(exercisesByIdProvider)[exerciseId];
  final unit = ref.read(settingsProvider).unit;
  final result = await showModalBottomSheet<_TargetResult>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _TargetSheet(
      title: exercise?.name ?? 'Lift target',
      caption: 'Lift this weight for at least this many reps in one set.',
      unit: unit,
      initialKg: existing?.targetKg,
      initialReps: existing?.targetReps,
      askReps: true,
      canRemove: existing != null,
    ),
  );
  if (result == null) return;
  final repo = ref.read(goalRepoProvider);
  if (result.remove) {
    await _removeWithUndo(ref, existing!);
  } else if (existing == null) {
    await repo.addLift(
      exerciseId: exerciseId,
      targetKg: result.kg!,
      targetReps: result.reps,
      today: ref.read(logicalTodayProvider),
    );
    Haptics.medium();
  } else {
    await repo.updateLift(existing.id, targetKg: result.kg!, targetReps: result.reps);
    Haptics.medium();
  }
}

Future<void> editBodyWeightGoal(BuildContext context, WidgetRef ref, {Goal? existing}) async {
  final unit = ref.read(settingsProvider).unit;
  final weights = ref.read(bodyWeightsProvider).value ?? const <BodyWeight>[];
  final latest = weights.isEmpty ? null : weights.last.weightKg;
  final result = await showModalBottomSheet<_TargetResult>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _TargetSheet(
      title: 'Body-weight target',
      caption: latest == null
          ? 'Progress starts from your first weigh-in.'
          : 'Progress counts from today’s ${Units.format(latest, unit, maxDecimals: 1)}.',
      unit: unit,
      initialKg: existing?.targetKg,
      askReps: false,
      canRemove: existing != null,
    ),
  );
  if (result == null) return;
  if (result.remove) {
    await _removeWithUndo(ref, existing!);
    return;
  }
  await ref
      .read(goalRepoProvider)
      .setBodyWeight(targetKg: result.kg!, startKg: latest, today: ref.read(logicalTodayProvider));
  Haptics.medium();
}

Future<void> _removeWithUndo(WidgetRef ref, Goal goal) async {
  final repo = ref.read(goalRepoProvider);
  await repo.remove(goal.id);
  Haptics.heavy();
  Toasts.show('Goal removed', actionLabel: 'Undo', onAction: () => repo.restore(goal));
}

typedef _TargetResult = ({double? kg, int? reps, bool remove});

class _TargetSheet extends StatefulWidget {
  const _TargetSheet({
    required this.title,
    required this.caption,
    required this.unit,
    required this.askReps,
    required this.canRemove,
    this.initialKg,
    this.initialReps,
  });

  final String title;
  final String caption;
  final WeightUnit unit;
  final bool askReps;
  final bool canRemove;
  final double? initialKg;
  final int? initialReps;

  @override
  State<_TargetSheet> createState() => _TargetSheetState();
}

class _TargetSheetState extends State<_TargetSheet> {
  late final _kg = TextEditingController(
    text: widget.initialKg == null ? '' : Units.format(widget.initialKg!, widget.unit, withUnit: false),
  );
  late final _reps = TextEditingController(text: widget.initialReps?.toString() ?? '');

  @override
  void dispose() {
    _kg.dispose();
    _reps.dispose();
    super.dispose();
  }

  double? get _value {
    final v = parseNumber(_kg.text);
    return v == null || v <= 0 ? null : v;
  }

  void _save() {
    final v = _value;
    if (v == null) return;
    final reps = int.tryParse(_reps.text.trim());
    Navigator.pop<_TargetResult>(context, (
      kg: Units.toKg(v, widget.unit),
      reps: reps == null || reps <= 1 ? null : reps,
      remove: false,
    ));
  }

  InputDecoration _decoration(String hint, String suffix) => InputDecoration(
    hintText: hint,
    suffixText: suffix,
    suffixStyle: GtText.label.colored(GtColors.text2),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: GtSpace.xs),
              Text(widget.title, style: GtText.title),
              const SizedBox(height: GtSpace.xs),
              Text(widget.caption, style: GtText.caption),
              const SizedBox(height: GtSpace.lg),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _kg,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: decimalInput,
                      style: GtText.body,
                      decoration: _decoration('Weight', widget.unit.name),
                    ),
                  ),
                  if (widget.askReps) ...[
                    const SizedBox(width: GtSpace.md),
                    Text('×', style: GtText.label.colored(GtColors.text3)),
                    const SizedBox(width: GtSpace.md),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _reps,
                        keyboardType: TextInputType.number,
                        inputFormatters: integerInput,
                        style: GtText.body,
                        decoration: _decoration('1', 'reps'),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: GtSpace.xl),
              GtButton(label: 'Save goal', onTap: _value == null ? null : _save, expand: true),
              if (widget.canRemove) ...[
                const SizedBox(height: GtSpace.sm),
                GtButton(
                  label: 'Remove goal',
                  kind: GtButtonKind.ghost,
                  expand: true,
                  onTap: () => Navigator.pop<_TargetResult>(context, (kg: null, reps: null, remove: true)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
