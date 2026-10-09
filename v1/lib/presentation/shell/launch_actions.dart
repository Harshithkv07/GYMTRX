import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:quick_actions/quick_actions.dart';

import '../lock/lock_gate.dart';
import '../log/log_actions.dart';

/// Opens the log sheet when the app is launched from the home-screen widget's
/// ＋ or the "Log today" app shortcut. Waits for the lock to clear first.
class LaunchActions {
  LaunchActions(this.context, this.ref);

  final BuildContext context;
  final WidgetRef ref;
  StreamSubscription<Uri?>? _clicks;
  bool _pendingLog = false;

  void start() {
    const shortcuts = QuickActions();
    shortcuts
        .initialize((type) {
          if (type == 'log_today') _requestLog();
        })
        .then(
          (_) => shortcuts.setShortcutItems(const [
            ShortcutItem(type: 'log_today', localizedTitle: 'Log today', icon: 'ic_shortcut_add'),
          ]),
        )
        .catchError((Object _) {}); // No launcher (tests): nothing to register.

    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleUri).catchError((_) {});
    _clicks = HomeWidget.widgetClicked.listen(_handleUri, onError: (_) {});
  }

  void _handleUri(Uri? uri) {
    if (uri?.host == 'log') _requestLog();
  }

  void _requestLog() {
    _pendingLog = true;
    flush();
  }

  /// Runs a waiting action once the app is unlocked. Called again by the
  /// shell whenever the lock state changes.
  void flush() {
    if (!_pendingLog || ref.read(lockStateProvider) || !context.mounted) return;
    _pendingLog = false;
    openLogSheet(context, ref, dayKey: logicalToday(ref));
  }

  void dispose() => _clicks?.cancel();
}
