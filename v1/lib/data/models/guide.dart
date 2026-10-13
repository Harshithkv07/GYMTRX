import 'package:flutter/foundation.dart';

/// One exercise from the exercise guide (free-exercise-db, public domain).
@immutable
class GuideExercise {
  const GuideExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.images,
    this.equipment,
    this.level,
    this.force,
    this.mechanic,
  });

  final String id;
  final String name;

  /// strength, stretching, cardio, plyometrics, powerlifting, …
  final String category;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  /// Relative paths like `Barbell_Squat/0.jpg`: start and end position.
  final List<String> images;
  final String? equipment;
  final String? level;
  final String? force;
  final String? mechanic;

  static GuideExercise? fromJson(Map<String, Object?> j) {
    final id = j['id'];
    final name = j['name'];
    if (id is! String || name is! String) return null;
    List<String> strings(Object? v) => [...?(v as List?)?.whereType<String>()];
    return GuideExercise(
      id: id,
      name: name,
      category: j['category'] as String? ?? 'strength',
      primaryMuscles: strings(j['primaryMuscles']),
      secondaryMuscles: strings(j['secondaryMuscles']),
      instructions: strings(j['instructions']),
      images: strings(j['images']),
      equipment: j['equipment'] as String?,
      level: j['level'] as String?,
      force: j['force'] as String?,
      mechanic: j['mechanic'] as String?,
    );
  }
}
