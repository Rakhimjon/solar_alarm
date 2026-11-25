# projectmem - solar_alarm

_Last updated: 2026-11-25_

## Project purpose
A new Flutter project.

## Recent issues
- [DONE] #0002 Migrate Focus Timer and key UI components to iOS Cupertino design style [lib/features/focus_timer/presentation/pages/focus_timer_view.dart] -> Converted Focus Timer and Main Navigation to native iOS Cupertino UI (CupertinoNavigationBar, CupertinoTabBar with frosted glass blur, CupertinoSlidingSegmentedControl, CupertinoSwitch, CupertinoButton, and CupertinoAlertDialog) (fixed)
- [DONE] #0001 Focus timer screen turns dark (no wakelock), lifecycle freezes/abruptly pauses on iOS, and animation needs iOS release optimization [lib/features/focus_timer/] -> Added wakelock_plus to keep screen on while focus timer runs, fixed iOS lifecycle handling with DateTime-based countdown, and removed per-frame allocations in HourglassWidget for smooth 60/120fps iOS release runs (fixed)

## Decisions
- Adopt 'Uyg'otgich' as pure Uzbek name for alarm, replace frustrating math addition mission with interactive Solar Rays Wake-up mission (5 gentle sun taps with morning affirmation)

## Notes
- feat: add bloc state management for solar alarm
- refactor: migrate project structure to DDD clean architecture with feature modules
- feat: add solar clock, focus timer, and planner features with navigation
- feat: add flutter_launcher_icons dependency and configuration
- feat: update application launcher icons for Android and iOS
- feat: add kiosk service and theme management with dark/light support
- feat: implement alarm feature with storage, repository, cubit, and UI views
- feat: add Maestro E2E test suite and math challenge mission to alarms
- feat: add task categories and filtering to planner view
- New feature: feat: migrate focus timer and navigation to iOS Cupertino design and add wakelock support [lib/core/theme/app_theme.dart]

## Key files
- `.gitignore`
- `.metadata`
- `README.md`
- `analysis_options.yaml`
- `android/.gitignore`
- `android/app/build.gradle.kts`
- `android/app/src/debug/AndroidManifest.xml`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/example/solar_alarm/MainActivity.kt`
- `android/app/src/main/res/drawable-v21/launch_background.xml`
- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `android/app/src/main/res/values-night/styles.xml`
- `android/app/src/main/res/values/styles.xml`
- `android/app/src/profile/AndroidManifest.xml`
- `android/build.gradle.kts`

## Open questions
- None logged yet.
