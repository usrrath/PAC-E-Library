import 'package:shared_preferences/shared_preferences.dart';

import '../models/success_user.dart';

class LoginService {
  static const String keyRememberMe = 'remember_me';
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

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyRememberMe) ?? false;
  }

  Future<String> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserEmail) ?? '';
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken) ?? '';
  }

  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId) ?? '';
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? '';
  }

  Future<String> getUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserLevel) ?? '';
  }

  Future<String> getUserPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserPhoto) ?? '';
  }

  Future<void> saveLogin({
    required SuccessUser data,
    required bool rememberMe,
    Map<String, String>? deviceInfo,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(keyRememberMe, rememberMe);

    await prefs.setString(
      keyToken,
      data.token.trim(),
    );

    await prefs.setString(
      keyUserId,
      data.user.id.trim(),
    );

    await prefs.setString(
      keyUserName,
      data.user.name.trim(),
    );

    await prefs.setString(
      keyUserLevel,
      (data.user.level ?? '').trim(),
    );

    await prefs.setString(
      keyUserPhoto,
      (data.user.photo ?? '').trim(),
    );

    if (deviceInfo != null) {
      await prefs.setString(
        keyDeviceType,
        deviceInfo['device_type'] ?? '',
      );

      await prefs.setString(
        keyDeviceName,
        deviceInfo['device_name'] ?? '',
      );

      await prefs.setString(
        keyPlatform,
        deviceInfo['platform'] ?? '',
      );

      await prefs.setString(
        keyBrowser,
        deviceInfo['browser'] ?? '',
      );
    }

    if (rememberMe) {
      await prefs.setString(
        keyUserEmail,
        data.user.email.trim(),
      );
    } else {
      await prefs.remove(keyUserEmail);
    }
  }

  Future<Map<String, String>> getSavedDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'device_type':
      prefs.getString(keyDeviceType) ?? '',
      'device_name':
      prefs.getString(keyDeviceName) ?? '',
      'platform':
      prefs.getString(keyPlatform) ?? '',
      'browser':
      prefs.getString(keyBrowser) ?? '',
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMe =
        prefs.getBool(keyRememberMe) ?? false;

    final email =
    prefs.getString(keyUserEmail);

    await prefs.clear();

    if (rememberMe) {
      await prefs.setBool(
        keyRememberMe,
        true,
      );

      if (email != null && email.trim().isNotEmpty) {
        await prefs.setString(
          keyUserEmail,
          email.trim(),
        );
      }
    }
  }
}