import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/success_user.dart';
import 'base_url.dart';
import 'profile_service.dart';

class LoginStartResult {
  final SuccessUser? user;
  final bool twoFactorRequired;
  final String tempToken;
  final String message;

  const LoginStartResult({
    required this.user,
    required this.twoFactorRequired,
    required this.tempToken,
    required this.message,
  });

  bool get completed => user != null && !twoFactorRequired;
}

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

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

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

      if (text.isEmpty) {
        return '$fallback (${response.statusCode})';
      }

      final body = jsonDecode(text);

      if (body is Map) {
        final message = body['message'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }

        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;

          if (first is List && first.isNotEmpty) {
            return first.first.toString();
          }

          return first.toString();
        }
      }
    } catch (_) {}

    return '$fallback (${response.statusCode})';
  }

  Map<String, dynamic> _decodeResponse(
      http.Response response,
      String listKey,
      ) {
    final text = response.body.trim();

    if (text.isEmpty) {
      return {listKey: []};
    }

    final body = jsonDecode(text);

    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    if (body is List) return {listKey: body};

    return {listKey: []};
  }

  String _stringValue(Map<String, dynamic> body, List<String> keys) {
    for (final key in keys) {
      final value = body[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }

      final data = body['data'];
      if (data is Map && data[key] != null) {
        final dataValue = data[key].toString().trim();
        if (dataValue.isNotEmpty) return dataValue;
      }
    }

    return '';
  }

  bool _boolValue(Map<String, dynamic> body, List<String> keys) {
    for (final key in keys) {
      if (body[key] == true) return true;

      final data = body['data'];
      if (data is Map && data[key] == true) return true;
    }

    return false;
  }

  String _normalizeBase64Image(File photo) {
    final bytes = photo.readAsBytesSync();
    final base64String = base64Encode(bytes);
    final ext = photo.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'png' : 'jpeg';

    return 'data:image/$mime;base64,$base64String';
  }

  Future<LoginStartResult> login(
      String username,
      String password, {
        required Map<String, String> deviceInfo,
      }) async {
    final uri = Uri.parse(apiUrl('/api/signin'));

    try {
      final body = {
        'username': username.trim(),
        'email': username.trim(),
        'password': password,
        ...deviceInfo,
      };

      debugPrint('LOGIN URL: $uri');
      debugPrint('LOGIN BODY SEND: $body');

      final response = await http.post(
        uri,
        headers: await _jsonHeaders(),
        body: jsonEncode(body),
      );

      debugPrint('LOGIN STATUS: ${response.statusCode}');
      debugPrint('LOGIN BODY: ${response.body}');

      final decoded = _decodeResponse(response, 'data');

      final twoFactorRequired = _boolValue(decoded, [
        'two_factor_required',
        'requires_2fa',
        'require_2fa',
        '2fa_required',
      ]);

      if (twoFactorRequired) {
        return LoginStartResult(
          user: null,
          twoFactorRequired: true,
          tempToken: _stringValue(decoded, [
            'temp_token',
            'login_token',
            'two_factor_token',
            'two_factor_session',
          ]),
          message: _stringValue(decoded, ['message']).isNotEmpty
              ? _stringValue(decoded, ['message'])
              : 'Two-factor authentication required',
        );
      }

      if (_isSuccess(response.statusCode)) {
        final user = await compute(successUserFromJson, response.body);

        return LoginStartResult(
          user: user,
          twoFactorRequired: false,
          tempToken: '',
          message: 'Login successful',
        );
      }

      throw Exception(_errorMessage(response, 'Login failed'));
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<SuccessUser> verifyTwoFactorLogin({
    required String username,
    required String password,
    required String code,
    required String tempToken,
    required Map<String, String> deviceInfo,
  }) async {
    final paths = [
      '/api/2fa/login/verify',
      '/api/2fa/verify-login',
      '/api/signin/2fa',
      '/api/signin',
    ];

    Object? lastError;

    for (final path in paths) {
      try {
        final uri = Uri.parse(apiUrl(path));

        final body = {
          'username': username.trim(),
          'email': username.trim(),
          'password': password,
          'code': code.trim(),
          'otp': code.trim(),
          'two_factor_code': code.trim(),
          if (tempToken.trim().isNotEmpty) 'temp_token': tempToken.trim(),
          if (tempToken.trim().isNotEmpty) 'login_token': tempToken.trim(),
          ...deviceInfo,
        };

        debugPrint('2FA LOGIN URL: $uri');
        debugPrint('2FA LOGIN BODY SEND: $body');

        final response = await http.post(
          uri,
          headers: await _jsonHeaders(),
          body: jsonEncode(body),
        );

        debugPrint('2FA LOGIN STATUS: ${response.statusCode}');
        debugPrint('2FA LOGIN BODY: ${response.body}');

        if (_isSuccess(response.statusCode)) {
          return compute(successUserFromJson, response.body);
        }

        lastError = _errorMessage(response, 'Invalid 2FA code');

        if (response.statusCode != 404) break;
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception(lastError ?? 'Invalid 2FA code');
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

    if (cleanName.isEmpty) {
      throw Exception('Name is required');
    }

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

      throw Exception(
        _errorMessage(response, 'Failed to load recommended books'),
      );
    } catch (e) {
      throw Exception('Recommended books error: $e');
    }
  }

  Future<Map<String, dynamic>> getTrendingSearches({
    String? token,
    int limit = 10,
  }) async {
    final uri = Uri.parse(apiUrl('/api/search/trending')).replace(
      queryParameters: {'limit': '$limit'},
    );

    final response = await http.get(
      uri,
      headers: await _authHeaders(token: token),
    );

    debugPrint('TRENDING SEARCH URL: $uri');
    debugPrint('TRENDING SEARCH STATUS: ${response.statusCode}');
    debugPrint('TRENDING SEARCH BODY: ${response.body}');

    if (_isSuccess(response.statusCode)) {
      return _decodeResponse(response, 'data');
    }

    throw Exception(
      _errorMessage(response, 'Failed to load trending searches'),
    );
  }

  Future<Map<String, dynamic>> getSuggestedBooks({
    String? token,
    int limit = 8,
  }) async {
    final uri = Uri.parse(apiUrl('/api/search/suggested')).replace(
      queryParameters: {'limit': '$limit'},
    );

    final response = await http.get(
      uri,
      headers: await _authHeaders(token: token),
    );

    debugPrint('SUGGESTED BOOKS URL: $uri');
    debugPrint('SUGGESTED BOOKS STATUS: ${response.statusCode}');
    debugPrint('SUGGESTED BOOKS BODY: ${response.body}');

    if (_isSuccess(response.statusCode)) {
      return _decodeResponse(response, 'books');
    }

    throw Exception(
      _errorMessage(response, 'Failed to load suggested books'),
    );
  }

  Future<Map<String, dynamic>> getBookViewsCount({
    String? token,
    required String bookId,
  }) async {
    final uri = Uri.parse(apiUrl('/api/books/$bookId/views/count'));

    final response = await http.get(
      uri,
      headers: await _authHeaders(token: token),
    );

    debugPrint('BOOK VIEWS COUNT URL: $uri');
    debugPrint('BOOK VIEWS COUNT STATUS: ${response.statusCode}');
    debugPrint('BOOK VIEWS COUNT BODY: ${response.body}');

    if (_isSuccess(response.statusCode)) {
      return _decodeResponse(response, 'data');
    }

    throw Exception(
      _errorMessage(response, 'Failed to load book views count'),
    );
  }

  Future<Map<String, dynamic>> setupTwoFactor({String? token}) async {
    final uri = Uri.parse(apiUrl('/api/2fa/setup'));

    final response = await http.post(
      uri,
      headers: await _authHeaders(token: token),
    );

    debugPrint('2FA SETUP STATUS: ${response.statusCode}');
    debugPrint('2FA SETUP BODY: ${response.body}');

    if (_isSuccess(response.statusCode)) {
      return _decodeResponse(response, 'data');
    }

    throw Exception(_errorMessage(response, 'Failed to setup 2FA'));
  }

  Future<Map<String, dynamic>> verifyTwoFactor({
    String? token,
    required String code,
  }) async {
    final uri = Uri.parse(apiUrl('/api/2fa/verify'));

    final response = await http.post(
      uri,
      headers: await _jsonHeaders(token: token),
      body: jsonEncode({'code': code.trim()}),
    );

    debugPrint('2FA VERIFY STATUS: ${response.statusCode}');
    debugPrint('2FA VERIFY BODY: ${response.body}');

    if (_isSuccess(response.statusCode)) {
      return _decodeResponse(response, 'data');
    }

    throw Exception(_errorMessage(response, 'Invalid 2FA code'));
  }

  Future<Map<String, dynamic>> disableTwoFactor({
    String? token,
    required String code,
  }) async {
    final uri = Uri.parse(apiUrl('/api/2fa/disable'));

    final response = await http.post(
      uri,
      headers: await _jsonHeaders(token: token),
      body: jsonEncode({'code': code.trim()}),
    );

    debugPrint('2FA DISABLE STATUS: ${response.statusCode}');
    debugPrint('2FA DISABLE BODY: ${response.body}');

    if (_isSuccess(response.statusCode)) {
      return _decodeResponse(response, 'data');
    }

    throw Exception(_errorMessage(response, 'Failed to disable 2FA'));
  }

  Future<bool> getTwoFactorStatus({String? token}) async {
    final uri = Uri.parse(apiUrl('/api/2fa/status'));

    final response = await http.get(
      uri,
      headers: await _authHeaders(token: token),
    );

    debugPrint('2FA STATUS: ${response.statusCode}');
    debugPrint('2FA BODY: ${response.body}');

    if (_isSuccess(response.statusCode)) {
      final body = _decodeResponse(response, 'data');

      return _boolValue(body, [
        'enabled',
        'two_factor_enabled',
        'is_2fa_enabled',
      ]);
    }

    return false;
  }
}