# #0011 Alarm save/delete screens close without awaiting repository operations or showing scheduling failures

- 2026-11-25T12:37:33Z `issue`: Alarm save/delete screens close without awaiting repository operations or showing scheduling failures [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:66]
- 2026-11-25T12:57:27Z `attempt`: Alarm save/delete now await operations, prevent duplicate saves, stay open on failure and show errors; checks pass [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:69] (worked)
- 2026-11-25T12:57:30Z `fix`: Alarm editor handles async completion and scheduling failures instead of closing prematurely [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:69]
