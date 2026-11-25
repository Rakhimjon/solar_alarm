# #0003 Unit test compilation is broken by stale alarm math APIs and a solar repository fake signature

- 2026-11-25T12:34:46Z `issue`: Unit test compilation is broken by stale alarm math APIs and a solar repository fake signature [test/features/alarm/alarm_cubit_test.dart:88]
- 2026-11-25T12:43:15Z `attempt`: Removed stale math test calls and updated solar fake region parameter; both suites pass [test/features/alarm/alarm_cubit_test.dart:87] (worked)
- 2026-11-25T12:43:17Z `fix`: Alarm and solar test suites compile and pass after syncing tests with current APIs [test/features/solar_clock/solar_clock_repository_test.dart:13]
