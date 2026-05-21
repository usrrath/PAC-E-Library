import 'dart:convert';

import 'user_model.dart';

SuccessUser successUserFromJson(String source) {
  return SuccessUser.fromJson(jsonDecode(source));
}

class SuccessUser {
  final bool success;
  final String message;
  final String token;
  final String expiresAt;
  final UserModel user;

  const SuccessUser({
    required this.success,
    required this.message,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory SuccessUser.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json['data']?['user'] ?? {};

    return SuccessUser(
      success: json['success'] == true,
      message: cleanText(json['message']),
      token: cleanText(json['token'] ?? json['access_token'] ?? json['auth_token']),
      expiresAt: cleanText(json['expires_at']),
      user: UserModel.fromJson(Map<String, dynamic>.from(userJson)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'expires_at': expiresAt,
      'user': user.toJson(),
    };
  }
}