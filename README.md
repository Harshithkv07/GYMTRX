# GYMTRX

A gym logbook for Android. 1.0 and 2.0 are quiet: they record which days you trained and what you did, and nothing else. 3.0 is built from 1.0 and adds the push: streaks, goals, records, reminders, a weekly program and progress photos.

| Folder | Version | What it is |
|---|---|---|
| [`v3/`](v3/) | 3.0.0 | 1.0's dark design plus a Progress tab: weekly streak, goals, personal records, weekly program with missed days, reminders, progress photos and share cards |
| [`v2/`](v2/) | 2.0.0 | Light sage and dark themes, dot-matrix type and body map, illustrated welcome page |
| [`v1/`](v1/) | 1.0.0 | Dark OLED theme, Geist type, volt accent |

Each folder is a complete Flutter project. Build it from inside its folder; see its own README. All three share the app id and signing key, so a newer version installs over an older one as an update and keeps your history (3.0 upgrades the database in place).
