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

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyRememberMe) ?? false;
  }

  Future<String> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserEmail) ?? '';
  }

  Future<void> saveLogin({
    required SuccessUser data,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(keyRememberMe, rememberMe);

    if (!rememberMe) {
      await clearAuthOnly();
      return;
    }

    await prefs.setString(keyToken, data.token);
    await prefs.setString(keyUserId, data.user.id);
    await prefs.setString(keyUserName, data.user.name);
    await prefs.setString(keyUserEmail, data.user.email);

    final level = data.user.level;
    if (level != null && level.isNotEmpty) {
      await prefs.setString(keyUserLevel, level);
    }

    final photo = data.user.photo;
    if (photo != null && photo.isNotEmpty) {
      await prefs.setString(keyUserPhoto, photo);
    }
  }

  Future<void> clearAuthOnly() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(keyToken);
    await prefs.remove(keyUserId);
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserEmail);
    await prefs.remove(keyUserLevel);
    await prefs.remove(keyUserPhoto);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}