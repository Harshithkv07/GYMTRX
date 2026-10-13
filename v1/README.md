# GYMTRX 1.0

A gym logbook for Android. Logging is fast (muscle groups first, everything else optional), and everything beyond logging is a feature you choose.

## First launch

Four short welcome slides come first (swipe, tap Next, or Skip). Then GYMTRX asks how you'll use it: **Just log my workouts**, **Log and track progress**, or **Everything**. You can then fine-tune a checklist. Anything that needs a permission or a sign-in gets its own short page that explains it before Android asks. Change your choices any time in **Settings → Features**. Turning a feature off only hides it; your data stays.

The first time the home screen opens, a short tour spotlights ＋, the calendar, the tabs and Settings. Replay it from **Settings → Take the tour**.

| Always on | Optional |
|---|---|
| Calendar, quick logging, exercises and sets, notes, backups, widget, app lock | **Track:** body weight, progress photos, insights |
| | **Stay motivated:** logging shortcuts, weekly streak, personal records, goals, weekly program, reminders |
| | **Connect:** exercise guide, Health Connect, Google Drive backup |

## Features

- **Quick capture:** ＋ → tap muscle groups → Done. Open the same day later for exercises, sets, a note, duration or body weight. Logging before 4 AM counts toward the previous day (change it in Settings).
- **Progress tab:** weekly streak, goals, personal records (gold trophy with a burst), this week's program and progress photos. It shows only the parts you turned on.
- **Weekly program:** planned days get a dot on the calendar and missed ones turn red. **Holidays** from a calendar already on your phone (such as Google Calendar's "Holidays in India") never count as missed, and reminders skip them.
- **Progress photos:** taken with GYMTRX's own camera. Tap **Ghost** to show your last photo faintly over the camera so you can match the pose and distance. Compare any two photos side by side or with a slider.
- **Exercise guide:** pictures, the muscles worked and step-by-step instructions for each exercise, plus a "Watch form on YouTube" button. The 69 built-in exercises are already linked; link your own with one tap. **Settings → Library → Exercises → Browse the exercise guide** lets you add any of 800+ exercises.
- **Health Connect:** GYMTRX first asks whether you wear a watch.
  - *No watch:* it reads your step count only, shown on rest days in the calendar.
  - *Watch (any brand that shares with Health Connect):* it also reads heart rate and active calories for each session (from your watch's workout, or the start time you enter), sleep, and weigh-ins from a smart scale. It can write your sessions (as strength training) and your weigh-ins.
- **Google Drive backup:** sign in with Google once. GYMTRX then backs up to a hidden folder in your own Drive, about once a day when you open the app and only if something changed. The last 7 backups are kept. Restore from **Settings**, or from the welcome screen on a new phone.
- **Insights:** counts, a year heatmap, a body map for the last 30 days, muscle-group recency, sessions per month, a body-weight trend and each exercise's history.
- **Reminders:** a nudge after a few days without a session, and a warning near the end of a week that's still short of your goal.
- **Accents:** two packs behind a sliding pill (or swipe the swatches). **Sage:** 12 calm colours, the default. **Neon:** GYMTRX's original Volt, Ice, Ember, Rose, Mint and Lilac.

## What goes online

GYMTRX has no server. The release build has internet permission for exactly two things:

1. **Exercise guide:** the exercise list (about 1 MB, once a month) and pictures (the first time each one is shown) come from [free-exercise-db](https://github.com/yuhonas/free-exercise-db), pinned to a fixed version and served by jsDelivr, with GitHub as a fallback. Nothing is sent except the request itself.
2. **Google Drive backup:** only if you sign in. Backups go to your own Drive's hidden app folder (the `drive.appdata` scope), which GYMTRX can see but nothing else of yours.

Health Connect and the calendar are read on the phone. Health data never leaves it. Progress photos are stored inside the app, never in your gallery. They're left out of Android's own cloud backup (use Drive backup or Export to keep them).

## Install on your phone

This is a fresh start: the build number is back to 2001, below GYMTRX 3.0's 2003, so Android won't install it over 3.0. **Uninstall the old GYMTRX first** (this deletes its data; export a backup first if you want it, since old backups still import).

```bash
flutter build apk --release --split-per-abi
```

Then install `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. Only install the arm64 APK; Flutter numbers the armeabi-v7a one lower (1001).

Android's own backup sometimes puts the old 3.0 log back after a reinstall. GYMTRX upgrades it in place, so that's harmless. For a clean slate, clear GYMTRX's storage once in Android's app settings, before opening it.

### Signing key

Android only installs an update over an existing app if both are signed with the same key. Release builds read `android/key.properties` (gitignored) and **fail** if it's missing, rather than quietly signing with this computer's debug key.

The key is `C:\Users\harshithKV\.gymtrx\gymtrx-release.jks`, alias `gymtrx`. `android/key.properties`:

```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=gymtrx
storeFile=C:/Users/harshithKV/.gymtrx/gymtrx-release.jks
```

Back up the `.jks` file and its password somewhere safe. Without them, future versions can't be installed over this one, and Google Sign-In (which checks the key's fingerprint) stops working.

## Google Drive backup: one-time setup

Google needs to know the app before anyone can sign in. This takes about 15 minutes in the [Google Cloud console](https://console.cloud.google.com), once, by you (not by each person who uses GYMTRX). Until it's done, the Drive rows in Settings say "Not set up yet".

1. Create a project (for example "GYMTRX") and, under **APIs & Services → Library**, enable the **Google Drive API**.
2. **Google Auth Platform → Branding:** app name "GYMTRX", your support email.
3. **Audience:** External. Then **Publish app** (to production). GYMTRX only asks for `drive.appdata`, which Google classes as non-sensitive, so there's no review. In "Testing" mode Google would ask you to sign in again every week.
4. **Data access → Add scopes:** `https://www.googleapis.com/auth/drive.appdata`.
5. **Clients → Create client → Android**, twice, both with package name `com.harshithkv.gymtrx`:
   - one with the **release** key's SHA-1;
   - one with the **debug** key's SHA-1 (for `flutter run`).

   Get both with `cd android` then `./gradlew signingReport`.
6. **Clients → Create client → Web application.** Copy its client ID into `googleWebClientId` in `lib/core/config.dart`. It's not a secret.

Rebuild, then sign in from **Settings → Google Drive**.

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
  `test/migration_test.dart` checks every upgrade path against those snapshots. Keep the old steps: Android's own backup can restore an older database into a new install.
- **Brand assets:** `python tool/generate_icons.py`, then `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`. After running flutter_native_splash, re-apply the dark `NormalTheme` in `res/values-v31` and `res/values-night-v31`, and delete any `res/values-night/` it adds.
- **Body map paths:** `python tool/gen_body_map.py <react-native-body-highlighter checkout>` regenerates `lib/presentation/body_map/body_map_data.dart`.
- **Native code:** Health Connect and the holiday calendar are thin Kotlin bridges in `android/app/src/main/kotlin/.../HealthBridge.kt` and `CalendarBridge.kt`, on the `gymtrx/health` and `gymtrx/calendar` channels. The home-screen widget is Jetpack Glance, in `.../widget/`.

Layout:
- `lib/core`: theme, motion, utils, config.
- `lib/data`: Drift database, repositories, backup, Drive, Health Connect, calendar, guide, photos, notifications, lock.
- `lib/logic`: features, Riverpod providers and pure logic (insights, records, streaks, program plan, trends, reminder planning, watch-workout matching, Drive pruning, guide mapping).
- `lib/presentation`: screens and widgets.

## Credits

- Geist and Geist Mono fonts (SIL Open Font License).
- Body map artwork from react-native-body-highlighter by ELABBASSI Hicham (MIT).
- Exercise guide data and pictures from free-exercise-db by yuhonas (public domain).

All three are listed on the in-app Licences page.
