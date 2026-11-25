# #0012 Custom weekday and segmented controls have sub-44px targets and GestureDetector controls lack button semantics

- 2026-11-25T12:37:37Z `issue`: Custom weekday and segmented controls have sub-44px targets and GestureDetector controls lack button semantics [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:540]
- 2026-11-25T12:57:39Z `attempt`: Weekday targets increased to 48, segmented controls to 48 minimum, and custom controls gained semantics; checks pass [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:662] (worked)
- 2026-11-25T12:57:41Z `fix`: Custom alarm controls now meet touch-target sizing and expose button/selection semantics [lib/features/alarm/presentation/pages/add_edit_alarm_page.dart:540]
