# #0014 permission_handler 13 requires Android compileSdk 37 while project AGP supports 36, breaking debug APK build

- 2026-11-25T12:56:15Z `issue`: permission_handler 13 requires Android compileSdk 37 while project AGP supports 36, breaking debug APK build [pubspec.yaml:26]
- 2026-11-25T12:56:45Z `attempt`: permission_handler 13.0.2 build failed: Android AAR metadata requires compileSdk 37, project uses 36 [pubspec.yaml:26] (failed)
- 2026-11-25T12:56:49Z `attempt`: Pinned permission_handler ^12.0.3, which uses Android plugin 13.0.1; debug APK builds [pubspec.yaml:26] (worked)
- 2026-11-25T12:56:59Z `fix`: Android debug build restored with permission_handler ^12.0.3 compatible with project compileSdk 36 [pubspec.yaml:26]
