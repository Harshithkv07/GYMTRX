import 'package:flutter/widgets.dart';

import '../../core/theme/icons.dart';
import '../../logic/features.dart';

/// How a feature is described to people: plain words, no jargon.
@immutable
class FeatureInfo {
  const FeatureInfo(this.feature, this.icon, this.title, this.line, this.where, {this.online = false});

  final AppFeature feature;
  final IconData icon;
  final String title;

  /// One sentence on what it does.
  final String line;

  /// Where to find it once it's on.
  final String where;

  /// Needs the internet to work.
  final bool online;
}

/// Everything optional, grouped the way onboarding and Settings show it.
const featureSections = <(String, List<FeatureInfo>)>[
  (
    'Track',
    [
      FeatureInfo(
        AppFeature.bodyWeight,
        GtIcons.weight,
        'Body weight',
        'Note your weight now and then and see the trend.',
        'Hold ＋ → Add weigh-in. The trend is in Insights.',
      ),
      FeatureInfo(
        AppFeature.photos,
        GtIcons.camera,
        'Progress photos',
        'Private photos kept inside GYMTRX, with a ghost of the last one to line up your pose.',
        'Progress tab → Photos, or hold ＋.',
      ),
      FeatureInfo(
        AppFeature.insights,
        GtIcons.insights,
        'Insights',
        'Your year at a glance, the muscles you’ve trained lately and each exercise’s history.',
        'The Insights tab.',
      ),
    ],
  ),
  (
    'Stay motivated',
    [
      FeatureInfo(
        AppFeature.suggestions,
        GtIcons.lightbulb,
        'Logging shortcuts',
        'One-tap “same as before” and what you lifted last time.',
        'In the log sheet while you log.',
      ),
      FeatureInfo(
        AppFeature.streak,
        GtIcons.flame,
        'Weekly streak',
        'Pick how many sessions a week you aim for. Weeks in a row that hit it build a streak.',
        'Top of the Progress tab. Weekly goal is in Settings.',
      ),
      FeatureInfo(
        AppFeature.records,
        GtIcons.trophy,
        'Personal records',
        'A gold trophy when a set beats your best.',
        'On your sets, and Progress → Records.',
      ),
      FeatureInfo(
        AppFeature.goals,
        GtIcons.target,
        'Goals',
        'Targets like a lift to hit, a body weight to reach or sessions per month.',
        'Progress → Goals.',
      ),
      FeatureInfo(
        AppFeature.program,
        GtIcons.program,
        'Weekly program',
        'Plan which days you train. Missed days turn red; holidays never count.',
        'Settings → Weekly program. Planned days show on the calendar.',
      ),
      FeatureInfo(
        AppFeature.reminders,
        GtIcons.bell,
        'Reminders',
        'A gentle nudge after a few days away, at a time you pick.',
        'Settings → Reminders.',
      ),
    ],
  ),
  (
    'Connect',
    [
      FeatureInfo(
        AppFeature.guide,
        GtIcons.guide,
        'Exercise guide',
        'How to do each exercise, with pictures and the muscles it works.',
        'The guide button next to any exercise.',
        online: true,
      ),
      FeatureInfo(
        AppFeature.health,
        GtIcons.health,
        'Health Connect',
        'Your steps on rest days. With a watch, also heart rate, calories and sleep.',
        'On the calendar and in each day’s details.',
      ),
      FeatureInfo(
        AppFeature.drive,
        GtIcons.cloud,
        'Google Drive backup',
        'Saves a copy to your own Google Drive automatically, so a new phone gets it all back.',
        'Settings → Your data.',
        online: true,
      ),
    ],
  ),
];

FeatureInfo infoOf(AppFeature f) => featureSections.expand((s) => s.$2).firstWhere((i) => i.feature == f);
