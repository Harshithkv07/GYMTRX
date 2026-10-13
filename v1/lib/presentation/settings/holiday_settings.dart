import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../../data/services/holiday_service.dart';
import '../../logic/providers/holiday_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/controls.dart';
import '../widgets/explainer_sheet.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/toast.dart';

/// Picks which phone calendars hold holidays. Explains first, then asks
/// Android for calendar access. Read-only: GYMTRX never changes the calendar.
Future<void> openHolidaySetup(BuildContext context, WidgetRef ref) async {
  final service = ref.read(holidayServiceProvider);
  if (!await service.hasPermission()) {
    if (!context.mounted) return;
    final go = await showExplainerSheet(
      context,
      icon: GtIcons.holiday,
      title: 'Holidays',
      body:
          'GYMTRX can read holidays from a calendar already on your phone, such as Google Calendar’s '
          '“Holidays in India”. Android will ask to let GYMTRX read your calendar next.',
      points: const [
        'A holiday never counts as a missed program day.',
        'Reminders don’t arrive on holidays.',
        'Only the calendars you pick are read, and nothing is ever changed.',
      ],
      action: 'Allow calendar access',
    );
    if (!go) return;
    if (!await service.requestPermission()) {
      Toasts.show('Calendar access is off. You can allow it in Android settings.');
      return;
    }
  }

  final List<PhoneCalendar> calendars;
  try {
    calendars = await service.calendars();
  } on Object {
    Toasts.show('Couldn’t read the calendars on this phone.');
    return;
  }
  if (!context.mounted) return;
  final current = ref.read(settingsProvider).holidayCalendarIds;
  final initial = current.isNotEmpty
      ? current.toSet()
      : {
          for (final c in calendars)
            if (HolidayService.looksLikeHolidays(c)) c.id,
        };

  final picked = await showModalBottomSheet<List<String>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _CalendarPicker(calendars: calendars, initial: initial),
  );
  if (picked == null) return;
  ref.read(settingsProvider.notifier).setHolidayCalendars(picked);
  Haptics.medium();
  Toasts.show(picked.isEmpty ? 'Holidays are off' : 'Holidays will show on the calendar');
}

class _CalendarPicker extends StatefulWidget {
  const _CalendarPicker({required this.calendars, required this.initial});

  final List<PhoneCalendar> calendars;
  final Set<String> initial;

  @override
  State<_CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<_CalendarPicker> {
  late final _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final anyHoliday = widget.calendars.any(HolidayService.looksLikeHolidays);
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, 0, GtSpace.gutter, GtSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: GtSpace.xs),
              Text('Holiday calendars', style: GtText.title),
              const SizedBox(height: GtSpace.sm),
              Text(
                anyHoliday
                    ? 'Tick the calendars whose days are holidays.'
                    : 'None of your calendars look like holidays. In Google Calendar, open Settings → Holidays, add '
                          'your country, then come back. Or tick one below.',
                style: GtText.body.colored(GtColors.text2),
              ),
              const SizedBox(height: GtSpace.md),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final c in widget.calendars)
                      Pressable(
                        onTap: () =>
                            setState(() => _selected.contains(c.id) ? _selected.remove(c.id) : _selected.add(c.id)),
                        haptic: PressHaptic.selection,
                        scale: 0.98,
                        semanticLabel: '${c.name}${_selected.contains(c.id) ? ', selected' : ''}',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: GtSpace.md),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: Color(c.color | 0xFF000000), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: GtSpace.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name.isEmpty ? 'Untitled calendar' : c.name, style: GtText.body),
                                    if (c.account.isNotEmpty && !c.account.contains('#holiday@'))
                                      Text(c.account, style: GtText.caption),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: GtMotion.of(context, GtMotion.medium),
                                width: 24,
                                height: 24,
                                decoration: ShapeDecoration(
                                  color: _selected.contains(c.id) ? context.accent : Colors.transparent,
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      color: _selected.contains(c.id) ? context.accent : GtColors.text3,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                child: _selected.contains(c.id)
                                    ? const Icon(GtIcons.check, size: 13, color: GtColors.onAccent)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: GtSpace.lg),
              GtButton(
                label: _selected.isEmpty ? 'Turn holidays off' : 'Use these calendars',
                expand: true,
                onTap: () => Navigator.pop(context, [
                  for (final c in widget.calendars)
                    if (_selected.contains(c.id)) c.id,
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
