import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ThemeController extends GetxController {
  final SharedPreferences _prefs;

  ThemeController(this._prefs);

  final Rx<ThemeMode> _themeMode = ThemeMode.dark.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    final savedMode = _prefs.getString(AppConstants.keyThemeMode);
    if (savedMode == 'light') {
      _themeMode.value = ThemeMode.light;
    } else {
      _themeMode.value = ThemeMode.dark;
    }
  }

  void toggleTheme() {
    if (_themeMode.value == ThemeMode.dark) {
      _themeMode.value = ThemeMode.light;
      _prefs.setString(AppConstants.keyThemeMode, 'light');
    } else {
      _themeMode.value = ThemeMode.dark;
      _prefs.setString(AppConstants.keyThemeMode, 'dark');
    }
    Get.changeThemeMode(_themeMode.value);
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _prefs.setString(
      AppConstants.keyThemeMode,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
    Get.changeThemeMode(mode);
  }
}
