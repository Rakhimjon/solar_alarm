import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _prefKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(_loadInitialTheme(prefs));

  static ThemeMode _loadInitialTheme(SharedPreferences prefs) {
    final saved = prefs.getString(_prefKey);
    if (saved == 'light') return ThemeMode.light;
    if (saved == 'dark') return ThemeMode.dark;
    return ThemeMode.dark;
  }

  void toggleTheme() {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(nextMode);
  }

  void setThemeMode(ThemeMode mode) {
    emit(mode);
    _prefs.setString(_prefKey, mode == ThemeMode.light ? 'light' : 'dark');
  }
}
