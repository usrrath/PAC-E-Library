import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apps/app_provider.dart';
import '../models/settings_model.dart';

class SettingsService {
  const SettingsService._();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String keyRememberMe = 'remember_me';
  static const String keySignedOut = 'signed_out';

  static const String keyAuthToken = 'auth_token';
  static const String keyToken = 'token';
  static const String keyAccessToken = 'access_token';

  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserLevel = 'user_level';
  static const String keyUserPhoto = 'user_photo';

  static const String keyTwoFactorEnabled = 'two_factor_enabled';
  static const String keyTwoFactorSecret = 'two_factor_secret';

  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyBiometricToken = 'biometric_server_token';
  static const String keyBiometricLastAuth = 'biometric_last_auth';
  static const String keyBiometricUserId = 'biometric_user_id';
  static const String keyBiometricUserName = 'biometric_user_name';
  static const String keyBiometricUserEmail = 'biometric_user_email';
  static const String keyBiometricUserLevel = 'biometric_user_level';
  static const String keyBiometricUserPhoto = 'biometric_user_photo';
  static const String keyBiometricPinCode = 'biometric_pin_code';

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

    final authToken = prefs.getString(keyAuthToken);
    if (authToken != null && authToken.trim().isNotEmpty) {
      return authToken.trim();
    }

    final token = prefs.getString(keyToken);
    if (token != null && token.trim().isNotEmpty) {
      return token.trim();
    }

    final accessToken = prefs.getString(keyAccessToken);
    if (accessToken != null && accessToken.trim().isNotEmpty) {
      return accessToken.trim();
    }

    return null;
  }

  static Future<bool> hasToken() async {
    final value = await token();
    return value != null && value.trim().isNotEmpty;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAuthToken, token.trim());
    await prefs.setBool(keySignedOut, false);
  }

  static Future<bool> isSignedOut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keySignedOut) ?? false;
  }

  static Future<void> setSignedOut(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keySignedOut, value);
  }

  static Future<bool> isTwoFactorEnabled() async {
    final enabled = await _secureStorage.read(key: keyTwoFactorEnabled);
    final secret = await _secureStorage.read(key: keyTwoFactorSecret);

    return enabled == 'true' && secret != null && secret.trim().isNotEmpty;
  }

  static Future<String> twoFactorSecret() async {
    return await _secureStorage.read(key: keyTwoFactorSecret) ?? '';
  }

  static Future<void> saveTwoFactor({
    required String secret,
  }) async {
    final cleanSecret = secret.trim().replaceAll(' ', '').toUpperCase();

    if (cleanSecret.isEmpty) {
      throw Exception('2FA secret is required');
    }

    await _secureStorage.write(key: keyTwoFactorEnabled, value: 'true');
    await _secureStorage.write(key: keyTwoFactorSecret, value: cleanSecret);
  }

  static Future<void> clearTwoFactor() async {
    await _secureStorage.delete(key: keyTwoFactorEnabled);
    await _secureStorage.delete(key: keyTwoFactorSecret);
  }

  static Future<bool> isBiometricEnabled() async {
    if (await isSignedOut()) return false;

    final enabled = await _secureStorage.read(key: keyBiometricEnabled);
    final bioToken = await _secureStorage.read(key: keyBiometricToken);

    return enabled == 'true' &&
        bioToken != null &&
        bioToken.trim().isNotEmpty;
  }

  static Future<String> biometricToken() async {
    return await _secureStorage.read(key: keyBiometricToken) ?? '';
  }

  static Future<void> saveBiometricToken({
    required String token,
    String userId = '',
    String name = '',
    String email = '',
    String level = '',
    String photo = '',
  }) async {
    final cleanToken = token.trim();

    if (cleanToken.isEmpty) {
      throw Exception('Biometric token is required');
    }

    await _secureStorage.write(key: keyBiometricEnabled, value: 'true');
    await _secureStorage.write(key: keyBiometricToken, value: cleanToken);
    await _secureStorage.write(key: keyBiometricUserId, value: userId.trim());
    await _secureStorage.write(key: keyBiometricUserName, value: name.trim());
    await _secureStorage.write(key: keyBiometricUserEmail, value: email.trim());
    await _secureStorage.write(key: keyBiometricUserLevel, value: level.trim());
    await _secureStorage.write(key: keyBiometricUserPhoto, value: photo.trim());
    await updateBiometricLastAuth();
  }

  static Future<void> updateBiometricLastAuth() async {
    await _secureStorage.write(
      key: keyBiometricLastAuth,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  static Future<int> biometricLastAuthMillis() async {
    final value = await _secureStorage.read(key: keyBiometricLastAuth);
    return int.tryParse(value ?? '') ?? 0;
  }

  static Future<void> saveBiometricPin(String pin) async {
    final cleanPin = pin.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(cleanPin)) {
      throw Exception('PIN must be 4 digits');
    }

    await _secureStorage.write(key: keyBiometricPinCode, value: cleanPin);
  }

  static Future<bool> hasBiometricPin() async {
    final pin = await _secureStorage.read(key: keyBiometricPinCode);
    return pin != null && RegExp(r'^\d{4}$').hasMatch(pin.trim());
  }

  static Future<bool> verifyBiometricPin(String pin) async {
    final savedPin = await _secureStorage.read(key: keyBiometricPinCode);
    return savedPin != null && savedPin.trim() == pin.trim();
  }

  static Future<void> restoreBiometricLoginToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final bioToken = await _secureStorage.read(key: keyBiometricToken) ?? '';
    final userId = await _secureStorage.read(key: keyBiometricUserId) ?? '';
    final name = await _secureStorage.read(key: keyBiometricUserName) ?? '';
    final email = await _secureStorage.read(key: keyBiometricUserEmail) ?? '';
    final level = await _secureStorage.read(key: keyBiometricUserLevel) ?? '';
    final photo = await _secureStorage.read(key: keyBiometricUserPhoto) ?? '';

    if (bioToken.trim().isEmpty) {
      throw Exception('Biometric token not found');
    }

    await prefs.setBool(keySignedOut, false);
    await prefs.setBool(keyRememberMe, true);
    await prefs.setString(keyAuthToken, bioToken.trim());
    await prefs.setString(keyUserId, userId.trim());
    await prefs.setString(keyUserName, name.trim());
    await prefs.setString(keyUserEmail, email.trim());
    await prefs.setString(keyUserLevel, level.trim());
    await prefs.setString(keyUserPhoto, photo.trim());
  }

  static Future<void> clearBiometric() async {
    await _secureStorage.delete(key: keyBiometricEnabled);
    await _secureStorage.delete(key: keyBiometricToken);
    await _secureStorage.delete(key: keyBiometricLastAuth);
    await _secureStorage.delete(key: keyBiometricUserId);
    await _secureStorage.delete(key: keyBiometricUserName);
    await _secureStorage.delete(key: keyBiometricUserEmail);
    await _secureStorage.delete(key: keyBiometricUserLevel);
    await _secureStorage.delete(key: keyBiometricUserPhoto);
    await _secureStorage.delete(key: keyBiometricPinCode);
  }

  static Future<void> clearAuthKeepRememberMe({
    bool signedOut = false,
    bool clearBiometricLogin = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMe = prefs.getBool(keyRememberMe) ?? false;
    final savedEmail = prefs.getString(keyUserEmail) ?? '';

    await prefs.remove(keyAuthToken);
    await prefs.remove(keyToken);
    await prefs.remove(keyAccessToken);
    await prefs.remove(keyUserId);
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserLevel);
    await prefs.remove(keyUserPhoto);

    await prefs.setBool(keySignedOut, signedOut);

    if (rememberMe) {
      await prefs.setBool(keyRememberMe, true);

      if (savedEmail.trim().isNotEmpty) {
        await prefs.setString(keyUserEmail, savedEmail.trim());
      }
    }

    if (clearBiometricLogin) {
      await clearBiometric();
    }
  }

  static Future<void> logout() async {
    await clearAuthKeepRememberMe(
      signedOut: true,
      clearBiometricLogin: true,
    );
  }

  static Future<void> clearAllSecurity() async {
    await clearBiometric();
    await clearTwoFactor();
    await clearAuthKeepRememberMe(
      signedOut: true,
      clearBiometricLogin: true,
    );
  }
}