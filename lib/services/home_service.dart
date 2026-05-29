import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/home_models.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';

class HomeData {
  final List<HomeBook> recommended;
  final List<HomeBook> popular;
  final List<HomeBook> newReleases;
  final List<HomeNotification> notifications;
  final List<Map<String, dynamic>> progress;

  const HomeData({
    required this.recommended,
    required this.popular,
    required this.newReleases,
    required this.notifications,
    required this.progress,
  });
}

class HomeService {
  final UserService _service = UserService();

  Future<String> _token() async {
    return (await ProfileService.getToken())?.trim() ?? '';
  }

  Future<Map<String, String>> _headers() async {
    final token = await _token();

    return {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _get(
      String path, {
        Map<String, String>? query,
      }) async {
    final uri = Uri.parse(_service.apiUrl(path)).replace(
      queryParameters: query,
    );

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _decode(response.body);
    }

    throw Exception('Failed to load data (${response.statusCode})');
  }

  Future<Map<String, dynamic>> _post(String path) async {
    final response = await http.post(
      Uri.parse(_service.apiUrl(path)),
      headers: await _headers(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _decode(response.body);
    }

    throw Exception('Failed to update (${response.statusCode})');
  }

  Future<Map<String, dynamic>> _getProgressList() async {
    try {
      return await _get('/api/pdf-progress/pdf-progress-list');
    } catch (_) {
      return await _get('/api/pdf-progress-list');
    }
  }

  Future<HomeData> loadHome() async {
    final results = await Future.wait([
      _get('/api/users/recommended-overall-books', query: {'limit': '8'}),
      _get('/api/items', query: {
        'per_page': '8',
        'filter': 'popular_section',
      }),
      _get('/api/items', query: {
        'per_page': '8',
        'filter': 'new_release_section',
      }),
      _get('/api/notifications'),
      _getProgressList(),
    ]);

    final recommended = _parseBooks(results[0]);
    final popular = _parseBooks(results[1]);
    final newReleases = _parseBooks(results[2]);

    recommended.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    popular.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));

    return HomeData(
      recommended: recommended,
      popular: popular,
      newReleases: newReleases,
      notifications: _parseNotifications(results[3]),
      progress: _extractList(results[4])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Future<void> toggleFavorite(String bookId) async {
    await _post('/api/books/$bookId/favorite');
  }

  List<HomeBook> _parseBooks(Map<String, dynamic> response) {
    return _extractList(response)
        .whereType<Map>()
        .map((e) => HomeBook.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.id.isNotEmpty)
        .map(_fixBookUrls)
        .toList();
  }

  HomeBook _fixBookUrls(HomeBook book) {
    return book.copyWith(
      coverUrl: _assetUrl(book.coverUrl),
      fileUrl: _assetUrl(book.fileUrl),
    );
  }

  String _assetUrl(String value) {
    var text = value.trim();

    if (text.isEmpty) return '';

    text = text.replaceAll('\\', '/');

    if (text.startsWith('http://') || text.startsWith('https://')) {
      return text;
    }

    if (text.startsWith('public/')) {
      text = text.replaceFirst('public/', 'storage/');
    }

    if (!text.startsWith('/')) {
      text = '/$text';
    }

    if (!text.startsWith('/storage/') &&
        !text.startsWith('/uploads/') &&
        !text.startsWith('/images/')) {
      text = '/storage${text.startsWith('/') ? text : '/$text'}';
    }

    return _service.apiUrl(text);
  }
}

Map<String, dynamic> _decode(String source) {
  final text = source.trim();
  if (text.isEmpty) return {};

  final decoded = jsonDecode(text);

  if (decoded is Map<String, dynamic>) return decoded;
  if (decoded is Map) return Map<String, dynamic>.from(decoded);
  if (decoded is List) return {'data': decoded};

  return {};
}

List<HomeNotification> _parseNotifications(Map<String, dynamic> response) {
  return _extractList(response)
      .whereType<Map>()
      .map((e) => HomeNotification.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

List<dynamic> _extractList(dynamic decoded) {
  if (decoded is List) return decoded;

  if (decoded is Map) {
    final data = decoded['data'];

    if (data is List) return data;

    if (data is Map) {
      for (final key in [
        'data',
        'items',
        'books',
        'recommended',
        'recommended_books',
        'popular',
        'new_releases',
        'notifications',
        'progress',
      ]) {
        if (data[key] is List) return data[key];
      }
    }

    for (final key in [
      'items',
      'books',
      'recommended',
      'recommended_books',
      'popular',
      'new_releases',
      'notifications',
      'progress',
      'favorites',
      'result',
      'results',
    ]) {
      if (decoded[key] is List) return decoded[key];
    }
  }

  return [];
}