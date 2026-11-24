import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_alarm/core/theme/theme_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ThemeCubit initializes and toggles theme mode', () async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
    final prefs = await SharedPreferences.getInstance();

    final cubit = ThemeCubit(prefs: prefs);
    expect(cubit.state, ThemeMode.dark);

    cubit.toggleTheme();
    expect(cubit.state, ThemeMode.light);
    expect(prefs.getString('app_theme_mode'), 'light');

    cubit.toggleTheme();
    expect(cubit.state, ThemeMode.dark);
    expect(prefs.getString('app_theme_mode'), 'dark');
  });
}
