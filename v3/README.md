# GYMTRX 3

A gym logbook for Android that keeps you going. Logging is still fast (muscle groups first, everything else optional), and 3.0 adds what helps you show up again: a weekly streak, goals, personal records, a weekly program, reminders and progress photos.

- **Quick capture:** ＋ → tap muscle groups (or a "same as before" combo, or today's program) → Done.
- **Details later:** open the same day again for exercises, optional sets, a note, duration or body weight. Logging before 4 AM counts toward the previous day (change it in Settings).
- **Progress tab:**
  - **Weekly streak:** weeks in a row that hit your weekly session goal. Rest days never break it, and the current week only counts once it's met.
  - **Goals:** a weekly goal (drives the streak), a monthly session goal, lift targets (e.g. Bench Press 90 kg × 5) and a body-weight target.
  - **Records:** a set that beats every earlier set of that exercise (heaviest weight, estimated 1RM, most reps, longest distance or time) gets a gold trophy with a burst the moment you type it.
  - **This week:** your program's days, done or missed.
  - **Photos:** progress photos with side-by-side and slider compare.
- **Weekly program:** plan which weekdays you train and what. Planned days get a dot on the calendar, missed ones turn red, and the log sheet fills a program day in one tap.
- **Reminders:** a nudge after a few days without a session, and a warning near the end of a week that's still short of your goal. Both are optional, at a time you pick.
- **Share:** a day, a record or your streak as an image card.
- **Insights:** counts, a year heatmap, a body map for the last 30 days, muscle-group recency, sessions per month, a body-weight trend with a 7-day average and goal line, and per-exercise history.
- **Extras:** home-screen widget, "Log today" app shortcut, fingerprint/face/PIN app lock.
- **Backups:** one ZIP with your data and photos. Old `.json` backups from 1.0 and 2.0 still import; your photos are kept when you import one.

Everything stays on the phone. The release build has no internet permission. Progress photos are stored inside the app, never in your gallery, and are left out of Android's own cloud backup (use Export backup to keep them).

If reminders don't show up, let GYMTRX run in the background in Android's battery settings; some phones hold back notifications from apps they've put to sleep.

## Install on your phone

3.0 uses the same app id and signing key as 1.0 and 2.0, so it installs over either as an update and upgrades the database in place. Export a backup in the current app first, just in case.

```bash
flutter build apk --release --split-per-abi
```

Then install `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. Its version code is 2003 (Flutter adds 1000 × the ABI index), above 2.0's 2002. Only install the arm64 APK: the armeabi-v7a one would count as a downgrade.

### Signing key

Android only installs an update over an existing app if both are signed with the same key. Release builds read `android/key.properties` (gitignored) and **fail** if it's missing, rather than quietly signing with this computer's debug key. The key and its setup are the same as for 1.0; see the 1.0 README.

If an install ever fails with a signature mismatch: export a backup, uninstall, install the new APK, then import the backup.

## Develop

```bash
flutter pub get
dart run build_runner build --force-jit   # Drift code generation
flutter analyze
flutter test
```

- **Database schema changes:** bump `schemaVersion`, add an `onUpgrade` step, then dump the new version and regenerate the migration test helpers:
  ```bash
  dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
  dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
  ```
  `test/migration_test.dart` checks every upgrade path against those snapshots.
- **Brand assets:** `python tool/generate_icons.py`, then `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`. After running flutter_native_splash, re-apply the dark `NormalTheme` in `res/values-v31` and `res/values-night-v31`.
- **Body map paths:** `python tool/gen_body_map.py <react-native-body-highlighter checkout>` regenerates `lib/presentation/body_map/body_map_data.dart`.
- **Share cards are a trial:** everything lives in `lib/presentation/share/`. To remove them, delete that folder and the few call sites (search for `share/`).

Layout: `lib/core` (theme, motion, utils) · `lib/data` (Drift database, repositories, backup, photos, notifications, lock) · `lib/logic` (Riverpod providers and pure maths: insights, records, streaks, program plan, trends, reminder planning) · `lib/presentation` (screens and widgets). The home-screen widget is native Jetpack Glance, in `android/app/src/main/kotlin/.../widget/`.

## Credits

Geist and Geist Mono fonts (SIL Open Font License). Body map artwork from react-native-body-highlighter by ELABBASSI Hicham (MIT). Both are listed on the in-app Licences page.
