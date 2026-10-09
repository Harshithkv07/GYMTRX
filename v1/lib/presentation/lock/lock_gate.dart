import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/services/lock_service.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/brand_mark.dart';
import '../widgets/gt_button.dart';

/// Whether the app is currently locked. Deep links wait for this to clear.
class LockStateNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(settingsProvider).lockEnabled;

  void lock() => state = true;

  void unlock() => state = false;
}

final lockStateProvider = NotifierProvider<LockStateNotifier, bool>(LockStateNotifier.new);

/// Sits above the navigator. When app lock is on, covers everything until
/// the user authenticates, and relocks after the chosen time in background.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate> {
  late final AppLifecycleListener _lifecycle;
  DateTime? _hiddenAt;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    final enabled = ref.read(settingsProvider).lockEnabled;
    LockService.setRecentsHidden(enabled);
    if (enabled) WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    _lifecycle = AppLifecycleListener(
      onHide: () => _hiddenAt = DateTime.now(),
      onShow: _onShow,
    );
  }

  void _onShow() {
    final settings = ref.read(settingsProvider);
    final hiddenAt = _hiddenAt;
    _hiddenAt = null;
    if (!settings.lockEnabled || hiddenAt == null || _authenticating) return;
    if (DateTime.now().difference(hiddenAt).inSeconds >= settings.lockAfterSec) {
      ref.read(lockStateProvider.notifier).lock();
      _unlock();
    }
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    _authenticating = true;
    final ok = await LockService.authenticate();
    _authenticating = false;
    // The system prompt hides the app briefly; that must not count as leaving.
    _hiddenAt = null;
    if (ok) ref.read(lockStateProvider.notifier).unlock();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsProvider.select((s) => s.lockEnabled), (_, enabled) => LockService.setRecentsHidden(enabled));
    final locked = ref.watch(lockStateProvider);
    return Stack(
      children: [
        // Nothing underneath is reachable (or readable by TalkBack) while locked.
        ExcludeSemantics(excluding: locked, child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !locked,
            child: AnimatedOpacity(
              duration: GtMotion.of(context, GtMotion.slow),
              curve: GtMotion.emphasized,
              opacity: locked ? 1 : 0,
              child: _LockScreen(onUnlock: _unlock),
            ),
          ),
        ),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GtColors.bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GtSpace.xxl),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const BrandMark(size: 72),
              const SizedBox(height: GtSpace.xl),
              Text('GYMTRX', style: GtText.overline.sized(13).colored(GtColors.text1)),
              const SizedBox(height: GtSpace.sm),
              Text('Locked', style: GtText.body.colored(GtColors.text2)),
              const Spacer(flex: 4),
              GtButton(label: 'Unlock', icon: GtIcons.fingerprint, onTap: onUnlock, expand: true),
            ],
          ),
        ),
      ),
    );
  }
}
