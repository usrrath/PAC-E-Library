import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/success_user.dart';

class LoginService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String keyRememberMe = 'remember_me';
  static const String keySignedOut = 'signed_out';

  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserLevel = 'user_level';
  static const String keyUserPhoto = 'user_photo';

  static const String keyDeviceType = 'device_type';
  static const String keyDeviceName = 'device_name';
  static const String keyPlatform = 'platform';
  static const String keyBrowser = 'browser';

  static const String biometricEnabled = 'biometric_enabled';
  static const String biometricToken = 'biometric_server_token';
  static const String biometricLastAuth = 'biometric_last_auth';
  static const String biometricUserId = 'biometric_user_id';
  static const String biometricUserName = 'biometric_user_name';
  static const String biometricUserEmail = 'biometric_user_email';
  static const String biometricUserLevel = 'biometric_user_level';
  static const String biometricUserPhoto = 'biometric_user_photo';
  static const String biometricPinCode = 'biometric_pin_code';

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyRememberMe) ?? false;
  }

  Future<bool> isSignedOut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keySignedOut) ?? false;
  }

  Future<String> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserEmail) ?? '';
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken) ?? '';
  }

  Future<void> saveLogin({
    required SuccessUser data,
    required bool rememberMe,
    Map<String, String>? deviceInfo,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(keySignedOut, false);
    await prefs.setBool(keyRememberMe, rememberMe);

    await prefs.setString(keyToken, data.token.trim());
    await prefs.setString(keyUserId, data.user.id.trim());
    await prefs.setString(keyUserName, data.user.name.trim());
    await prefs.setString(keyUserLevel, data.user.level.trim());
    await prefs.setString(keyUserPhoto, data.user.photo.trim());

    if (rememberMe) {
      await prefs.setString(keyUserEmail, data.user.email.trim());
    } else {
      await prefs.remove(keyUserEmail);
    }

    if (deviceInfo != null) {
      await prefs.setString(keyDeviceType, deviceInfo['device_type'] ?? '');
      await prefs.setString(keyDeviceName, deviceInfo['device_name'] ?? '');
      await prefs.setString(keyPlatform, deviceInfo['platform'] ?? '');
      await prefs.setString(keyBrowser, deviceInfo['browser'] ?? '');
    }
  }

  Future<void> saveBiometricSession(SuccessUser data) async {
    await _secureStorage.write(key: biometricEnabled, value: 'true');
    await _secureStorage.write(key: biometricToken, value: data.token.trim());
    await _secureStorage.write(key: biometricUserId, value: data.user.id.trim());
    await _secureStorage.write(key: biometricUserName, value: data.user.name.trim());
    await _secureStorage.write(key: biometricUserEmail, value: data.user.email.trim());
    await _secureStorage.write(key: biometricUserLevel, value: data.user.level.trim());
    await _secureStorage.write(key: biometricUserPhoto, value: data.user.photo.trim());
    await updateBiometricLastAuth();
  }

  Future<bool> isBiometricEnabled({bool ignoreSignedOut = false}) async {
    if (!ignoreSignedOut && await isSignedOut()) return false;

    final enabled = await _secureStorage.read(key: biometricEnabled);
    final token = await _secureStorage.read(key: biometricToken);
    final pin = await _secureStorage.read(key: biometricPinCode);

    return enabled == 'true' &&
        token != null &&
        token.trim().isNotEmpty &&
        pin != null &&
        RegExp(r'^\d{4}$').hasMatch(pin.trim());
  }

  Future<String> getBiometricToken() async {
    return await _secureStorage.read(key: biometricToken) ?? '';
  }

  Future<void> saveBiometricPin(String pin) async {
    final cleanPin = pin.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(cleanPin)) {
      throw Exception('PIN must be 4 digits');
    }

    await _secureStorage.write(key: biometricPinCode, value: cleanPin);
  }

  Future<bool> verifyBiometricPin(String pin) async {
    final savedPin = await _secureStorage.read(key: biometricPinCode);
    return savedPin != null && savedPin.trim() == pin.trim();
  }

  Future<void> updateBiometricLastAuth() async {
    await _secureStorage.write(
      key: biometricLastAuth,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Future<void> restoreBiometricLoginToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final token = await _secureStorage.read(key: biometricToken) ?? '';
    final userId = await _secureStorage.read(key: biometricUserId) ?? '';
    final name = await _secureStorage.read(key: biometricUserName) ?? '';
    final email = await _secureStorage.read(key: biometricUserEmail) ?? '';
    final level = await _secureStorage.read(key: biometricUserLevel) ?? '';
    final photo = await _secureStorage.read(key: biometricUserPhoto) ?? '';

    if (token.trim().isEmpty) {
      throw Exception('Biometric token not found');
    }

    await prefs.setBool(keySignedOut, false);
    await prefs.setBool(keyRememberMe, true);
    await prefs.setString(keyToken, token.trim());
    await prefs.setString(keyUserId, userId.trim());
    await prefs.setString(keyUserName, name.trim());
    await prefs.setString(keyUserEmail, email.trim());
    await prefs.setString(keyUserLevel, level.trim());
    await prefs.setString(keyUserPhoto, photo.trim());
  }

  Future<Map<String, String>> getSavedDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'device_type': prefs.getString(keyDeviceType) ?? '',
      'device_name': prefs.getString(keyDeviceName) ?? '',
      'platform': prefs.getString(keyPlatform) ?? '',
      'browser': prefs.getString(keyBrowser) ?? '',
    };
  }

  Future<void> clearAuthOnly() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(keyToken);
    await prefs.remove(keyUserId);
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserLevel);
    await prefs.remove(keyUserPhoto);
  }

  Future<void> clearBiometricLogin() async {
    await _secureStorage.delete(key: biometricEnabled);
    await _secureStorage.delete(key: biometricToken);
    await _secureStorage.delete(key: biometricLastAuth);
    await _secureStorage.delete(key: biometricUserId);
    await _secureStorage.delete(key: biometricUserName);
    await _secureStorage.delete(key: biometricUserEmail);
    await _secureStorage.delete(key: biometricUserLevel);
    await _secureStorage.delete(key: biometricUserPhoto);
    await _secureStorage.delete(key: biometricPinCode);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMe = prefs.getBool(keyRememberMe) ?? false;
    final email = prefs.getString(keyUserEmail);

    await prefs.clear();
    await clearBiometricLogin();

    await prefs.setBool(keySignedOut, true);

    if (rememberMe) {
      await prefs.setBool(keyRememberMe, true);
      if (email != null && email.trim().isNotEmpty) {
        await prefs.setString(keyUserEmail, email.trim());
      }
    }
  }
}