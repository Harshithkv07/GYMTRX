# GYMTRX 2

A quiet gym logbook for Android. It records which days you trained and what you did, and nothing else: no streaks, goals, reminders or nudges.

Version 2 is a full redesign of [1.0](../v1/) with the same features and the same data:

- **Look:** pale sage "mist" backgrounds with a dark version of the same design for night. There are white cards, dark ink pill buttons with lime labels and coral overlines.
- **Dots everywhere:** headlines and big numbers use the dot-matrix font Doto. The body map is drawn as a dot-matrix figure whose trained muscles light up in the accent. Charts are made of dots too.
- **Artwork:** an illustrated welcome page and home header.
- **Layout:**
  - **Home** has a greeting, this week, plain numbers and the latest sessions.
  - **Calendar** and **Insights** work as before.
  - A floating pill nav sits next to a round ＋.

## What it does

- **Quick capture:** ＋ → tap muscle tiles (or a "same as before" combo) → Done.
- **Details later:** open the same day again to add exercises, optional sets, a note, duration or body weight. Logging before 4 AM counts toward the previous day (change it in Settings).
- **Insights:**
  - Neutral counts and a dotted year view.
  - A dot body heat map for the last 30 days, and when each muscle group was last trained.
  - Sessions per month, a body-weight trend and per-exercise history.
- **Extras:**
  - Light, dark or automatic theme, and seven accents.
  - Home-screen widget, "Log today" shortcut and fingerprint/face/PIN app lock.
  - JSON backup export and import. Backups work in both directions between 1.0 and 2.

Everything stays on the phone. The release build has no internet permission.

## Updating from 1.0 keeps your data

2.0 uses the same app id (`com.harshithkv.gymtrx`), database and settings, so it installs over 1.0 like an update. Two things make that work:

1. **The same signing key.** `android/key.properties` (gitignored) points at the existing release keystore. Never create a new one, or Android will refuse the update.
2. **A higher version code.** 1.0 was installed from a per-ABI build, so its version code is 2001 (arm64 adds 2000). Keep building per-ABI. The arm64 APK of build `+2` gets version code 2002, which is higher.

```bash
flutter build apk --release --split-per-abi
```

Install `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. Bump the `+N` build number in `pubspec.yaml` for every release after this.

If an install ever fails with a signature or downgrade error, export a backup in Settings first. Then uninstall, install the new APK and import the backup.

## Develop

```bash
flutter pub get
dart run build_runner build --force-jit   # Drift code generation
flutter analyze
flutter test
```

- Brand assets:
  1. `python tool/generate_icons.py`
  2. `dart run flutter_launcher_icons`
  3. `dart run flutter_native_splash:create`
  4. After running flutter_native_splash, restore the `NormalTheme` window backgrounds in `res/values*/styles.xml` (`@color/gymtrx_background`).
- Body map paths: `python tool/gen_body_map.py <react-native-body-highlighter checkout>` regenerates `lib/presentation/body_map/body_map_data.dart`.
- **Code layout:**
  - `lib/core`: theme tokens (light/dark `GtColors`), type, motion, utils.
  - `lib/data`: Drift database, repositories, backup, lock.
  - `lib/logic`: Riverpod providers, insights maths.
  - `lib/presentation`: screens. `presentation/art` holds the dot-matrix pieces: `DotBody`, `DotText`, dot charts, the illustrated `HeroArt` and the mist background.
- The home-screen widget is native Jetpack Glance, in `android/app/src/main/kotlin/.../widget/`.

## Credits

- Fonts: Geist, Geist Mono and Doto (SIL Open Font License).
- Body map artwork: react-native-body-highlighter by ELABBASSI Hicham (MIT).
- The welcome and home illustrations are original images made for this app with an AI image generator.
- The fonts and body map are listed on the in-app Licences page.
