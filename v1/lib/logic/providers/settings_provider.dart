import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/accents.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/units.dart';
import '../features.dart';

/// Overridden in main() with the instance loaded at startup.
final prefsProvider = Provider<SharedPreferencesWithCache>((ref) => throw UnimplementedError());

@immutable
class AppSettings {
  const AppSettings({
    this.accent = GtAccent.fallback,
    this.unit = WeightUnit.kg,
    this.weekStart = DateTime.monday,
    this.dayStartHour = 4,
    this.haptics = true,
    this.lockEnabled = false,
    this.lockAfterSec = 60,
    this.lastExportAt,
    this.lateNightHintSeen = false,
    this.tourSeen = false,
    this.weeklyGoal = 3,
    this.weeklyGoalLog = const [],
    this.monthlyGoal = 0,
    this.remindInactive = false,
    this.inactiveDays = 3,
    this.remindStreak = false,
    this.streakRemindOffset = 0,
    this.reminderMinutes = 18 * 60,
    this.remindersSince,
    this.programStartDayKey,
    this.streakCelebrated = 0,
    this.features = allFeatures,
    this.onboardingDone = false,
    this.healthConnected = false,
    this.healthWatch,
    this.healthHeart = true,
    this.healthSleep = true,
    this.healthWeightsIn = true,
    this.healthWrite = true,
    this.holidayCalendarIds = const [],
    this.driveAuto = true,
    this.driveAccount,
    this.driveLastBackupAt,
    this.driveLastHash,
    this.driveLastError,
  });

  static const allFeatures = {...AppFeature.values};

  final GtAccent accent;
  final WeightUnit unit;

  /// DateTime.monday or DateTime.sunday.
  final int weekStart;

  /// Entries logged before this hour count toward the previous day.
  final int dayStartHour;
  final bool haptics;
  final bool lockEnabled;

  /// Relock after the app has been in the background this long (0 = immediately).
  final int lockAfterSec;
  final DateTime? lastExportAt;
  final bool lateNightHintSeen;

  /// The home-screen tour has been shown (or skipped) on this phone.
  final bool tourSeen;

  /// Sessions per week that keep the streak going.
  final int weeklyGoal;

  /// Which goal applied from which week on: `(weekStartKey, goal)`, oldest
  /// first. A change only affects the current week onward, so raising the
  /// goal never breaks weeks that were already earned.
  final List<(int, int)> weeklyGoalLog;

  /// Sessions per month; 0 = off.
  final int monthlyGoal;

  final bool remindInactive;

  /// Nudge after this many days without a session.
  final int inactiveDays;
  final bool remindStreak;

  /// The streak-at-risk reminder fires on the last day of the week (0) or the
  /// day before (1).
  final int streakRemindOffset;

  /// Time of day for reminders, minutes since midnight.
  final int reminderMinutes;

  /// Day reminders were first switched on: the inactivity count starts here
  /// when nothing has been logged yet.
  final int? remindersSince;

  /// Missed program days are only counted from this day on; null = no program.
  final int? programStartDayKey;

  /// Highest streak milestone already celebrated.
  final int streakCelebrated;

  /// The optional features this person uses (see [AppFeature]).
  final Set<AppFeature> features;
  bool has(AppFeature f) => features.contains(f);

  /// First-launch onboarding has been completed (or skipped by a restore).
  final bool onboardingDone;

  /// Health Connect was connected through GYMTRX's own flow.
  final bool healthConnected;

  /// Whether they wear a watch or band; null = not asked yet. Without one,
  /// only steps are read.
  final bool? healthWatch;

  /// With a watch: heart rate and calories per session, sleep, weigh-ins from
  /// other apps, and sending workouts and weigh-ins to Health Connect.
  final bool healthHeart;
  final bool healthSleep;
  final bool healthWeightsIn;
  final bool healthWrite;

  /// Phone calendars whose all-day events count as holidays.
  final List<String> holidayCalendarIds;

  /// Google Drive: back up automatically, and how the last one went.
  final bool driveAuto;

  /// The Google account backups go to; null = signed out.
  final String? driveAccount;
  final DateTime? driveLastBackupAt;
  final String? driveLastHash;
  final String? driveLastError;

  /// Health Connect is on and connected.
  bool get healthOn => has(AppFeature.health) && healthConnected;

  /// The watch-only Health Connect parts are in use.
  bool get watchHealth => healthOn && healthWatch == true;

  AppSettings copyWith({
    GtAccent? accent,
    WeightUnit? unit,
    int? weekStart,
    int? dayStartHour,
    bool? haptics,
    bool? lockEnabled,
    int? lockAfterSec,
    DateTime? lastExportAt,
    bool? lateNightHintSeen,
    bool? tourSeen,
    int? weeklyGoal,
    List<(int, int)>? weeklyGoalLog,
    int? monthlyGoal,
    bool? remindInactive,
    int? inactiveDays,
    bool? remindStreak,
    int? streakRemindOffset,
    int? reminderMinutes,
    int? remindersSince,
    Object? programStartDayKey = _keep,
    int? streakCelebrated,
    Set<AppFeature>? features,
    bool? onboardingDone,
    bool? healthConnected,
    Object? healthWatch = _keep,
    bool? healthHeart,
    bool? healthSleep,
    bool? healthWeightsIn,
    bool? healthWrite,
    List<String>? holidayCalendarIds,
    bool? driveAuto,
    Object? driveAccount = _keep,
    DateTime? driveLastBackupAt,
    Object? driveLastHash = _keep,
    Object? driveLastError = _keep,
  }) => AppSettings(
    accent: accent ?? this.accent,
    unit: unit ?? this.unit,
    weekStart: weekStart ?? this.weekStart,
    dayStartHour: dayStartHour ?? this.dayStartHour,
    haptics: haptics ?? this.haptics,
    lockEnabled: lockEnabled ?? this.lockEnabled,
    lockAfterSec: lockAfterSec ?? this.lockAfterSec,
    lastExportAt: lastExportAt ?? this.lastExportAt,
    lateNightHintSeen: lateNightHintSeen ?? this.lateNightHintSeen,
    tourSeen: tourSeen ?? this.tourSeen,
    weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    weeklyGoalLog: weeklyGoalLog ?? this.weeklyGoalLog,
    monthlyGoal: monthlyGoal ?? this.monthlyGoal,
    remindInactive: remindInactive ?? this.remindInactive,
    inactiveDays: inactiveDays ?? this.inactiveDays,
    remindStreak: remindStreak ?? this.remindStreak,
    streakRemindOffset: streakRemindOffset ?? this.streakRemindOffset,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    remindersSince: remindersSince ?? this.remindersSince,
    programStartDayKey: identical(programStartDayKey, _keep) ? this.programStartDayKey : programStartDayKey as int?,
    streakCelebrated: streakCelebrated ?? this.streakCelebrated,
    features: features ?? this.features,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    healthConnected: healthConnected ?? this.healthConnected,
    healthWatch: identical(healthWatch, _keep) ? this.healthWatch : healthWatch as bool?,
    healthHeart: healthHeart ?? this.healthHeart,
    healthSleep: healthSleep ?? this.healthSleep,
    healthWeightsIn: healthWeightsIn ?? this.healthWeightsIn,
    healthWrite: healthWrite ?? this.healthWrite,
    holidayCalendarIds: holidayCalendarIds ?? this.holidayCalendarIds,
    driveAuto: driveAuto ?? this.driveAuto,
    driveAccount: identical(driveAccount, _keep) ? this.driveAccount : driveAccount as String?,
    driveLastBackupAt: driveLastBackupAt ?? this.driveLastBackupAt,
    driveLastHash: identical(driveLastHash, _keep) ? this.driveLastHash : driveLastHash as String?,
    driveLastError: identical(driveLastError, _keep) ? this.driveLastError : driveLastError as String?,
  );
}

/// copyWith sentinel so a nullable field can be cleared back to null.
const _keep = Object();

List<(int, int)> _decodeGoalLog(Object? raw) {
  try {
    final list = raw is String ? jsonDecode(raw) : raw;
    if (list is! List) return const [];
    return [
      for (final e in list)
        if (e case [final int week, final int goal]) (week, goal),
    ];
  } on FormatException {
    return const [];
  }
}

List<List<int>> _goalLogJson(List<(int, int)> log) => [
  for (final (week, goal) in log) [week, goal],
];

class SettingsNotifier extends Notifier<AppSettings> {
  SharedPreferencesWithCache get _prefs => ref.read(prefsProvider);

  @override
  AppSettings build() {
    final p = _prefs;
    final exportMs = p.getInt('lastExportAt');
    final driveMs = p.getInt('driveLastBackupAt');
    final s = AppSettings(
      accent: GtAccent.fromName(p.getString('accent')),
      unit: WeightUnit.fromName(p.getString('unit')),
      weekStart: p.getInt('weekStart') ?? DateTime.monday,
      dayStartHour: p.getInt('dayStartHour') ?? 4,
      haptics: p.getBool('haptics') ?? true,
      lockEnabled: p.getBool('lockEnabled') ?? false,
      lockAfterSec: p.getInt('lockAfterSec') ?? 60,
      lastExportAt: exportMs == null ? null : DateTime.fromMillisecondsSinceEpoch(exportMs),
      lateNightHintSeen: p.getBool('lateNightHintSeen') ?? false,
      tourSeen: p.getBool('tourSeen') ?? false,
      weeklyGoal: p.getInt('weeklyGoal') ?? 3,
      weeklyGoalLog: _decodeGoalLog(p.getString('weeklyGoalLog')),
      monthlyGoal: p.getInt('monthlyGoal') ?? 0,
      remindInactive: p.getBool('remindInactive') ?? false,
      inactiveDays: p.getInt('inactiveDays') ?? 3,
      remindStreak: p.getBool('remindStreak') ?? false,
      streakRemindOffset: p.getInt('streakRemindOffset') ?? 0,
      reminderMinutes: p.getInt('reminderMinutes') ?? 18 * 60,
      remindersSince: p.getInt('remindersSince'),
      programStartDayKey: p.getInt('programStartDayKey'),
      streakCelebrated: p.getInt('streakCelebrated') ?? 0,
      features: AppFeature.decode(p.getString('features')) ?? AppSettings.allFeatures,
      onboardingDone: p.getBool('onboardingDone') ?? false,
      healthConnected: p.getBool('healthConnected') ?? false,
      healthWatch: p.getBool('healthWatch'),
      healthHeart: p.getBool('healthHeart') ?? true,
      healthSleep: p.getBool('healthSleep') ?? true,
      healthWeightsIn: p.getBool('healthWeightsIn') ?? true,
      healthWrite: p.getBool('healthWrite') ?? true,
      holidayCalendarIds: p.getStringList('holidayCalendarIds') ?? const [],
      driveAuto: p.getBool('driveAuto') ?? true,
      driveAccount: p.getString('driveAccount'),
      driveLastBackupAt: driveMs == null ? null : DateTime.fromMillisecondsSinceEpoch(driveMs),
      driveLastHash: p.getString('driveLastHash'),
      driveLastError: p.getString('driveLastError'),
    );
    Haptics.enabled = s.haptics;
    return s;
  }

  void setAccent(GtAccent v) {
    _prefs.setString('accent', v.name);
    state = state.copyWith(accent: v);
  }

  void setUnit(WeightUnit v) {
    _prefs.setString('unit', v.name);
    state = state.copyWith(unit: v);
  }

  void setWeekStart(int v) {
    _prefs.setInt('weekStart', v);
    state = state.copyWith(weekStart: v);
  }

  void setDayStartHour(int v) {
    _prefs.setInt('dayStartHour', v);
    state = state.copyWith(dayStartHour: v);
  }

  void setHaptics(bool v) {
    _prefs.setBool('haptics', v);
    Haptics.enabled = v;
    state = state.copyWith(haptics: v);
  }

  void setLockEnabled(bool v) {
    _prefs.setBool('lockEnabled', v);
    state = state.copyWith(lockEnabled: v);
  }

  void setLockAfter(int seconds) {
    _prefs.setInt('lockAfterSec', seconds);
    state = state.copyWith(lockAfterSec: seconds);
  }

  void markExported(DateTime at) {
    _prefs.setInt('lastExportAt', at.millisecondsSinceEpoch);
    state = state.copyWith(lastExportAt: at);
  }

  void markLateNightHintSeen() {
    _prefs.setBool('lateNightHintSeen', true);
    state = state.copyWith(lateNightHintSeen: true);
  }

  /// False asks for the home-screen tour again.
  void setTourSeen(bool v) {
    _prefs.setBool('tourSeen', v);
    state = state.copyWith(tourSeen: v);
  }

  /// Sets the weekly goal from the week starting [weekStartKey] onward.
  void setWeeklyGoal(int v, {required int weekStartKey}) {
    final log = [
      for (final e in state.weeklyGoalLog)
        if (e.$1 < weekStartKey) e,
      (weekStartKey, v),
    ];
    _prefs.setInt('weeklyGoal', v);
    _prefs.setString('weeklyGoalLog', jsonEncode(_goalLogJson(log)));
    state = state.copyWith(weeklyGoal: v, weeklyGoalLog: log);
  }

  void setMonthlyGoal(int v) {
    _prefs.setInt('monthlyGoal', v);
    state = state.copyWith(monthlyGoal: v);
  }

  void setRemindInactive(bool v, {required int today}) {
    _prefs.setBool('remindInactive', v);
    if (v) _markRemindersSince(today);
    state = state.copyWith(remindInactive: v);
  }

  void setInactiveDays(int v) {
    _prefs.setInt('inactiveDays', v);
    state = state.copyWith(inactiveDays: v);
  }

  void setRemindStreak(bool v, {required int today}) {
    _prefs.setBool('remindStreak', v);
    if (v) _markRemindersSince(today);
    state = state.copyWith(remindStreak: v);
  }

  void setStreakRemindOffset(int v) {
    _prefs.setInt('streakRemindOffset', v);
    state = state.copyWith(streakRemindOffset: v);
  }

  void setReminderMinutes(int v) {
    _prefs.setInt('reminderMinutes', v);
    state = state.copyWith(reminderMinutes: v);
  }

  void _markRemindersSince(int today) {
    if (state.remindersSince != null) return;
    _prefs.setInt('remindersSince', today);
    state = state.copyWith(remindersSince: today);
  }

  void setProgramStart(int? dayKey) {
    if (dayKey == null) {
      _prefs.remove('programStartDayKey');
    } else {
      _prefs.setInt('programStartDayKey', dayKey);
    }
    state = state.copyWith(programStartDayKey: dayKey);
  }

  void markStreakCelebrated(int weeks) {
    _prefs.setInt('streakCelebrated', weeks);
    state = state.copyWith(streakCelebrated: weeks);
  }

  void setFeatures(Set<AppFeature> v) {
    _prefs.setString('features', jsonEncode(AppFeature.encode(v)));
    state = state.copyWith(features: {...v});
  }

  void setFeature(AppFeature f, bool on) => setFeatures(on ? {...state.features, f} : ({...state.features}..remove(f)));

  void completeOnboarding() {
    _prefs.setBool('onboardingDone', true);
    state = state.copyWith(onboardingDone: true);
  }

  /// Saves the watch answer and marks Health Connect as connected.
  void setHealthConnected({required bool watch}) {
    _prefs.setBool('healthConnected', true);
    _prefs.setBool('healthWatch', watch);
    state = state.copyWith(healthConnected: true, healthWatch: watch);
  }

  void disconnectHealth() {
    _prefs.setBool('healthConnected', false);
    state = state.copyWith(healthConnected: false);
  }

  void setHealthHeart(bool v) {
    _prefs.setBool('healthHeart', v);
    state = state.copyWith(healthHeart: v);
  }

  void setHealthSleep(bool v) {
    _prefs.setBool('healthSleep', v);
    state = state.copyWith(healthSleep: v);
  }

  void setHealthWeightsIn(bool v) {
    _prefs.setBool('healthWeightsIn', v);
    state = state.copyWith(healthWeightsIn: v);
  }

  void setHealthWrite(bool v) {
    _prefs.setBool('healthWrite', v);
    state = state.copyWith(healthWrite: v);
  }

  void setHolidayCalendars(List<String> ids) {
    _prefs.setStringList('holidayCalendarIds', ids);
    state = state.copyWith(holidayCalendarIds: [...ids]);
  }

  void setDriveAuto(bool v) {
    _prefs.setBool('driveAuto', v);
    state = state.copyWith(driveAuto: v);
  }

  void setDriveAccount(String? email) {
    if (email == null) {
      _prefs.remove('driveAccount');
      _prefs.remove('driveLastHash');
    } else {
      _prefs.setString('driveAccount', email);
    }
    state = state.copyWith(
      driveAccount: email,
      driveLastError: null,
      driveLastHash: email == null ? null : state.driveLastHash,
    );
  }

  void markDriveBackup(DateTime at, String hash) {
    _prefs.setInt('driveLastBackupAt', at.millisecondsSinceEpoch);
    _prefs.setString('driveLastHash', hash);
    _prefs.remove('driveLastError');
    state = state.copyWith(driveLastBackupAt: at, driveLastHash: hash, driveLastError: null);
  }

  void setDriveError(String? message) {
    if (message == null) {
      _prefs.remove('driveLastError');
    } else {
      _prefs.setString('driveLastError', message);
    }
    state = state.copyWith(driveLastError: message);
  }

  /// The day a photo is being taken for. Kept across the camera hand-off in
  /// case Android kills the app while the camera is open.
  int? get pendingPhotoDay => _prefs.getInt('pendingPhotoDay');

  set pendingPhotoDay(int? dayKey) {
    if (dayKey == null) {
      _prefs.remove('pendingPhotoDay');
    } else {
      _prefs.setInt('pendingPhotoDay', dayKey);
    }
  }

  /// Applies settings restored from a backup file.
  void restore(Map<String, Object?> json) {
    final p = _prefs;
    if (json['accent'] case final String v) p.setString('accent', v);
    if (json['unit'] case final String v) p.setString('unit', v);
    if (json['weekStart'] case final int v) p.setInt('weekStart', v);
    if (json['dayStartHour'] case final int v) p.setInt('dayStartHour', v);
    if (json['haptics'] case final bool v) p.setBool('haptics', v);
    if (json['weeklyGoal'] case final int v) p.setInt('weeklyGoal', v);
    if (json['weeklyGoalLog'] case final List v) {
      p.setString('weeklyGoalLog', jsonEncode(_goalLogJson(_decodeGoalLog(v))));
    }
    if (json['monthlyGoal'] case final int v) p.setInt('monthlyGoal', v);
    if (json['inactiveDays'] case final int v) p.setInt('inactiveDays', v);
    if (json['streakRemindOffset'] case final int v) p.setInt('streakRemindOffset', v);
    if (json['reminderMinutes'] case final int v) p.setInt('reminderMinutes', v);
    if (AppFeature.decode(json['features']) case final features?) {
      p.setString('features', jsonEncode(AppFeature.encode(features)));
    }
    // Older backups don't know about programs: keep the current start then.
    if (json.containsKey('programStartDayKey')) {
      if (json['programStartDayKey'] case final int v) {
        p.setInt('programStartDayKey', v);
      } else {
        p.remove('programStartDayKey');
      }
    }
    ref.invalidateSelf();
  }

  Map<String, Object?> toJson() => {
    'accent': state.accent.name,
    'unit': state.unit.name,
    'weekStart': state.weekStart,
    'dayStartHour': state.dayStartHour,
    'haptics': state.haptics,
    'weeklyGoal': state.weeklyGoal,
    'weeklyGoalLog': _goalLogJson(state.weeklyGoalLog),
    'monthlyGoal': state.monthlyGoal,
    'inactiveDays': state.inactiveDays,
    'streakRemindOffset': state.streakRemindOffset,
    'reminderMinutes': state.reminderMinutes,
    'programStartDayKey': state.programStartDayKey,
    'features': AppFeature.encode(state.features),
  };
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
