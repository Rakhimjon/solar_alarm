# #0007 White text on amber buttons/chips fails WCAG contrast: 2.15:1 dark theme and 3.19:1 light theme

- 2026-11-25T12:36:37Z `issue`: White text on amber buttons/chips fails WCAG contrast: 2.15:1 dark theme and 3.19:1 light theme [lib/core/theme/app_theme.dart:26]
- 2026-11-25T12:57:34Z `attempt`: Added accessible onPrimary colors and applied them to amber buttons/chips and ringing actions; analysis and tests pass [lib/core/theme/app_theme.dart:7] (worked)
- 2026-11-25T12:57:36Z `fix`: Amber controls now use dark foreground colors instead of low-contrast white text [lib/core/theme/app_theme.dart:26]
