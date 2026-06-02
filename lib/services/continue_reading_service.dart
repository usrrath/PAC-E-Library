import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/continue_reading_book.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';
import '../utils/continue_reading_utils.dart';

class ContinueReadingService {
  final UserService _service = UserService();

  static List<ContinueReadingBook>? _cache;

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

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await http
        .get(
      Uri.parse(_service.apiUrl(path)),
      headers: await _headers(),
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final text = response.body.trim();
      if (text.isEmpty) return {};

      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      if (decoded is List) return {'data': decoded};

      return {};
    }

    throw Exception(errorMessage(response, 'Failed to load reading progress'));
  }

  Future<Map<String, dynamic>> _getProgressList() async {
    try {
      return await _get('/api/pdf-progress/pdf-progress-list');
    } catch (_) {
      return await _get('/api/pdf-progress-list');
    }
  }

  Future<List<ContinueReadingBook>> getContinueReadingBooks({
    bool refresh = false,
  }) async {
    if (!refresh && _cache != null) return _cache!;

    final response = await _getProgressList();

    final rows = extractList(response)
        .whereType<Map>()
        .map((e) => ContinueReadingBook.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.id.trim().isNotEmpty)
        .toList();

    final bestByBook = <String, ContinueReadingBook>{};

    for (final book in rows) {
      final old = bestByBook[book.id];

      if (old == null ||
          book.percent > old.percent ||
          (book.percent == old.percent && book.lastPage > old.lastPage)) {
        bestByBook[book.id] = book;
      }
    }

    final books = bestByBook.values.toList()
      ..sort((a, b) {
        final percentSort = b.percent.compareTo(a.percent);
        if (percentSort != 0) return percentSort;

        final pageSort = b.lastPage.compareTo(a.lastPage);
        if (pageSort != 0) return pageSort;

        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

    _cache = books;
    return books;
  }

  static void clearCache() {
    _cache = null;
  }
}