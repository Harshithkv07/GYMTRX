import 'dart:convert';

/// The optional parts of GYMTRX. Logging (the calendar, the log sheet, entries
/// and backups) is always on; each of these is picked at first launch and can
/// be changed any time in Settings → Features. Turning one off only hides it:
/// its data stays and comes back when it's turned on again.
///
/// Stored by name, so renaming a value forgets it.
enum AppFeature {
  bodyWeight,
  photos,
  insights,
  suggestions,
  streak,
  records,
  goals,
  program,
  reminders,
  guide,
  health,
  drive;

  /// Any of these keeps the Progress tab.
  static const progress = {streak, records, goals, program, photos};

  /// Parses a stored list of names; null when nothing was stored.
  static Set<AppFeature>? decode(Object? raw) {
    try {
      final list = raw is String ? jsonDecode(raw) : raw;
      if (list is! List) return null;
      return {
        for (final name in list)
          for (final f in AppFeature.values)
            if (f.name == name) f,
      };
    } on FormatException {
      return null;
    }
  }

  static List<String> encode(Set<AppFeature> features) => [
    for (final f in AppFeature.values)
      if (features.contains(f)) f.name,
  ];
}

/// The three answers to "How will you use GYMTRX?", each a starting point
/// for the checklist.
enum FeaturePreset {
  justLog({}),
  track({AppFeature.bodyWeight, AppFeature.photos, AppFeature.insights, AppFeature.records, AppFeature.suggestions}),
  everything({...AppFeature.values});

  const FeaturePreset(this.features);

  final Set<AppFeature> features;
}
