# GYMTRX

A quiet gym logbook for Android. It records which days you trained and what you did, and nothing else: no streaks, goals, reminders or nudges.

- **Quick capture:** ＋ → tap muscle groups (or a "same as before" combo) → Done.
- **Details later:** open the same day again for exercises, optional sets, a note, duration or body weight. Logging before 4 AM counts toward the previous day (change it in Settings).
- **Insights:** neutral counts, a year heatmap, a body map for the last 30 days, muscle-group recency, sessions per month, a body-weight trend and per-exercise history.
- **Extras:** home-screen widget, "Log today" app shortcut, fingerprint/face/PIN app lock, JSON backup export and import.

Everything stays on the phone. The release build has no internet permission.

## Install on your phone

```bash
flutter build apk --release --split-per-abi
```

Then install `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (most phones from the last several years are arm64).

### Use your own signing key first

Android only installs an update over an existing app if both are signed with the same key. Release builds fall back to this computer's debug key, so set up a dedicated key **before** the first install on your phone:

1. Create the key and choose your own password:
   ```bash
   "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore "%USERPROFILE%\gymtrx-release.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias gymtrx
   ```
2. Create `android/key.properties`. It's gitignored, so never commit it.
   ```properties
   storePassword=YOUR_PASSWORD
   keyPassword=YOUR_PASSWORD
   keyAlias=gymtrx
   storeFile=C:/Users/harshithKV/gymtrx-release.jks
   ```
3. Back up `gymtrx-release.jks` and the password somewhere safe. Without them, future versions can't be installed over this one.

If an install ever fails with a signature mismatch: export a backup in Settings, uninstall, install the new APK, then import the backup.

## Develop

```bash
flutter pub get
dart run build_runner build --force-jit   # Drift code generation
flutter analyze
flutter test
```

- Brand assets: `python tool/generate_icons.py`, then `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`. After running flutter_native_splash, re-apply the dark `NormalTheme` in `res/values-v31` and `res/values-night-v31`.
- Body map paths: `python tool/gen_body_map.py <react-native-body-highlighter checkout>` regenerates `lib/presentation/body_map/body_map_data.dart`.

Layout: `lib/core` (theme, motion, utils) · `lib/data` (Drift database, repositories, backup, lock) · `lib/logic` (Riverpod providers, insights maths) · `lib/presentation` (screens and widgets). The home-screen widget is native Jetpack Glance, in `android/app/src/main/kotlin/.../widget/`.

## Credits

Geist and Geist Mono fonts (SIL Open Font License). Body map artwork from react-native-body-highlighter by ELABBASSI Hicham (MIT). Both are listed on the in-app Licences page.
