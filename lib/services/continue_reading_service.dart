import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/continue_reading_book.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';
import '../utils/continue_reading_utils.dart';

class ContinueReadingService {
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

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse(_service.apiUrl(path));
    final response = await http.get(uri, headers: await _headers());

    debugPrint('CONTINUE GET: $uri');
    debugPrint('CONTINUE STATUS: ${response.statusCode}');
    debugPrint('CONTINUE BODY: ${response.body}');

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

  Future<List<ContinueReadingBook>> getContinueReadingBooks() async {
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
          book.lastPage > old.lastPage ||
          (book.lastPage == old.lastPage && book.percent > old.percent)) {
        bestByBook[book.id] = book;
      }
    }

    return bestByBook.values.toList()
      ..sort((a, b) {
        final pageSort = b.lastPage.compareTo(a.lastPage);
        if (pageSort != 0) return pageSort;

        final percentSort = b.percent.compareTo(a.percent);
        if (percentSort != 0) return percentSort;

        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
  }
}