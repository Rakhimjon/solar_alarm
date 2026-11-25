# #0015 iOS permission_handler notification support is disabled until PERMISSION_NOTIFICATIONS=1 is added to Podfile build definitions

- 2026-11-25T12:58:18Z `issue`: iOS permission_handler notification support is disabled until PERMISSION_NOTIFICATIONS=1 is added to Podfile build definitions [ios/Podfile:39]
- 2026-11-25T12:59:15Z `attempt`: Enabled PERMISSION_NOTIFICATIONS=1 in iOS Podfile; Podfile syntax and debug iOS build pass [ios/Podfile:41] (worked)
- 2026-11-25T12:59:17Z `fix`: iOS notification permission support enabled and verified with successful debug iOS build [ios/Podfile:41]
