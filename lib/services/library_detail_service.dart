import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/library_detail_model.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';

class LibraryDetailService {
  final UserService _userService = UserService();

  String get base => _userService.base;

  Future<LibraryDetailModel> getBookDetail(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) throw Exception('Book ID not found.');

    final headers = await _headers();

    for (final path in [
      '/api/item/$cleanId/show',
      '/api/items/$cleanId',
      '/api/books/$cleanId',
    ]) {
      final uri = Uri.parse(_apiUrl(path));
      final response = await http.get(uri, headers: headers);

      debugPrint('BOOK DETAIL URL: $uri');
      debugPrint('BOOK DETAIL STATUS: ${response.statusCode}');

      if (_ok(response.statusCode)) {
        final decoded = _safeDecode(response.body);
        return LibraryDetailModel.fromJson(_extractMap(decoded));
      }
    }

    throw Exception('Failed to load book details.');
  }

  Future<bool> checkFavorite(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) return false;

    final uri = Uri.parse(_apiUrl('/api/books/$cleanId/favorite/check'));
    final response = await http.get(uri, headers: await _headers());

    debugPrint('CHECK FAVORITE URL: $uri');
    debugPrint('CHECK FAVORITE STATUS: ${response.statusCode}');

    if (!_ok(response.statusCode)) return false;

    return _bool(_safeDecode(response.body));
  }

  Future<bool> toggleFavorite({
    required String id,
    required bool isFavorite,
  }) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) throw Exception('Book ID not found.');

    final uri = Uri.parse(_apiUrl('/api/books/$cleanId/favorite'));
    final headers = await _headers();

    final response = isFavorite
        ? await http.delete(uri, headers: headers)
        : await http.post(uri, headers: headers);

    debugPrint('TOGGLE FAVORITE URL: $uri');
    debugPrint('TOGGLE FAVORITE STATUS: ${response.statusCode}');

    if (!_ok(response.statusCode)) {
      throw Exception('Failed to update favorite.');
    }

    return !isFavorite;
  }

  Future<List<LibraryDetailModel>> getSimilarTitles(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) return const [];

    final headers = await _headers();

    final paths = [
      '/api/users/books/$cleanId/similar-titles?limit=6',
      '/api/books/$cleanId/similar-titles?limit=6',
      '/api/items/$cleanId/similar-titles?limit=6',
      '/api/users/books/$cleanId/similarTitles?limit=6',
    ];

    for (final path in paths) {
      final uri = Uri.parse(_apiUrl(path));

      try {
        final response = await http.get(uri, headers: headers);

        debugPrint('SIMILAR TITLES URL: $uri');
        debugPrint('SIMILAR TITLES STATUS: ${response.statusCode}');
        debugPrint('SIMILAR TITLES BODY: ${response.body}');

        if (!_ok(response.statusCode)) continue;

        final decoded = _safeDecode(response.body);
        final list = _extractList(decoded);

        final books = list
            .map((e) => LibraryDetailModel.fromJson(_toMap(e)))
            .where((book) {
          final bookId = book.id.trim();
          return bookId.isNotEmpty && bookId != cleanId;
        })
            .toList();

        if (books.isNotEmpty) return books;
      } catch (e) {
        debugPrint('SIMILAR TITLES ERROR: $e');
      }
    }

    return const [];
  }

  String fullUrl(String value) {
    return ProfileService.fullUrl(value, base);
  }

  String _apiUrl(String path) {
    final cleanBase = base.replaceAll(RegExp(r'/+$'), '');

    final root = cleanBase.endsWith('/api')
        ? cleanBase.substring(0, cleanBase.length - 4)
        : cleanBase;

    final cleanPath = path.startsWith('/') ? path : '/$path';

    return '$root$cleanPath';
  }

  Future<Map<String, String>> _headers() async {
    final token = await ProfileService.getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer ${token.trim()}',
    };
  }

  bool _ok(int statusCode) => statusCode >= 200 && statusCode < 300;

  dynamic _safeDecode(String body) {
    try {
      if (body.trim().isEmpty) return {};
      return jsonDecode(body);
    } catch (_) {
      return {};
    }
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is! Map) return {};

    final map = Map<String, dynamic>.from(data);

    for (final key in const [
      'data',
      'item',
      'book',
      'result',
    ]) {
      final value = map[key];
      if (value is Map) return Map<String, dynamic>.from(value);
    }

    return map;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is! Map) return const [];

    final map = Map<String, dynamic>.from(data);

    for (final key in const [
      'data',
      'items',
      'books',
      'similar_titles',
      'similarTitles',
      'similar',
      'recommendations',
      'recommended',
      'results',
      'result',
    ]) {
      final value = map[key];

      if (value is List) return value;

      if (value is Map) {
        final nested = _extractList(value);
        if (nested.isNotEmpty) return nested;
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
        'favorite',
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
        'status',
      ]) {
        if (map.containsKey(key)) return _bool(map[key]);
      }

      if (map.containsKey('data')) return _bool(map['data']);
    }

    return false;
  }
}