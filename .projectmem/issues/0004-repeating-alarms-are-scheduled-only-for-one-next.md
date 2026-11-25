# #0004 Repeating alarms are scheduled only for one nextDateTime and never rescheduled after ringing stops

- 2026-11-25T12:34:56Z `issue`: Repeating alarms are scheduled only for one nextDateTime and never rescheduled after ringing stops [lib/features/alarm/data/datasources/alarm_local_storage.dart:111]
- 2026-11-25T12:47:40Z `attempt`: Repeating alarms reschedule after dismissal and stale/missing native schedules restore on launch; scheduling tests pass [lib/features/alarm/data/datasources/alarm_local_storage.dart:132] (worked)
- 2026-11-25T12:47:42Z `fix`: Repeating alarms now reschedule after dismissal and on app launch when native schedule is absent or expired [lib/features/alarm/data/datasources/alarm_local_storage.dart:139]
