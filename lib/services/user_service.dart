import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/success_user.dart';
import 'base_url.dart';

class UserService {
  final String base = BaseURL.base;

  Map<String, String> _jsonHeaders({String? token}) {
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  Map<String, String> _authHeaders({String? token}) {
    return {
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      if (response.body.trim().isEmpty) {
        return "$fallback (${response.statusCode})";
      }

      final body = jsonDecode(response.body);

      if (body is Map) {
        if (body["message"] != null) {
          return body["message"].toString();
        }

        if (body["errors"] is Map) {
          final errors = body["errors"] as Map;

          if (errors.isNotEmpty) {
            final first = errors.values.first;

            if (first is List && first.isNotEmpty) {
              return first.first.toString();
            }

            return first.toString();
          }
        }
      }
    } catch (_) {}

    return "$fallback (${response.statusCode})";
  }

  Map<String, dynamic> _decodeMap(
      http.Response response,
      String invalidMessage,
      ) {
    if (response.body.trim().isEmpty) return {};

    final body = jsonDecode(response.body);

    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);

    throw Exception(invalidMessage);
  }

  String _normalizeBase64Image(File photo) {
    final bytes = photo.readAsBytesSync();
    final base64String = base64Encode(bytes);

    final ext = photo.path.split(".").last.toLowerCase();

    String mime = "jpeg";

    if (ext == "png") {
      mime = "png";
    } else if (ext == "jpg" || ext == "jpeg") {
      mime = "jpeg";
    }

    return "data:image/$mime;base64,$base64String";
  }

  Future<SuccessUser> login(String email, String password) async {
    final uri = Uri.parse("$base/api/signin");

    try {
      final response = await http.post(
        uri,
        headers: _jsonHeaders(),
        body: jsonEncode({
          "email": email.trim(),
          "password": password,
        }),
      );

      debugPrint("LOGIN STATUS: ${response.statusCode}");
      debugPrint("LOGIN BODY: ${response.body}");

      if (_isSuccess(response.statusCode)) {
        return compute(successUserFromJson, response.body);
      }

      throw Exception(_errorMessage(response, "Login failed"));
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }

  Future<void> logout(String token) async {
    final uri = Uri.parse("$base/api/signout");

    try {
      final response = await http.post(
        uri,
        headers: _authHeaders(token: token),
      );

      debugPrint("LOGOUT STATUS: ${response.statusCode}");
      debugPrint("LOGOUT BODY: ${response.body}");

      if (!_isSuccess(response.statusCode)) {
        throw Exception(_errorMessage(response, "Logout failed"));
      }
    } catch (e) {
      throw Exception("Logout error: $e");
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
    required bool terminateSessions,
  }) async {
    final uri = Uri.parse("$base/api/password/change");

    try {
      final response = await http.patch(
        uri,
        headers: _jsonHeaders(token: token),
        body: jsonEncode({
          "old_password": oldPassword,
          "new_password": newPassword,
          "new_password_confirmation": newPasswordConfirmation,
          "terminate_sessions": terminateSessions,
        }),
      );

      debugPrint("CHANGE PASSWORD STATUS: ${response.statusCode}");
      debugPrint("CHANGE PASSWORD BODY: ${response.body}");

      if (_isSuccess(response.statusCode)) {
        return _decodeMap(response, "Invalid change password response");
      }

      throw Exception(_errorMessage(response, "Failed to change password"));
    } catch (e) {
      throw Exception("Change password error: $e");
    }
  }

  Future<Map<String, dynamic>> getVerifyAccount(String token) async {
    final uri = Uri.parse("$base/api/verify/account");

    try {
      final response = await http.get(
        uri,
        headers: _authHeaders(token: token),
      );

      debugPrint("VERIFY ACCOUNT STATUS: ${response.statusCode}");
      debugPrint("VERIFY ACCOUNT BODY: ${response.body}");

      if (_isSuccess(response.statusCode)) {
        return _decodeMap(response, "Invalid verify account response");
      }

      throw Exception(_errorMessage(response, "Account verification failed"));
    } catch (e) {
      throw Exception("Verify account error: $e");
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final uri = Uri.parse("$base/api/users/profile");

    try {
      final response = await http.get(
        uri,
        headers: _authHeaders(token: token),
      );

      debugPrint("GET PROFILE STATUS: ${response.statusCode}");
      debugPrint("GET PROFILE BODY: ${response.body}");

      if (_isSuccess(response.statusCode)) {
        return _decodeMap(response, "Invalid profile response");
      }

      throw Exception(_errorMessage(response, "Failed to load profile"));
    } catch (e) {
      throw Exception("Profile error: $e");
    }
  }

  Future<Map<String, dynamic>> updateName({
    required String token,
    required String name,
  }) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw Exception("Name is required");
    }

    final uri = Uri.parse("$base/api/users/profile");

    try {
      final response = await http.patch(
        uri,
        headers: _jsonHeaders(token: token),
        body: jsonEncode({
          "name": cleanName,
        }),
      );

      debugPrint("UPDATE NAME STATUS: ${response.statusCode}");
      debugPrint("UPDATE NAME BODY: ${response.body}");

      if (_isSuccess(response.statusCode)) {
        return _decodeMap(response, "Invalid update name response");
      }

      throw Exception(_errorMessage(response, "Failed to update name"));
    } catch (e) {
      throw Exception("Update name error: $e");
    }
  }

  Future<Map<String, dynamic>> updatePhoto({
    required String token,
    required File photo,
  }) async {
    final uri = Uri.parse("$base/api/update/photo");

    try {
      final base64Photo = _normalizeBase64Image(photo);

      final response = await http.patch(
        uri,
        headers: _jsonHeaders(token: token),
        body: jsonEncode({
          "photo": base64Photo,
        }),
      );

      debugPrint("UPDATE PHOTO STATUS: ${response.statusCode}");
      debugPrint("UPDATE PHOTO BODY: ${response.body}");

      if (_isSuccess(response.statusCode)) {
        return _decodeMap(response, "Invalid update photo response");
      }

      throw Exception(_errorMessage(response, "Failed to update photo"));
    } catch (e) {
      throw Exception("Update photo error: $e");
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    File? photo,
  }) async {
    final cleanName = name?.trim() ?? "";

    if (cleanName.isEmpty && photo == null) {
      return {
        "success": false,
        "message": "No changes to update",
      };
    }

    Map<String, dynamic> result = {};

    try {
      if (cleanName.isNotEmpty) {
        result = await updateName(
          token: token,
          name: cleanName,
        );
      }

      if (photo != null) {
        final photoResult = await updatePhoto(
          token: token,
          photo: photo,
        );

        result = {
          ...result,
          ...photoResult,
        };
      }

      return result;
    } catch (e) {
      throw Exception("Update profile error: $e");
    }
  }
}