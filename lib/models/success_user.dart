import 'dart:convert';

SuccessUser successUserFromJson(String str) {
  return SuccessUser.fromJson(jsonDecode(str));
}

String successUserToJson(SuccessUser data) {
  return jsonEncode(data.toJson());
}

class SuccessUser {
  final String? message;
  final User user;
  final String token;
  final String? expiresAt;

  SuccessUser({
    this.message,
    required this.user,
    required this.token,
    this.expiresAt,
  });

  factory SuccessUser.fromJson(Map<String, dynamic> json) {
    return SuccessUser(
      message: json['message']?.toString(),
      user: User.fromJson(json['user'] ?? {}),
      token: json['token']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
      'token': token,
      'expires_at': expiresAt,
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? level;
  final String? photo;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.level,
    this.photo,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      level: json['level']?.toString(),
      photo: json['photo']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'level': level,
      'photo': photo,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}