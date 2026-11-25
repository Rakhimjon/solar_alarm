# #0010 No runtime notification or exact-alarm permission check/onboarding exists before scheduling alarms

- 2026-11-25T12:37:31Z `issue`: No runtime notification or exact-alarm permission check/onboarding exists before scheduling alarms [lib/main.dart:13]
- 2026-11-25T12:57:20Z `attempt`: Alarm creation now requests notifications and exact-alarm access with denial feedback; analysis, tests and APK build pass [lib/core/services/alarm_permissions.dart:6] (worked)
- 2026-11-25T12:57:23Z `fix`: Runtime alarm permissions and user-facing denial messages added for custom and solar alarms [lib/core/services/alarm_permissions.dart:6]
