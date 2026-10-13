import '../core/utils/day_key.dart';

/// How a day relates to the weekly program.
enum PlanStatus {
  /// No program, a rest day, or before the program started.
  none,

  /// A training day still to come (or today, not yet logged).
  planned,

  /// A training day with a session.
  done,

  /// A past training day without a session.
  missed,

  /// A training day that fell on a holiday and wasn't logged: never missed.
  holiday,
}

/// Any session counts as done, whatever it trained. Today is never missed:
/// it isn't over yet, and neither is a holiday.
PlanStatus planStatus(
  int day, {
  required Set<int> trainingWeekdays,
  required int? programStart,
  required bool logged,
  required int today,
  bool isHoliday = false,
}) {
  if (programStart == null || day < programStart) return PlanStatus.none;
  if (!trainingWeekdays.contains(DayKeys.weekday(day))) return PlanStatus.none;
  if (logged) return PlanStatus.done;
  if (isHoliday) return PlanStatus.holiday;
  return day < today ? PlanStatus.missed : PlanStatus.planned;
}
