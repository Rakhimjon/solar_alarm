# #0001 Focus timer screen turns dark (no wakelock), lifecycle freezes/abruptly pauses on iOS, and animation needs iOS release optimization

- 2026-11-25T03:55:49Z `issue`: Focus timer screen turns dark (no wakelock), lifecycle freezes/abruptly pauses on iOS, and animation needs iOS release optimization [lib/features/focus_timer/]
- 2026-11-25T04:52:33Z `fix`: Added wakelock_plus to keep screen on while focus timer runs, fixed iOS lifecycle handling with DateTime-based countdown, and removed per-frame allocations in HourglassWidget for smooth 60/120fps iOS release runs
