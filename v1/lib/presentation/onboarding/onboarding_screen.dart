import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/icons.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../logic/features.dart';
import '../../logic/providers/settings_provider.dart';
import '../health/health_connect_flow.dart';
import '../settings/drive_actions.dart';
import '../widgets/gt_button.dart';
import '../widgets/pressable.dart';
import '../widgets/surface.dart';
import 'feature_catalog.dart';
import 'feature_checklist.dart';
import 'feature_setup.dart';
import 'intro_carousel.dart';

enum _Step { welcome, preset, checklist, reminders, health, drive, summary }

/// First launch: what GYMTRX can do, which parts this person wants, and the
/// few permissions those parts need, each explained before Android asks.
/// Everything chosen here can be changed later in Settings → Features.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  var _step = _Step.welcome;
  var _forward = true;
  FeaturePreset? _preset;
  var _selected = <AppFeature>{};
  final _done = <_Step>{};

  /// The intro slide last shown, so Back from the setup returns to it.
  var _introPage = 0;

  List<_Step> get _steps => [
    _Step.welcome,
    _Step.preset,
    _Step.checklist,
    if (_selected.contains(AppFeature.reminders)) _Step.reminders,
    if (_selected.contains(AppFeature.health)) _Step.health,
    if (_selected.contains(AppFeature.drive)) _Step.drive,
    _Step.summary,
  ];

  void _go(_Step step, {bool forward = true}) => setState(() {
    _forward = forward;
    _step = step;
  });

  void _next() {
    if (_step == _Step.checklist) ref.read(settingsProvider.notifier).setFeatures(_selected);
    final steps = _steps;
    _go(steps[steps.indexOf(_step) + 1]);
  }

  void _back() {
    final steps = _steps;
    final i = steps.indexOf(_step);
    if (i > 0) _go(steps[i - 1], forward: false);
  }

  void _finish() {
    final notifier = ref.read(settingsProvider.notifier);
    notifier.setFeatures(_selected);
    notifier.completeOnboarding();
  }

  Future<void> _restore() async {
    // A restore brings back the features chosen on the old phone too.
    if (await restoreFromDrive(context, ref)) ref.read(settingsProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final steps = _steps;
    final index = steps.indexOf(_step);

    final page = switch (_step) {
      _Step.welcome => IntroCarousel(
        initialPage: _introPage,
        onPageChanged: (p) => _introPage = p,
        onStart: () => _go(_Step.preset),
        onRestore: driveConfigured ? _restore : null,
      ),
      _Step.preset => _PresetPage(
        selected: _preset,
        onPick: (p) => setState(() {
          _preset = p;
          _selected = {...p.features};
        }),
      ),
      _Step.checklist => _ChecklistPage(
        selected: _selected,
        onChanged: (f, on) => setState(() => on ? _selected.add(f) : _selected.remove(f)),
      ),
      _Step.reminders => _SetupPage(
        icon: GtIcons.bell,
        title: 'Reminders',
        body:
            'A short note when it’s been a few days, at most three times, then quiet. '
            '${_selected.contains(AppFeature.streak) ? 'Also a heads-up when a week is short of your goal. ' : ''}'
            'Android will ask you to allow notifications.',
        action: 'Turn on reminders',
        done: _done.contains(_Step.reminders),
        doneText: 'Reminders are on. Pick the time in Settings → Reminders.',
        onAction: () async {
          if (await enableReminders(ref)) setState(() => _done.add(_Step.reminders));
        },
      ),
      _Step.health => _SetupPage(
        icon: GtIcons.health,
        title: 'Health Connect',
        body:
            'Health Connect is Android’s shared health store. GYMTRX can read your steps from it, '
            'and if you wear a watch, your heart rate, calories and sleep. You choose next.',
        action: 'Connect',
        done: _done.contains(_Step.health),
        doneText: 'Connected. You can change what’s shared in Settings → Health Connect.',
        onAction: () async {
          if (await openHealthConnectFlow(context)) setState(() => _done.add(_Step.health));
        },
      ),
      _Step.drive => _SetupPage(
        icon: GtIcons.google,
        title: 'Google Drive backup',
        body: driveConfigured
            ? 'Sign in with your Google account. GYMTRX keeps its backups in a hidden folder of your own Drive '
                  'that only GYMTRX can see, and backs up by itself about once a day.'
            : 'Drive backup isn’t set up in this copy of GYMTRX yet. You can still export backups from Settings.',
        action: 'Sign in with Google',
        done: _done.contains(_Step.drive),
        doneText: 'Signed in. Backups happen by themselves; see Settings → Your data.',
        onAction: driveConfigured
            ? () async {
                if (await signInToDrive(context, ref, explain: false)) setState(() => _done.add(_Step.drive));
              }
            : null,
      ),
      _Step.summary => _SummaryPage(selected: _selected),
    };

    final showBar = _step != _Step.welcome;
    final canNext = switch (_step) {
      _Step.preset => _preset != null,
      _ => true,
    };
    final isSetup = const {_Step.reminders, _Step.health, _Step.drive}.contains(_step);

    return Scaffold(
      backgroundColor: GtColors.bg,
      body: Column(
        children: [
          SizedBox(height: padding.top),
          if (showBar) _Dots(count: steps.length - 1, index: index - 1, onBack: _back),
          Expanded(
            child: PageTransitionSwitcher(
              duration: GtMotion.of(context, const Duration(milliseconds: 420)),
              reverse: !_forward,
              transitionBuilder: (child, primary, secondary) => SharedAxisTransition(
                animation: primary,
                secondaryAnimation: secondary,
                transitionType: SharedAxisTransitionType.horizontal,
                fillColor: GtColors.bg,
                child: child,
              ),
              child: KeyedSubtree(key: ValueKey(_step), child: page),
            ),
          ),
          if (showBar)
            Padding(
              padding: EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.md, GtSpace.gutter, padding.bottom + GtSpace.lg),
              child: _step == _Step.summary
                  ? GtButton(label: 'Start logging', expand: true, haptic: PressHaptic.medium, onTap: _finish)
                  : GtButton(
                      label: isSetup && !_done.contains(_step) ? 'Skip for now' : 'Next',
                      kind: isSetup && !_done.contains(_step) ? GtButtonKind.secondary : GtButtonKind.primary,
                      expand: true,
                      onTap: canNext ? _next : null,
                    ),
            ),
        ],
      ),
    );
  }
}

/// Progress through the steps, with a back arrow.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index, required this.onBack});

  final int count;
  final int index;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final duration = GtMotion.of(context, GtMotion.medium);
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: GtSpace.md),
          GtIconButton(icon: GtIcons.back, onTap: onBack, semanticLabel: 'Back'),
          const Spacer(),
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: duration,
              curve: GtMotion.emphasized,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == index ? 20 : 6,
              height: 6,
              decoration: ShapeDecoration(
                color: i <= index ? context.accent : GtColors.s3,
                shape: const StadiumBorder(),
              ),
            ),
          const Spacer(),
          const SizedBox(width: 44 + GtSpace.md),
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle(this.title, this.caption);

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.gutter, GtSpace.sm, GtSpace.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GtText.headline),
          const SizedBox(height: GtSpace.sm),
          Text(caption, style: GtText.body.colored(GtColors.text2)),
        ],
      ),
    );
  }
}

class _PresetPage extends StatelessWidget {
  const _PresetPage({required this.selected, required this.onPick});

  final FeaturePreset? selected;
  final ValueChanged<FeaturePreset> onPick;

  static const _copy = {
    FeaturePreset.justLog: (GtIcons.calendar, 'Just log my workouts', 'The calendar and quick logging. Nothing else.'),
    FeaturePreset.track: (
      GtIcons.insights,
      'Log and track progress',
      'Adds body weight, photos, insights, records and logging shortcuts.',
    ),
    FeaturePreset.everything: (
      GtIcons.sparkle,
      'Everything',
      'Also streaks, goals, a weekly program, reminders, the exercise guide, Health Connect and Drive backup.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: GtSpace.lg),
      children: [
        const _PageTitle('How will you use GYMTRX?', 'Pick a starting point. You can fine-tune it on the next screen.'),
        const SizedBox(height: GtSpace.xl),
        for (final p in FeaturePreset.values)
          Padding(
            padding: const EdgeInsets.fromLTRB(GtSpace.lg, 0, GtSpace.lg, GtSpace.md),
            child: _PresetCard(
              icon: _copy[p]!.$1,
              title: _copy[p]!.$2,
              line: _copy[p]!.$3,
              selected: selected == p,
              onTap: () => onPick(p),
            ),
          ),
      ],
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
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
                  const SizedBox(height: 3),
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

class _ChecklistPage extends StatelessWidget {
  const _ChecklistPage({required this.selected, required this.onChanged});

  final Set<AppFeature> selected;
  final void Function(AppFeature, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: GtSpace.lg),
      children: [
        const _PageTitle('Fine-tune it', 'Only what’s ticked shows up. Change any of it later in Settings → Features.'),
        FeatureChecklist(selected: selected, onChanged: onChanged),
      ],
    );
  }
}

/// One feature that needs a permission or a sign-in, explained first.
class _SetupPage extends StatelessWidget {
  const _SetupPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.done,
    required this.doneText,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String action;
  final bool done;
  final String doneText;
  final VoidCallback? onAction;

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
        const SizedBox(height: GtSpace.x3),
        AnimatedSwitcher(
          duration: GtMotion.of(context, GtMotion.medium),
          child: done
              ? Row(
                  key: const ValueKey('done'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(GtIcons.check, size: 18, color: context.accent),
                    const SizedBox(width: GtSpace.md),
                    Expanded(child: Text(doneText, style: GtText.body)),
                  ],
                )
              : Align(
                  key: const ValueKey('todo'),
                  alignment: Alignment.centerLeft,
                  child: GtButton(label: action, onTap: onAction, haptic: PressHaptic.medium),
                ),
        ),
      ],
    );
  }
}

class _SummaryPage extends StatelessWidget {
  const _SummaryPage({required this.selected});

  final Set<AppFeature> selected;

  @override
  Widget build(BuildContext context) {
    final chosen = [
      for (final (_, items) in featureSections)
        for (final i in items)
          if (selected.contains(i.feature)) i,
    ];
    return ListView(
      padding: const EdgeInsets.only(bottom: GtSpace.lg),
      children: [
        _PageTitle(
          'Here’s your GYMTRX',
          chosen.isEmpty
              ? 'Just logging: tap ＋ after a session, pick what you trained, done.'
              : 'Tap ＋ after a session to log it. Here’s where everything else lives.',
        ),
        const SizedBox(height: GtSpace.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg),
          child: GtCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const _SummaryRow(
                  icon: GtIcons.calendar,
                  title: 'Logging',
                  where: 'The ＋ button logs today. Tap any day on the calendar to see or edit it.',
                ),
                for (final i in chosen) ...[
                  const Divider(indent: 56, endIndent: GtSpace.lg),
                  _SummaryRow(icon: i.icon, title: i.title, where: i.where),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(GtSpace.gutter + 4, GtSpace.md, GtSpace.gutter, 0),
          child: Text('Change any of this in Settings → Features.', style: GtText.caption),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.title, required this.where});

  final IconData icon;
  final String title;
  final String where;

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
                Text(where, style: GtText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
