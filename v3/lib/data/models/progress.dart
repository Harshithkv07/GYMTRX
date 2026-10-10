import 'package:flutter/foundation.dart';

import '../database/app_database.dart';

/// One logged set plus the context personal-record detection needs. Rows
/// come in logging order: day, then exercise position, then set position.
typedef SetRecordRow = ({
  int setId,
  int exerciseId,
  ExerciseKind kind,
  int dayKey,
  int entryId,
  int entryPos,
  int setPos,
  double? weightKg,
  int? reps,
  int? durationSec,
  double? distanceKm,
});

/// A training day in the weekly program.
@immutable
class ProgramDayPlan {
  const ProgramDayPlan({
    required this.weekday,
    required this.label,
    this.groupIds = const [],
    this.exerciseIds = const [],
  });

  /// ISO weekday, 1 = Monday … 7 = Sunday.
  final int weekday;
  final String label;
  final List<int> groupIds;
  final List<int> exerciseIds;
}
