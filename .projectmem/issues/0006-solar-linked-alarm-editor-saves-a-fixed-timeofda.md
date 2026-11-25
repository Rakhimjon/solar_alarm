# #0006 Solar-linked alarm editor saves a fixed TimeOfDay; scheduling ignores linkedSolarType and solarOffsetMinutes

- 2026-11-25T12:36:27Z `issue`: Solar-linked alarm editor saves a fixed TimeOfDay; scheduling ignores linkedSolarType and solarOffsetMinutes [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:66]
- 2026-11-25T12:47:34Z `attempt`: Solar alarms now resolve event dates, offsets, weekdays and region; three scheduling regression tests pass [lib/features/alarm/data/datasources/alarm_local_storage.dart:16] (worked)
- 2026-11-25T12:47:37Z `fix`: Solar-linked alarms schedule resolved event time with offset and preserve location; regression tests pass [lib/features/alarm/data/datasources/alarm_local_storage.dart:16]
