import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/haptics.dart';
import '../../data/services/health_service.dart';
import '../../logic/features.dart';
import '../../logic/providers/health_providers.dart';
import '../../logic/providers/settings_provider.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';

/// Connects Health Connect: asks first whether they wear a watch (no watch
/// means steps only), says exactly what will be read and written, and only
/// then shows Android's permission screen. True when connected.
Future<bool> openHealthConnectFlow(BuildContext context) async {
  final ok = await Navigator.of(
    context,
    rootNavigator: true,
  ).push<bool>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const HealthConnectFlow()));
  return ok ?? false;
}

enum _Step { checking, unavailable, watch, explain, result }

class HealthConnectFlow extends ConsumerStatefulWidget {
  const HealthConnectFlow({super.key});

  @override
  ConsumerState<HealthConnectFlow> createState() => _HealthConnectFlowState();
}

class _HealthConnectFlowState extends ConsumerState<HealthConnectFlow> {
  var _step = _Step.checking;
  var _status = HealthStatus.unavailable;
  bool? _watch;
  Set<String> _granted = const {};
  var _asking = false;

  @override
  void initState() {
    super.initState();
    _watch = ref.read(settingsProvider).healthWatch;
    _check();
  }

  Future<void> _check() async {
    final status = await ref.read(healthServiceProvider).status();
    if (!mounted) return;
    setState(() {
      _status = status;
      _step = status == HealthStatus.available ? _Step.watch : _Step.unavailable;
    });
  }

  List<String> get _wanted => _watch == true ? HealthPermissions.watch : HealthPermissions.noWatch;

  Future<void> _ask() async {
    setState(() => _asking = true);
    Set<String> granted;
    try {
      granted = await ref.read(healthServiceProvider).request(_wanted);
    } on Object {
      granted = await ref.read(healthServiceProvider).granted();
    }
    if (!mounted) return;
    final connected = granted.contains(HealthPermissions.steps) || granted.intersection(_wanted.toSet()).isNotEmpty;
    if (connected) {
      final notifier = ref.read(settingsProvider.notifier)
        ..setHealthConnected(watch: _watch == true)
        ..setFeature(AppFeature.health, true);
      notifier.setHealthHeart(granted.contains(HealthPermissions.heartRate));
      notifier.setHealthSleep(granted.contains(HealthPermissions.sleep));
      notifier.setHealthWeightsIn(granted.contains(HealthPermissions.readWeight));
      notifier.setHealthWrite(granted.contains(HealthPermissions.writeWorkouts));
      Haptics.medium();
      ref.read(healthSyncProvider.notifier).syncAll();
    }
    setState(() {
      _asking = false;
      _granted = granted;
      _step = _Step.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final connected = _granted.isNotEmpty;

    final (Widget body, Widget? action) = switch (_step) {
      _Step.checking => (const Center(child: CircularProgressIndicator()), null),
      _Step.unavailable => (
        _Page(
          icon: GtIcons.health,
          title: _status == HealthStatus.needsUpdate
              ? 'Health Connect needs an update'
              : 'Health Connect isn’t here yet',
          body: _status == HealthStatus.needsUpdate
              ? 'Update Health Connect from the Play Store, then come back and connect.'
              : 'On Android 13 and older, Health Connect is a free app from Google. Install it, then come back and connect.',
        ),
        GtButton(
          label: _status == HealthStatus.needsUpdate ? 'Update Health Connect' : 'Get Health Connect',
          expand: true,
          onTap: () async {
            await ref.read(healthServiceProvider).openInstall();
            if (mounted) setState(() => _step = _Step.checking);
            await Future<void>.delayed(const Duration(seconds: 1));
            await _check();
          },
        ),
      ),
      _Step.watch => (
        ListView(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.lg, GtSpace.gutter, GtSpace.lg),
          children: [
            Text('Do you wear a smartwatch or fitness band?', style: GtText.headline),
            const SizedBox(height: GtSpace.sm),
            Text(
              'Any watch that shares with Health Connect works: Galaxy Watch, Pixel Watch, Fitbit, Mi Band, Amazfit and more.',
              style: GtText.body.colored(GtColors.text2),
            ),
            const SizedBox(height: GtSpace.xxl),
            _Choice(
              icon: GtIcons.watch,
              title: 'Yes, I wear one',
              line:
                  'GYMTRX reads your steps, plus heart rate, calories and sleep from your watch, and can share your sessions and weigh-ins with it.',
              selected: _watch == true,
              onTap: () => setState(() => _watch = true),
            ),
            const SizedBox(height: GtSpace.md),
            _Choice(
              icon: GtIcons.footprints,
              title: 'No',
              line: 'GYMTRX only reads your step count, which your phone records. Nothing else.',
              selected: _watch == false,
              onTap: () => setState(() => _watch = false),
            ),
          ],
        ),
        GtButton(
          label: 'Next',
          expand: true,
          onTap: _watch == null ? null : () => setState(() => _step = _Step.explain),
        ),
      ),
      _Step.explain => (
        ListView(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.lg, GtSpace.gutter, GtSpace.lg),
          children: [
            Text('What GYMTRX will use', style: GtText.headline),
            const SizedBox(height: GtSpace.sm),
            Text(
              'Android will show a screen listing these next. Allow what you’re happy with; anything you skip is simply left out.',
              style: GtText.body.colored(GtColors.text2),
            ),
            const SizedBox(height: GtSpace.xl),
            GtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  const _Use(GtIcons.footprints, 'Steps', 'Read: shown on rest days in your calendar.'),
                  if (_watch == true) ...const [
                    Divider(indent: 56, endIndent: GtSpace.lg),
                    _Use(GtIcons.heart, 'Heart rate', 'Read: average and peak while you trained.'),
                    Divider(indent: 56, endIndent: GtSpace.lg),
                    _Use(GtIcons.flame, 'Active calories', 'Read: what you burned in the session.'),
                    Divider(indent: 56, endIndent: GtSpace.lg),
                    _Use(GtIcons.sleep, 'Sleep', 'Read: how long you slept the night before.'),
                    Divider(indent: 56, endIndent: GtSpace.lg),
                    _Use(
                      GtIcons.exercise,
                      'Exercise',
                      'Read your watch’s workouts to find when you trained; write your sessions as strength training.',
                    ),
                    Divider(indent: 56, endIndent: GtSpace.lg),
                    _Use(GtIcons.weight, 'Weight', 'Read weigh-ins from a smart scale; write the ones you type.'),
                    Divider(indent: 56, endIndent: GtSpace.lg),
                    _Use(
                      GtIcons.time,
                      'Past data',
                      'Read older data too, so sessions from last month get their numbers.',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: GtSpace.lg),
            Text(
              'It all stays on your phone. GYMTRX has no server and never sends health data anywhere.',
              style: GtText.caption,
            ),
          ],
        ),
        GtButton(label: _asking ? 'Waiting for Android…' : 'Continue', expand: true, onTap: _asking ? null : _ask),
      ),
      _Step.result => (
        _Page(
          icon: connected ? GtIcons.check : GtIcons.warning,
          title: connected ? 'Connected' : 'Nothing was allowed',
          body: connected
              ? _watch == true
                    ? 'Your steps show on rest days, and each session gets its heart rate and calories once your watch syncs. '
                          'Change any of it in Settings → Health Connect.'
                    : 'Your steps now show on rest days in the calendar. If you get a watch later, switch it on in Settings → Health Connect.'
              : 'Health Connect stays off. You can try again any time from Settings.',
          extra: connected
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (perm, label) in [
                      (HealthPermissions.steps, 'Steps'),
                      if (_watch == true) ...[
                        (HealthPermissions.heartRate, 'Heart rate'),
                        (HealthPermissions.calories, 'Active calories'),
                        (HealthPermissions.sleep, 'Sleep'),
                        (HealthPermissions.readWorkouts, 'Watch workouts'),
                        (HealthPermissions.readWeight, 'Weigh-ins from other apps'),
                        (HealthPermissions.writeWorkouts, 'Sharing your sessions'),
                      ],
                    ])
                      Padding(
                        padding: const EdgeInsets.only(top: GtSpace.sm),
                        child: Row(
                          children: [
                            Icon(
                              _granted.contains(perm) ? GtIcons.check : GtIcons.close,
                              size: 16,
                              color: _granted.contains(perm) ? context.accent : GtColors.text3,
                            ),
                            const SizedBox(width: GtSpace.md),
                            Text(
                              label,
                              style: GtText.body.colored(_granted.contains(perm) ? GtColors.text1 : GtColors.text3),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              : null,
        ),
        connected
            ? GtButton(label: 'Done', expand: true, onTap: () => Navigator.pop(context, true))
            : GtButton(label: 'Try again', expand: true, onTap: () => setState(() => _step = _Step.explain)),
      ),
    };

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: Column(
        children: [
          SizedBox(height: padding.top),
          SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: GtSpace.md),
                GtIconButton(
                  icon: _step == _Step.explain ? GtIcons.back : GtIcons.close,
                  semanticLabel: _step == _Step.explain ? 'Back' : 'Close',
                  onTap: () => _step == _Step.explain
                      ? setState(() => _step = _Step.watch)
                      : Navigator.pop(context, _step == _Step.result && connected),
                ),
                const SizedBox(width: GtSpace.md),
                Text('Health Connect', style: GtText.titleSmall),
              ],
            ),
          ),
          Expanded(
            child: PageTransitionSwitcher(
              duration: GtMotion.of(context, const Duration(milliseconds: 380)),
              transitionBuilder: (child, primary, secondary) => SharedAxisTransition(
                animation: primary,
                secondaryAnimation: secondary,
                transitionType: SharedAxisTransitionType.horizontal,
                fillColor: GtColors.bg,
                child: child,
              ),
              child: KeyedSubtree(key: ValueKey(_step), child: body),
            ),
          ),
          if (action != null)
            Padding(
              padding: EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.md, GtSpace.gutter, padding.bottom + GtSpace.lg),
              child: action,
            ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.icon, required this.title, required this.body, this.extra});

  final IconData icon;
  final String title;
  final String body;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.x3, GtSpace.gutter, GtSpace.lg),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 64,
            height: 64,
            decoration: ShapeDecoration(color: context.gt.accentMuted, shape: squircle(20)),
            child: Icon(icon, size: 30, color: context.accent),
          ),
        ),
        const SizedBox(height: GtSpace.xxl),
        Text(title, style: GtText.headline),
        const SizedBox(height: GtSpace.md),
        Text(body, style: GtText.body.colored(GtColors.text2)),
        if (extra != null) ...[const SizedBox(height: GtSpace.xl), extra!],
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.title,
    required this.line,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String line;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = GtMotion.of(context, GtMotion.medium);
    return Pressable(
      onTap: onTap,
      haptic: PressHaptic.selection,
      scale: 0.98,
      semanticLabel: '$title. $line${selected ? ', selected' : ''}',
      child: AnimatedContainer(
        duration: duration,
        curve: GtMotion.emphasized,
        padding: const EdgeInsets.all(GtSpace.lg),
        decoration: ShapeDecoration(
          color: selected ? context.gt.accentMuted : GtColors.s1,
          shape: squircle(
            GtRadius.lg,
            side: BorderSide(color: selected ? context.accent : GtColors.hairlineStrong, width: selected ? 1.5 : 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: duration,
              width: 44,
              height: 44,
              decoration: ShapeDecoration(color: selected ? context.accent : GtColors.s2, shape: squircle(14)),
              child: Icon(icon, size: 22, color: selected ? GtColors.onAccent : GtColors.text2),
            ),
            const SizedBox(width: GtSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GtText.titleSmall),
                  const SizedBox(height: 4),
                  Text(line, style: GtText.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Use extends StatelessWidget {
  const _Use(this.icon, this.title, this.line);

  final IconData icon;
  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.accent),
          const SizedBox(width: GtSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GtText.body.weight(600)),
                const SizedBox(height: 2),
                Text(line, style: GtText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
