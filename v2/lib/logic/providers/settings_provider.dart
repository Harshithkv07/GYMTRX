import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/accents.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/units.dart';

/// Overridden in main() with the instance loaded at startup.
final prefsProvider = Provider<SharedPreferencesWithCache>((ref) => throw UnimplementedError());

@immutable
class AppSettings {
  const AppSettings({
    this.accent = GtAccent.volt,
    this.themeMode = ThemeMode.system,
    this.userName = '',
    this.welcomeSeen = false,
    this.unit = WeightUnit.kg,
    this.weekStart = DateTime.monday,
    this.dayStartHour = 4,
    this.haptics = true,
    this.lockEnabled = false,
    this.lockAfterSec = 60,
    this.lastExportAt,
    this.lateNightHintSeen = false,
  });

  final GtAccent accent;

  /// Light, dark or following the phone.
  final ThemeMode themeMode;

  /// What the home screen calls the user ("Hey, …"). Empty means no name.
  final String userName;

  /// The welcome page shows once, on first launch (and once after updating from 1.0).
  final bool welcomeSeen;
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

  AppSettings copyWith({
    GtAccent? accent,
    ThemeMode? themeMode,
    String? userName,
    bool? welcomeSeen,
    WeightUnit? unit,
    int? weekStart,
    int? dayStartHour,
    bool? haptics,
    bool? lockEnabled,
    int? lockAfterSec,
    DateTime? lastExportAt,
    bool? lateNightHintSeen,
  }) => AppSettings(
    accent: accent ?? this.accent,
    themeMode: themeMode ?? this.themeMode,
    userName: userName ?? this.userName,
    welcomeSeen: welcomeSeen ?? this.welcomeSeen,
    unit: unit ?? this.unit,
    weekStart: weekStart ?? this.weekStart,
    dayStartHour: dayStartHour ?? this.dayStartHour,
    haptics: haptics ?? this.haptics,
    lockEnabled: lockEnabled ?? this.lockEnabled,
    lockAfterSec: lockAfterSec ?? this.lockAfterSec,
    lastExportAt: lastExportAt ?? this.lastExportAt,
    lateNightHintSeen: lateNightHintSeen ?? this.lateNightHintSeen,
  );
}

ThemeMode _themeModeFrom(String? name) =>
    ThemeMode.values.firstWhere((m) => m.name == name, orElse: () => ThemeMode.system);

class SettingsNotifier extends Notifier<AppSettings> {
  SharedPreferencesWithCache get _prefs => ref.read(prefsProvider);

  @override
  AppSettings build() {
    final p = _prefs;
    final exportMs = p.getInt('lastExportAt');
    final s = AppSettings(
      accent: GtAccent.fromName(p.getString('accent')),
      themeMode: _themeModeFrom(p.getString('themeMode')),
      userName: p.getString('userName') ?? '',
      welcomeSeen: p.getBool('welcomeSeen') ?? false,
      unit: WeightUnit.fromName(p.getString('unit')),
      weekStart: p.getInt('weekStart') ?? DateTime.monday,
      dayStartHour: p.getInt('dayStartHour') ?? 4,
      haptics: p.getBool('haptics') ?? true,
      lockEnabled: p.getBool('lockEnabled') ?? false,
      lockAfterSec: p.getInt('lockAfterSec') ?? 60,
      lastExportAt: exportMs == null ? null : DateTime.fromMillisecondsSinceEpoch(exportMs),
      lateNightHintSeen: p.getBool('lateNightHintSeen') ?? false,
    );
    Haptics.enabled = s.haptics;
    return s;
  }

  void setAccent(GtAccent v) {
    _prefs.setString('accent', v.name);
    state = state.copyWith(accent: v);
  }

  void setThemeMode(ThemeMode v) {
    _prefs.setString('themeMode', v.name);
    state = state.copyWith(themeMode: v);
  }

  void setUserName(String v) {
    final name = v.trim();
    _prefs.setString('userName', name);
    state = state.copyWith(userName: name);
  }

  void markWelcomeSeen() {
    _prefs.setBool('welcomeSeen', true);
    state = state.copyWith(welcomeSeen: true);
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

  /// Applies settings restored from a backup file. Backups from 1.0 simply
  /// lack the newer keys.
  void restore(Map<String, Object?> json) {
    final p = _prefs;
    if (json['accent'] case final String v) p.setString('accent', v);
    if (json['themeMode'] case final String v) p.setString('themeMode', v);
    if (json['userName'] case final String v) p.setString('userName', v);
    if (json['unit'] case final String v) p.setString('unit', v);
    if (json['weekStart'] case final int v) p.setInt('weekStart', v);
    if (json['dayStartHour'] case final int v) p.setInt('dayStartHour', v);
    if (json['haptics'] case final bool v) p.setBool('haptics', v);
    ref.invalidateSelf();
  }

  Map<String, Object?> toJson() => {
    'accent': state.accent.name,
    'themeMode': state.themeMode.name,
    'userName': state.userName,
    'unit': state.unit.name,
    'weekStart': state.weekStart,
    'dayStartHour': state.dayStartHour,
    'haptics': state.haptics,
  };
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
