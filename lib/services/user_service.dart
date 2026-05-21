import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/success_user.dart';
import 'base_url.dart';
import 'profile_service.dart';

class UserService {
  final String base = BaseURL.base;

  String get apiRoot {
    final cleanBase = base.replaceAll(RegExp(r'/+$'), '');
    return cleanBase.endsWith('/api')
        ? cleanBase.substring(0, cleanBase.length - 4)
        : cleanBase;
  }

  String apiUrl(String path) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$apiRoot$cleanPath';
  }

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  Future<String> _tokenOrSaved(String? token) async {
    final cleanToken = token?.trim() ?? '';
    if (cleanToken.isNotEmpty) return cleanToken;

    final savedToken = await ProfileService.getToken();
    return savedToken?.trim() ?? '';
  }

  Future<Map<String, String>> _authHeaders({String? token}) async {
    final cleanToken = await _tokenOrSaved(token);

    return {
      'Accept': 'application/json',
      if (cleanToken.isNotEmpty) 'Authorization': 'Bearer $cleanToken',
    };
  }

  Future<Map<String, String>> _jsonHeaders({String? token}) async {
    final cleanToken = await _tokenOrSaved(token);

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (cleanToken.isNotEmpty) 'Authorization': 'Bearer $cleanToken',
    };
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final text = response.body.trim();
      if (text.isEmpty) return '$fallback (${response.statusCode})';

      final body = jsonDecode(text);

      if (body is Map) {
        final message = body['message'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }

        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
          return first.toString();
        }
      }
    } catch (_) {}

    return '$fallback (${response.statusCode})';
  }

  Map<String, dynamic> _decodeResponse(http.Response response, String listKey) {
    final text = response.body.trim();
    if (text.isEmpty) return {listKey: []};

    final body = jsonDecode(text);

    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    if (body is List) return {listKey: body};

    return {listKey: []};
  }

  String _normalizeBase64Image(File photo) {
    final bytes = photo.readAsBytesSync();
    final base64String = base64Encode(bytes);
    final ext = photo.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'png' : 'jpeg';

    return 'data:image/$mime;base64,$base64String';
  }

  Future<SuccessUser> login(String email, String password) async {
    final uri = Uri.parse(apiUrl('/api/signin'));

    try {
      final response = await http.post(
        uri,
        headers: await _jsonHeaders(),
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      debugPrint('LOGIN STATUS: ${response.statusCode}');
      debugPrint('LOGIN BODY: ${response.body}');

      if (_isSuccess(response.statusCode)) {
        return compute(successUserFromJson, response.body);
      }

      throw Exception(_errorMessage(response, 'Login failed'));
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<void> logout(String token) async {
    final uri = Uri.parse(apiUrl('/api/signout'));

    try {
      final response = await http.post(
        uri,
        headers: await _authHeaders(token: token),
      );

      debugPrint('LOGOUT STATUS: ${response.statusCode}');
      debugPrint('LOGOUT BODY: ${response.body}');

      if (!_isSuccess(response.statusCode)) {
        throw Exception(_errorMessage(response, 'Logout failed'));
      }
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  Future<Map<String, dynamic>> getVerifyAccount(String token) async {
    final uri = Uri.parse(apiUrl('/api/verify/account'));

    try {
      final response = await http.get(
        uri,
        headers: await _authHeaders(token: token),
      );

      if (_isSuccess(response.statusCode)) {
        return _decodeResponse(response, 'data');
      }

      throw Exception(_errorMessage(response, 'Account verification failed'));
    } catch (e) {
      throw Exception('Verify account error: $e');
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final uri = Uri.parse(apiUrl('/api/users/profile'));

    try {
      final response = await http.get(
        uri,
        headers: await _authHeaders(token: token),
      );

      if (_isSuccess(response.statusCode)) {
        return _decodeResponse(response, 'data');
      }

      throw Exception(_errorMessage(response, 'Failed to load profile'));
    } catch (e) {
      throw Exception('Profile error: $e');
    }
  }

  Future<Map<String, dynamic>> updateName({
    required String token,
    required String name,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw Exception('Name is required');

    final uri = Uri.parse(apiUrl('/api/users/profile'));

    try {
      final response = await http.patch(
        uri,
        headers: await _jsonHeaders(token: token),
        body: jsonEncode({'name': cleanName}),
      );

      if (_isSuccess(response.statusCode)) {
        return _decodeResponse(response, 'data');
      }

      throw Exception(_errorMessage(response, 'Failed to update name'));
    } catch (e) {
      throw Exception('Update name error: $e');
    }
  }

  Future<Map<String, dynamic>> updatePhoto({
    required String token,
    required File photo,
  }) async {
    final uri = Uri.parse(apiUrl('/api/update/photo'));

    try {
      final response = await http.patch(
        uri,
        headers: await _jsonHeaders(token: token),
        body: jsonEncode({
          'photo': _normalizeBase64Image(photo),
        }),
      );

      if (_isSuccess(response.statusCode)) {
        return _decodeResponse(response, 'data');
      }

      throw Exception(_errorMessage(response, 'Failed to update photo'));
    } catch (e) {
      throw Exception('Update photo error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    File? photo,
  }) async {
    final cleanName = name?.trim() ?? '';

    if (cleanName.isEmpty && photo == null) {
      return {
        'success': false,
        'message': 'No changes to update',
      };
    }

    Map<String, dynamic> result = {};

    if (cleanName.isNotEmpty) {
      result = await updateName(token: token, name: cleanName);
    }

    if (photo != null) {
      final photoResult = await updatePhoto(token: token, photo: photo);
      result = {...result, ...photoResult};
    }

    return result;
  }

  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
    required bool terminateSessions,
  }) async {
    final uri = Uri.parse(apiUrl('/api/password/change'));

    try {
      final response = await http.patch(
        uri,
        headers: await _jsonHeaders(token: token),
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
          'terminate_sessions': terminateSessions,
        }),
      );

      debugPrint('CHANGE PASSWORD STATUS: ${response.statusCode}');
      debugPrint('CHANGE PASSWORD BODY: ${response.body}');

      if (_isSuccess(response.statusCode)) {
        return _decodeResponse(response, 'data');
      }

      throw Exception(_errorMessage(response, 'Failed to change password'));
    } catch (e) {
      throw Exception('Change password error: $e');
    }
  }

  Future<Map<String, dynamic>> getCategories({String? token}) async {
    final paths = [
      '/api/categories',
      '/api/category',
    ];

    Object? lastError;

    for (final path in paths) {
      final uri = Uri.parse(apiUrl(path));

      try {
        final response = await http.get(
          uri,
          headers: await _authHeaders(token: token),
        );

        debugPrint('CATEGORIES URL: $uri');
        debugPrint('CATEGORIES STATUS: ${response.statusCode}');
        debugPrint('CATEGORIES BODY: ${response.body}');

        if (_isSuccess(response.statusCode)) {
          return _decodeResponse(response, 'categories');
        }

        lastError = _errorMessage(response, 'Failed to load categories');

        if (response.statusCode != 404) break;
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception('Categories error: $lastError');
  }

  Future<Map<String, dynamic>> getItems({
    String? token,
    required int page,
    required int perPage,
    int? categoryId,
    String search = '',
    String filter = 'all',
  }) async {
    final query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (categoryId != null && categoryId > 0) 'category_id': '$categoryId',
      if (filter.trim().isNotEmpty) 'filter': filter.trim(),
    };

    final paths = [
      '/api/items',
      '/api/books',
    ];

    Object? lastError;

    for (final path in paths) {
      final uri = Uri.parse(apiUrl(path)).replace(queryParameters: query);

      try {
        final response = await http.get(
          uri,
          headers: await _authHeaders(token: token),
        );

        debugPrint('ITEMS URL: $uri');
        debugPrint('ITEMS STATUS: ${response.statusCode}');
        debugPrint('ITEMS BODY: ${response.body}');

        if (_isSuccess(response.statusCode)) {
          return _decodeResponse(response, 'items');
        }

        lastError = _errorMessage(response, 'Failed to load books');

        if (response.statusCode != 404) break;
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception('Books error: $lastError');
  }

  Future<Map<String, dynamic>> getRecommendedBooks({
    String? token,
    int limit = 4,
  }) async {
    final uri = Uri.parse(apiUrl('/api/users/recommended-books')).replace(
      queryParameters: {'limit': '$limit'},
    );

    try {
      final response = await http.get(
        uri,
        headers: await _authHeaders(token: token),
      );

      debugPrint('RECOMMENDED URL: $uri');
      debugPrint('RECOMMENDED STATUS: ${response.statusCode}');
      debugPrint('RECOMMENDED BODY: ${response.body}');

      if (_isSuccess(response.statusCode)) {
        return _decodeResponse(response, 'books');
      }

      throw Exception(_errorMessage(response, 'Failed to load recommended books'));
    } catch (e) {
      throw Exception('Recommended books error: $e');
    }
  }
}