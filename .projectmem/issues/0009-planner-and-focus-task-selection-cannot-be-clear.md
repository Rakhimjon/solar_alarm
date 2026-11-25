# #0009 Planner and focus task selection cannot be cleared because nullable copyWith parameters retain old IDs and titles

- 2026-11-25T12:37:11Z `issue`: Planner and focus task selection cannot be cleared because nullable copyWith parameters retain old IDs and titles [lib/features/planner/presentation/cubit/planner_state.dart:40]
- 2026-11-25T12:42:56Z `attempt`: Added explicit clearActiveTask handling for planner and focus; regression test passes [lib/features/planner/presentation/cubit/planner_state.dart:36] (worked)
- 2026-11-25T12:42:58Z `fix`: Planner and focus task selections now clear correctly; regression test passes [lib/features/focus_timer/presentation/cubit/focus_timer_cubit.dart:52]
