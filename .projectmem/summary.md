# projectmem - solar_alarm

_Last updated: 2026-11-26_

## Project purpose
A new Flutter project.

## Recent issues
- [DONE] #0015 iOS permission_handler notification support is disabled until PERMISSION_NOTIFICATIONS=1 is added to Podfile build definitions [ios/Podfile:39] -> iOS notification permission support enabled and verified with successful debug iOS build [ios/Podfile:41] (fixed)
- [DONE] #0014 permission_handler 13 requires Android compileSdk 37 while project AGP supports 36, breaking debug APK build [pubspec.yaml:26] -> Android debug build restored with permission_handler ^12.0.3 compatible with project compileSdk 36 [pubspec.yaml:26] (fixed)
  - Failed attempt: permission_handler 13.0.2 build failed: Android AAR metadata requires compileSdk 37, project uses 36 [pubspec.yaml:26]
- [DONE] #0013 New Planner widget tests expose AddPlan layout/Material issues and a typed category fallback failure [lib/features/planner/presentation/pages/add_plan_page.dart:155] -> Planner widget flow passes with correct Material/layout/category handling and mobile viewport coverage [test/features/planner/planner_flow_test.dart:80] (fixed)
  - Partial attempt: Fixed ListTile Material, duration overflow and category typing; timed test still missed offscreen save button [lib/features/planner/presentation/pages/add_plan_page.dart:134]
  - Failed attempt: ensureVisible and Scrollable.ensureVisible did not make save button hittable in default 800x600 test viewport [test/features/planner/planner_flow_test.dart:89]
- [DONE] #0012 Custom weekday and segmented controls have sub-44px targets and GestureDetector controls lack button semantics [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:540] -> Custom alarm controls now meet touch-target sizing and expose button/selection semantics [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:540] (fixed)
- [DONE] #0011 Alarm save/delete screens close without awaiting repository operations or showing scheduling failures [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:66] -> Alarm editor handles async completion and scheduling failures instead of closing prematurely [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:69] (fixed)
- [DONE] #0010 No runtime notification or exact-alarm permission check/onboarding exists before scheduling alarms [lib/main.dart:13] -> Runtime alarm permissions and user-facing denial messages added for custom and solar alarms [lib/core/services/alarm_permissions.dart:6] (fixed)
- [DONE] #0009 Planner and focus task selection cannot be cleared because nullable copyWith parameters retain old IDs and titles [lib/features/planner/presentation/cubit/planner_state.dart:40] -> Planner and focus task selections now clear correctly; regression test passes [lib/features/focus_timer/presentation/cubit/focus_timer_cubit.dart:52] (fixed)
- [DONE] #0008 Cancelling solar alarm cannot clear activeAlarmTime because copyWith converts null back to the old value [lib/features/solar_clock/presentation/cubit/solar_clock_state.dart:44] -> Solar alarm cancellation now clears activeAlarmTime; regression test passes [lib/features/solar_clock/presentation/cubit/solar_clock_cubit.dart:69] (fixed)
- [DONE] #0007 White text on amber buttons/chips fails WCAG contrast: 2.15:1 dark theme and 3.19:1 light theme [lib/core/theme/app_theme.dart:26] -> Amber controls now use dark foreground colors instead of low-contrast white text [lib/core/theme/app_theme.dart:26] (fixed)
- [DONE] #0006 Solar-linked alarm editor saves a fixed TimeOfDay; scheduling ignores linkedSolarType and solarOffsetMinutes [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:66] -> Solar-linked alarms schedule resolved event time with offset and preserve location; regression tests pass [lib/features/alarm/data/datasources/alarm_local_storage.dart:16] (fixed)
- ...and 5 older fixed issues not shown (`pjm search`, or `get_issue(issue_id)` via MCP)

## Decisions
- Adopt 'Uyg'otgich' as pure Uzbek name for alarm, replace frustrating math addition mission with interactive Solar Rays Wake-up mission (5 gentle sun taps with morning affirmation)
- Refactor: refactor: update ringing page indicator color and dynamic region in solar clock view [lib/features/alarm/presentation/pages/ringing_page.dart]
- Planner creation uses a dedicated screen: timed tasks open Focus Timer attached to the task; no-timer tasks stay in Planner and complete directly [lib/features/planner/presentation/]
- Planner 'Yangi Reja' FAB replaced with custom CupertinoButton (tinted primary bg + primary foreground, thin border), centered via centerFloat [lib/features/planner/presentation/pages/planner_view.dart]
- Habits minimalist UI: replaced FAB with tinted Cupertino centerFloat button (primary bg alpha + thin border, primary text/ikon), replaced Material TextFormField with CupertinoTextField (iOS style), replaced save ElevatedButton with tinted CupertinoButton [lib/features/habit/presentation/pages/{habit_view,add_habit_page}.dart]
- Navigation moved to go_router (moliyachi pattern): RoutePath constants in lib/core/router/path.dart, GoRouter in router.dart, tabs via StatefulShellRoute.indexedStack; tab switches use context.go(RoutePath.focus) instead of onSwitchTab callbacks. Shared CustomButton in lib/core/widgets/custom_button.dart (tinted primary default, filled via backgroundColor). Habit tab redesigned minimal: week strip with per-day progress rings + month calendar on detail page (tap past days to toggle, HabitCubit.toggleDate). [lib/core/router/router.dart]
- Minimal UI pass across tabs: borderless cards (colors.card, radius 16), single primary accent, Cupertino switches/segments. Alarm list = large thin time + one muted detail line; alarm editor uses inline CupertinoDatePicker and grouped rows (sound via action sheet). Focus: tap the countdown when idle to set a custom duration (CupertinoTimerPicker, hm, min 1 minute); presets are plain text. [lib/features/focus_timer/presentation/pages/focus_timer_view.dart]

## Notes
- feat: implement alarm feature with storage, repository, cubit, and UI views
- feat: add Maestro E2E test suite and math challenge mission to alarms
- feat: add task categories and filtering to planner view
- New feature: feat: migrate focus timer and navigation to iOS Cupertino design and add wakelock support [lib/core/theme/app_theme.dart]
- New feature: feat: add Patrol E2E test suite and integration test configuration [integration_test/app_e2e_test.dart]
- Removed math mission remnants (mathOperand1/2, mathAnswer, verifyMathAndDismiss) from AlarmState and AlarmCubit. Created full-screen RingingPage (iOS black style, pulsing sun ScaleTransition, animated progress dots, fade route transition). alarm_view.dart now pushes RingingPage via rootNavigator instead of showing AlertDialog. Added patrol E2E test for alarm creation flow.
- New feature: feat: replace math alarm mission with full-screen ringing page and add E2E test [lib/features/alarm/presentation/cubit/alarm_cubit.dart]
- gotcha: Maestro iOS E2E loses Flutter semantics tree after inputText focuses a TextField (only status bar exposed); type+save legs can't be asserted. Workaround: keep flow to tap/assert navigation only. [.maestro/03_planner_flow.yaml]
- pre-existing iOS build breakage unrelated to this task: lib/features/alarm/presentation/pages/ringing_page.dart uses undefined CustomButton (lines 339,358,375); blocks full flutter build ios / Maestro until fixed separately [lib/features/alarm/presentation/pages/ringing_page.dart]
- New feature: feat: add habit feature, go_router navigation, and UI minimal polish [lib/di.dart]

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
