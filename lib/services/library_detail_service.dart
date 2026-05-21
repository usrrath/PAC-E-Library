import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/library_detail_model.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';

class LibraryDetailService {
  final UserService _userService = UserService();

  String get base => _userService.base;

  Future<LibraryDetailModel> getBookDetail(String id) async {
    final cleanId = id.trim();

    if (cleanId.isEmpty) {
      throw Exception('Book ID not found.');
    }

    final headers = await _headers();

    for (final path in [
      '/api/item/$cleanId/show',
      '/api/items/$cleanId',
    ]) {
      final response = await http.get(
        Uri.parse(_apiUrl(path)),
        headers: headers,
      );

      if (_ok(response.statusCode)) {
        return LibraryDetailModel.fromJson(
          _extractMap(jsonDecode(response.body)),
        );
      }
    }

    throw Exception('Failed to load book details.');
  }

  Future<bool> checkFavorite(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) return false;

    final response = await http.get(
      Uri.parse(_apiUrl('/api/books/$cleanId/favorite/check')),
      headers: await _headers(),
    );

    if (!_ok(response.statusCode)) return false;

    return _bool(jsonDecode(response.body));
  }

  Future<bool> toggleFavorite({
    required String id,
    required bool isFavorite,
  }) async {
    final cleanId = id.trim();

    if (cleanId.isEmpty) {
      throw Exception('Book ID not found.');
    }

    final uri = Uri.parse(_apiUrl('/api/books/$cleanId/favorite'));
    final headers = await _headers();

    final response = isFavorite
        ? await http.delete(uri, headers: headers)
        : await http.post(uri, headers: headers);

    if (!_ok(response.statusCode)) {
      throw Exception('Failed to update favorite.');
    }

    return !isFavorite;
  }

  Future<List<LibraryDetailModel>> getSimilarTitles(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) return const [];

    final response = await http.get(
      Uri.parse(_apiUrl('/api/users/books/$cleanId/similar-titles?limit=6')),
      headers: await _headers(),
    );

    if (!_ok(response.statusCode)) return const [];

    final list = _extractList(jsonDecode(response.body));

    return list
        .map((e) => LibraryDetailModel.fromJson(_toMap(e)))
        .where((e) => e.id.isNotEmpty && e.id != cleanId)
        .toList();
  }

  String fullUrl(String value) {
    return ProfileService.fullUrl(value, base);
  }

  String _apiUrl(String path) {
    final cleanBase = base.replaceAll(RegExp(r'/+$'), '');

    final root = cleanBase.endsWith('/api')
        ? cleanBase.substring(0, cleanBase.length - 4)
        : cleanBase;

    return '$root$path';
  }

  Future<Map<String, String>> _headers() async {
    final token = await ProfileService.getToken();

    return {
      'Accept': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer ${token.trim()}',
    };
  }

  bool _ok(int statusCode) => statusCode >= 200 && statusCode < 300;

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      for (final key in const ['data', 'item', 'book']) {
        final value = map[key];
        if (value is Map) return Map<String, dynamic>.from(value);
      }

      return map;
    }

    return {};
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      for (final key in const [
        'data',
        'items',
        'books',
        'similar_titles',
        'similarTitles',
        'results',
      ]) {
        final value = map[key];

        if (value is List) return value;

        if (value is Map) {
          final nested = _extractList(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }

    return const [];
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  bool _bool(dynamic data) {
    if (data is bool) return data;
    if (data is num) return data == 1;

    if (data is String) {
      final value = data.toLowerCase().trim();

      return const [
        'true',
        '1',
        'yes',
        'saved',
        'favorited',
      ].contains(value);
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      for (final key in const [
        'is_favorite',
        'isFavorite',
        'favorite',
        'favorited',
        'saved',
      ]) {
        if (map.containsKey(key)) return _bool(map[key]);
      }

      if (map.containsKey('data')) return _bool(map['data']);
    }

    return false;
  }
}