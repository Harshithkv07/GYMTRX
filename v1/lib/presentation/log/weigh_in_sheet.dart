import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/units.dart';
import '../../logic/providers/data_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/autosave_field.dart';
import '../widgets/controls.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import 'day_picker_sheet.dart';

/// Record body weight for any day, gym day or not.
Future<void> showWeighInSheet(BuildContext context, WidgetRef ref, {required int dayKey}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _WeighInSheet(dayKey: dayKey),
  );
}

class _WeighInSheet extends ConsumerStatefulWidget {
  const _WeighInSheet({required this.dayKey});

  final int dayKey;

  @override
  ConsumerState<_WeighInSheet> createState() => _WeighInSheetState();
}

class _WeighInSheetState extends ConsumerState<_WeighInSheet> {
  late int _day = widget.dayKey;
  late final _controller = TextEditingController(text: _initialText(_day));

  String _initialText(int day) {
    final unit = ref.read(settingsProvider).unit;
    final w = ref.read(bodyWeightByDayProvider)[day];
    return w == null ? '' : Units.format(w.weightKg, unit, withUnit: false, maxDecimals: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(double delta) {
    final unit = ref.read(settingsProvider).unit;
    final weights = ref.read(bodyWeightsProvider).value ?? const [];
    final base = parseNumber(_controller.text) ??
        (weights.isEmpty ? (unit == WeightUnit.kg ? 70.0 : 154.0) : Units.toDisplay(weights.last.weightKg, unit));
    Haptics.selection();
    final next = ((base + delta) * 10).round() / 10;
    _controller.text = Fmt.number(next, maxDecimals: 1);
    setState(() {});
  }

  Future<void> _save() async {
    final unit = ref.read(settingsProvider).unit;
    final repo = ref.read(bodyWeightRepoProvider);
    final v = parseNumber(_controller.text);
    if (v == null || v <= 0) return;
    Haptics.medium();
    await repo.upsert(_day, Units.toKg(v, unit));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final today = ref.watch(todayProvider);
    final weights = ref.watch(bodyWeightsProvider).value ?? const [];
    final existing = weights.where((w) => w.dayKey == _day).firstOrNull;
    final previous = weights.where((w) => w.dayKey < _day).lastOrNull;
    final valid = (parseNumber(_controller.text) ?? 0) > 0;

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
              Row(
                children: [
                  Expanded(child: Text('Weigh-in', style: GtText.title)),
                  Pressable(
                    onTap: () async {
                      final picked = await pickDay(context, ref, selected: _day);
                      if (picked != null && mounted) {
                        setState(() {
                          _day = picked;
                          _controller.text = _initialText(picked);
                        });
                      }
                    },
                    haptic: PressHaptic.selection,
                    child: Row(
                      children: [
                        Text(Fmt.sheetDate(_day, today), style: GtText.label.colored(GtColors.text2)),
                        const SizedBox(width: 4),
                        const Icon(GtIcons.chevronDown, size: 12, color: GtColors.text2),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GtSpace.xxl),
              Row(
                children: [
                  _StepButton(label: '−', onTap: () => _step(-0.1)),
                  // The field hugs its text so number and unit stay centred together.
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        IntrinsicWidth(
                          child: TextField(
                            controller: _controller,
                            autofocus: existing == null,
                            onChanged: (_) => setState(() {}),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: decimalInput,
                            textAlign: TextAlign.center,
                            style: GtText.figure.sized(48),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: previous == null
                                  ? '0.0'
                                  : Units.format(previous.weightKg, unit, withUnit: false, maxDecimals: 1),
                              hintStyle: GtText.figure.sized(48).colored(GtColors.text3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(unit.name, style: GtText.label.sized(16).colored(GtColors.text2)),
                      ],
                    ),
                  ),
                  _StepButton(label: '+', onTap: () => _step(0.1)),
                ],
              ),
              if (previous != null) ...[
                const SizedBox(height: GtSpace.sm),
                Text(
                  'Previous: ${Units.format(previous.weightKg, unit, maxDecimals: 1)} on ${Fmt.dayMonth(previous.dayKey)}',
                  textAlign: TextAlign.center,
                  style: GtText.caption,
                ),
              ],
              const SizedBox(height: GtSpace.xxl),
              GtButton(label: 'Save', onTap: valid ? _save : null, expand: true, haptic: PressHaptic.none),
              if (existing != null) ...[
                const SizedBox(height: GtSpace.sm),
                GtButton(
                  label: 'Remove this weigh-in',
                  kind: GtButtonKind.ghost,
                  expand: true,
                  onTap: () {
                    Haptics.heavy();
                    ref.read(bodyWeightRepoProvider).remove(_day);
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: PressHaptic.none,
      scale: 0.88,
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: ShapeDecoration(color: GtColors.s2, shape: squircle(26)),
        child: Text(label, style: GtText.title.colored(GtColors.text1)),
      ),
    );
  }
}
