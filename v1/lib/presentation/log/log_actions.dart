import 'package:flutter/cupertino.dart' show CupertinoSheetRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/day_key.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/repositories/session_repository.dart';
import '../../logic/providers/settings_provider.dart';
import '../entry/entry_detail_screen.dart';
import '../widgets/toast.dart';
import 'log_sheet.dart';

/// The day ＋ logs to: before the "day starts at" hour it is still yesterday.
int logicalToday(WidgetRef ref) =>
    DayKeys.logicalToday(dayStartHour: ref.read(settingsProvider).dayStartHour);

/// Opens the stacked log sheet for [dayKey]. If that day already has an
/// entry, the sheet edits it (that is how details get added later).
Future<void> openLogSheet(BuildContext context, WidgetRef ref, {required int dayKey}) {
  return Navigator.of(context, rootNavigator: true).push(
    CupertinoSheetRoute<void>(builder: (_) => LogSheet(initialDayKey: dayKey)),
  );
}

Future<void> openEntry(BuildContext context, int dayKey) {
  return Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EntryDetailScreen(dayKey: dayKey)));
}

/// Deletes immediately and offers Undo instead of asking first.
Future<void> deleteEntryWithUndo(SessionRepository repo, int dayKey) async {
  Haptics.heavy();
  final snapshot = await repo.deleteEntry(dayKey);
  if (snapshot == null) return;
  Toasts.show(
    'Deleted ${Fmt.weekdayDayMonth(dayKey)}',
    actionLabel: 'Undo',
    onAction: () {
      Haptics.light();
      repo.restoreEntry(snapshot);
    },
  );
}
