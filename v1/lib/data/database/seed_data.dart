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

/// Common exercises: (name, group slug, kind, exercise guide id).
const seedExercises = <(String, String, ExerciseKind, String?)>[
  ('Bench Press', 'chest', ExerciseKind.strength, 'Barbell_Bench_Press_-_Medium_Grip'),
  ('Incline Bench Press', 'chest', ExerciseKind.strength, 'Barbell_Incline_Bench_Press_-_Medium_Grip'),
  ('Dumbbell Bench Press', 'chest', ExerciseKind.strength, 'Dumbbell_Bench_Press'),
  ('Incline Dumbbell Press', 'chest', ExerciseKind.strength, 'Incline_Dumbbell_Press'),
  ('Chest Fly', 'chest', ExerciseKind.strength, 'Dumbbell_Flyes'),
  ('Cable Crossover', 'chest', ExerciseKind.strength, 'Cable_Crossover'),
  ('Pec Deck', 'chest', ExerciseKind.strength, 'Butterfly'),
  ('Push-up', 'chest', ExerciseKind.bodyweight, 'Pushups'),
  ('Chest Dip', 'chest', ExerciseKind.bodyweight, 'Dips_-_Chest_Version'),
  ('Deadlift', 'back', ExerciseKind.strength, 'Barbell_Deadlift'),
  ('Pull-up', 'back', ExerciseKind.bodyweight, 'Pullups'),
  ('Chin-up', 'back', ExerciseKind.bodyweight, 'Chin-Up'),
  ('Lat Pulldown', 'back', ExerciseKind.strength, 'Wide-Grip_Lat_Pulldown'),
  ('Barbell Row', 'back', ExerciseKind.strength, 'Bent_Over_Barbell_Row'),
  ('Dumbbell Row', 'back', ExerciseKind.strength, 'One-Arm_Dumbbell_Row'),
  ('Seated Cable Row', 'back', ExerciseKind.strength, 'Seated_Cable_Rows'),
  ('T-Bar Row', 'back', ExerciseKind.strength, 'T-Bar_Row_with_Handle'),
  ('Back Extension', 'back', ExerciseKind.bodyweight, 'Hyperextensions_Back_Extensions'),
  ('Overhead Press', 'shoulders', ExerciseKind.strength, 'Standing_Military_Press'),
  ('Dumbbell Shoulder Press', 'shoulders', ExerciseKind.strength, 'Dumbbell_Shoulder_Press'),
  ('Lateral Raise', 'shoulders', ExerciseKind.strength, 'Side_Lateral_Raise'),
  ('Front Raise', 'shoulders', ExerciseKind.strength, 'Front_Dumbbell_Raise'),
  ('Rear Delt Fly', 'shoulders', ExerciseKind.strength, 'Reverse_Flyes'),
  ('Face Pull', 'shoulders', ExerciseKind.strength, 'Face_Pull'),
  ('Arnold Press', 'shoulders', ExerciseKind.strength, 'Arnold_Dumbbell_Press'),
  ('Barbell Curl', 'biceps', ExerciseKind.strength, 'Barbell_Curl'),
  ('Dumbbell Curl', 'biceps', ExerciseKind.strength, 'Dumbbell_Bicep_Curl'),
  ('Hammer Curl', 'biceps', ExerciseKind.strength, 'Hammer_Curls'),
  ('Preacher Curl', 'biceps', ExerciseKind.strength, 'Preacher_Curl'),
  ('Cable Curl', 'biceps', ExerciseKind.strength, 'Standing_Biceps_Cable_Curl'),
  ('Incline Dumbbell Curl', 'biceps', ExerciseKind.strength, 'Incline_Dumbbell_Curl'),
  ('Tricep Pushdown', 'triceps', ExerciseKind.strength, 'Triceps_Pushdown'),
  ('Overhead Tricep Extension', 'triceps', ExerciseKind.strength, 'Standing_Dumbbell_Triceps_Extension'),
  ('Skull Crusher', 'triceps', ExerciseKind.strength, 'EZ-Bar_Skullcrusher'),
  ('Close-Grip Bench Press', 'triceps', ExerciseKind.strength, 'Close-Grip_Barbell_Bench_Press'),
  ('Tricep Dip', 'triceps', ExerciseKind.bodyweight, 'Dips_-_Triceps_Version'),
  ('Tricep Kickback', 'triceps', ExerciseKind.strength, 'Tricep_Dumbbell_Kickback'),
  ('Squat', 'legs', ExerciseKind.strength, 'Barbell_Squat'),
  ('Front Squat', 'legs', ExerciseKind.strength, 'Front_Barbell_Squat'),
  ('Leg Press', 'legs', ExerciseKind.strength, 'Leg_Press'),
  ('Romanian Deadlift', 'legs', ExerciseKind.strength, 'Romanian_Deadlift'),
  ('Leg Extension', 'legs', ExerciseKind.strength, 'Leg_Extensions'),
  ('Leg Curl', 'legs', ExerciseKind.strength, 'Lying_Leg_Curls'),
  ('Walking Lunge', 'legs', ExerciseKind.strength, 'Bodyweight_Walking_Lunge'),
  ('Bulgarian Split Squat', 'legs', ExerciseKind.strength, 'Split_Squat_with_Dumbbells'),
  ('Hack Squat', 'legs', ExerciseKind.strength, 'Hack_Squat'),
  ('Goblet Squat', 'legs', ExerciseKind.strength, 'Goblet_Squat'),
  ('Hip Thrust', 'glutes', ExerciseKind.strength, 'Barbell_Hip_Thrust'),
  ('Glute Bridge', 'glutes', ExerciseKind.strength, 'Barbell_Glute_Bridge'),
  ('Cable Kickback', 'glutes', ExerciseKind.strength, 'One-Legged_Cable_Kickback'),
  ('Hip Abduction', 'glutes', ExerciseKind.strength, 'Thigh_Abductor'),
  ('Plank', 'core', ExerciseKind.timed, 'Plank'),
  ('Crunch', 'core', ExerciseKind.bodyweight, 'Crunches'),
  ('Hanging Leg Raise', 'core', ExerciseKind.bodyweight, 'Hanging_Leg_Raise'),
  ('Cable Crunch', 'core', ExerciseKind.strength, 'Cable_Crunch'),
  ('Russian Twist', 'core', ExerciseKind.bodyweight, 'Russian_Twist'),
  ('Ab Wheel Rollout', 'core', ExerciseKind.bodyweight, 'Ab_Roller'),
  ('Treadmill', 'cardio', ExerciseKind.cardio, 'Running_Treadmill'),
  ('Cycling', 'cardio', ExerciseKind.cardio, 'Bicycling_Stationary'),
  ('Rowing Machine', 'cardio', ExerciseKind.cardio, 'Rowing_Stationary'),
  ('Elliptical', 'cardio', ExerciseKind.cardio, 'Elliptical_Trainer'),
  ('Stair Climber', 'cardio', ExerciseKind.cardio, 'Stairmaster'),
  ('Jump Rope', 'cardio', ExerciseKind.timed, 'Rope_Jumping'),
  ('Wrist Curl', 'forearms', ExerciseKind.strength, 'Palms-Up_Barbell_Wrist_Curl_Over_A_Bench'),
  ("Farmer's Carry", 'forearms', ExerciseKind.strength, 'Farmers_Walk'),
  ('Standing Calf Raise', 'calves', ExerciseKind.strength, 'Standing_Calf_Raises'),
  ('Seated Calf Raise', 'calves', ExerciseKind.strength, 'Seated_Calf_Raise'),
  ('Barbell Shrug', 'traps', ExerciseKind.strength, 'Barbell_Shrug'),
  ('Dumbbell Shrug', 'traps', ExerciseKind.strength, 'Dumbbell_Shrug'),
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
    for (final (name, slug, kind, guideId) in seedExercises) {
      b.insert(
        db.exercises,
        ExercisesCompanion.insert(name: name, groupId: Value(idBySlug[slug]), kind: kind, guideId: Value(guideId)),
      );
    }
  });
}
