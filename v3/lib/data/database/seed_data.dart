import 'package:drift/drift.dart';

import 'app_database.dart';

/// Default muscle groups, in chip order: (slug, name, hidden).
/// Forearms, Calves and Traps start hidden and can be shown in Settings.
const seedGroups = <(String, String, bool)>[
  ('chest', 'Chest', false),
  ('back', 'Back', false),
  ('shoulders', 'Shoulders', false),
  ('biceps', 'Biceps', false),
  ('triceps', 'Triceps', false),
  ('legs', 'Legs', false),
  ('glutes', 'Glutes', false),
  ('core', 'Core', false),
  ('cardio', 'Cardio', false),
  ('full_body', 'Full body', false),
  ('forearms', 'Forearms', true),
  ('calves', 'Calves', true),
  ('traps', 'Traps', true),
];

/// Common exercises: (name, group slug, kind).
const seedExercises = <(String, String, ExerciseKind)>[
  ('Bench Press', 'chest', ExerciseKind.strength),
  ('Incline Bench Press', 'chest', ExerciseKind.strength),
  ('Dumbbell Bench Press', 'chest', ExerciseKind.strength),
  ('Incline Dumbbell Press', 'chest', ExerciseKind.strength),
  ('Chest Fly', 'chest', ExerciseKind.strength),
  ('Cable Crossover', 'chest', ExerciseKind.strength),
  ('Pec Deck', 'chest', ExerciseKind.strength),
  ('Push-up', 'chest', ExerciseKind.bodyweight),
  ('Chest Dip', 'chest', ExerciseKind.bodyweight),
  ('Deadlift', 'back', ExerciseKind.strength),
  ('Pull-up', 'back', ExerciseKind.bodyweight),
  ('Chin-up', 'back', ExerciseKind.bodyweight),
  ('Lat Pulldown', 'back', ExerciseKind.strength),
  ('Barbell Row', 'back', ExerciseKind.strength),
  ('Dumbbell Row', 'back', ExerciseKind.strength),
  ('Seated Cable Row', 'back', ExerciseKind.strength),
  ('T-Bar Row', 'back', ExerciseKind.strength),
  ('Back Extension', 'back', ExerciseKind.bodyweight),
  ('Overhead Press', 'shoulders', ExerciseKind.strength),
  ('Dumbbell Shoulder Press', 'shoulders', ExerciseKind.strength),
  ('Lateral Raise', 'shoulders', ExerciseKind.strength),
  ('Front Raise', 'shoulders', ExerciseKind.strength),
  ('Rear Delt Fly', 'shoulders', ExerciseKind.strength),
  ('Face Pull', 'shoulders', ExerciseKind.strength),
  ('Arnold Press', 'shoulders', ExerciseKind.strength),
  ('Barbell Curl', 'biceps', ExerciseKind.strength),
  ('Dumbbell Curl', 'biceps', ExerciseKind.strength),
  ('Hammer Curl', 'biceps', ExerciseKind.strength),
  ('Preacher Curl', 'biceps', ExerciseKind.strength),
  ('Cable Curl', 'biceps', ExerciseKind.strength),
  ('Incline Dumbbell Curl', 'biceps', ExerciseKind.strength),
  ('Tricep Pushdown', 'triceps', ExerciseKind.strength),
  ('Overhead Tricep Extension', 'triceps', ExerciseKind.strength),
  ('Skull Crusher', 'triceps', ExerciseKind.strength),
  ('Close-Grip Bench Press', 'triceps', ExerciseKind.strength),
  ('Tricep Dip', 'triceps', ExerciseKind.bodyweight),
  ('Tricep Kickback', 'triceps', ExerciseKind.strength),
  ('Squat', 'legs', ExerciseKind.strength),
  ('Front Squat', 'legs', ExerciseKind.strength),
  ('Leg Press', 'legs', ExerciseKind.strength),
  ('Romanian Deadlift', 'legs', ExerciseKind.strength),
  ('Leg Extension', 'legs', ExerciseKind.strength),
  ('Leg Curl', 'legs', ExerciseKind.strength),
  ('Walking Lunge', 'legs', ExerciseKind.strength),
  ('Bulgarian Split Squat', 'legs', ExerciseKind.strength),
  ('Hack Squat', 'legs', ExerciseKind.strength),
  ('Goblet Squat', 'legs', ExerciseKind.strength),
  ('Hip Thrust', 'glutes', ExerciseKind.strength),
  ('Glute Bridge', 'glutes', ExerciseKind.strength),
  ('Cable Kickback', 'glutes', ExerciseKind.strength),
  ('Hip Abduction', 'glutes', ExerciseKind.strength),
  ('Plank', 'core', ExerciseKind.timed),
  ('Crunch', 'core', ExerciseKind.bodyweight),
  ('Hanging Leg Raise', 'core', ExerciseKind.bodyweight),
  ('Cable Crunch', 'core', ExerciseKind.strength),
  ('Russian Twist', 'core', ExerciseKind.bodyweight),
  ('Ab Wheel Rollout', 'core', ExerciseKind.bodyweight),
  ('Treadmill', 'cardio', ExerciseKind.cardio),
  ('Cycling', 'cardio', ExerciseKind.cardio),
  ('Rowing Machine', 'cardio', ExerciseKind.cardio),
  ('Elliptical', 'cardio', ExerciseKind.cardio),
  ('Stair Climber', 'cardio', ExerciseKind.cardio),
  ('Jump Rope', 'cardio', ExerciseKind.timed),
  ('Wrist Curl', 'forearms', ExerciseKind.strength),
  ("Farmer's Carry", 'forearms', ExerciseKind.strength),
  ('Standing Calf Raise', 'calves', ExerciseKind.strength),
  ('Seated Calf Raise', 'calves', ExerciseKind.strength),
  ('Barbell Shrug', 'traps', ExerciseKind.strength),
  ('Dumbbell Shrug', 'traps', ExerciseKind.strength),
];

Future<void> seedLibrary(AppDatabase db) async {
  await db.batch((b) {
    for (var i = 0; i < seedGroups.length; i++) {
      final (slug, name, hidden) = seedGroups[i];
      b.insert(
        db.muscleGroups,
        MuscleGroupsCompanion.insert(name: name, slug: Value(slug), sortOrder: Value(i), hidden: Value(hidden)),
      );
    }
  });
  final idBySlug = {for (final g in await db.select(db.muscleGroups).get()) g.slug!: g.id};
  await db.batch((b) {
    for (final (name, slug, kind) in seedExercises) {
      b.insert(db.exercises, ExercisesCompanion.insert(name: name, groupId: Value(idBySlug[slug]), kind: kind));
    }
  });
}
