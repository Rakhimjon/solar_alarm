# #0008 Cancelling solar alarm cannot clear activeAlarmTime because copyWith converts null back to the old value

- 2026-11-25T12:36:56Z `issue`: Cancelling solar alarm cannot clear activeAlarmTime because copyWith converts null back to the old value [lib/features/solar_clock/presentation/cubit/solar_clock_state.dart:44]
- 2026-11-25T12:42:50Z `attempt`: Added clearActiveAlarmTime and regression test; focused state tests pass [lib/features/solar_clock/presentation/cubit/solar_clock_state.dart:38] (worked)
- 2026-11-25T12:42:53Z `fix`: Solar alarm cancellation now clears activeAlarmTime; regression test passes [lib/features/solar_clock/presentation/cubit/solar_clock_cubit.dart:69]
