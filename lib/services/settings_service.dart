import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apps/app_provider.dart';
import '../models/settings_model.dart';

class SettingsService {
  const SettingsService._();

  static double fontScale(FontSizePref value) {
    switch (value) {
      case FontSizePref.small:
        return 0.90;
      case FontSizePref.medium:
        return 1.00;
      case FontSizePref.large:
        return 1.15;
    }
  }

  static FontSizePref fontFromScale(double value) {
    if (value <= 0.95) return FontSizePref.small;
    if (value >= 1.10) return FontSizePref.large;
    return FontSizePref.medium;
  }

  static Future<void> changeThemeMode(ThemeMode value) async {
    await AppProvider.changeThemeMode(value);
  }

  static Future<void> changeFontSize(FontSizePref value) async {
    await AppProvider.changeFontScale(fontScale(value));
  }

  static Future<void> changeLanguage(String code) async {
    await AppProvider.changeLocale(code);
  }

  static Future<void> resetSettings() async {
    await AppSettings.clearAll();
    await AppProvider.changeThemeMode(ThemeMode.system);
    await AppProvider.changeFontScale(1.00);
    await AppProvider.changeLocale('en');
  }

  static Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token');
  }

  static Future<void> clearAuthKeepRememberMe() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMe = prefs.getBool('remember_me') ?? false;
    final savedEmail = prefs.getString('user_email') ?? '';

    await prefs.remove('auth_token');
    await prefs.remove('token');
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_level');
    await prefs.remove('user_photo');

    if (rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('user_email', savedEmail);
    }
  }
}