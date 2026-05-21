import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import '../models/pdf_note_model.dart';
import 'base_url.dart';

class PdfReaderService {
  PdfReaderService({required this.bookId});

  final String bookId;

  String _token = '';
  String _pdfUrl = '';

  int get itemId => int.tryParse(bookId) ?? 0;

  static final CacheManager _pdfCacheManager = CacheManager(
    Config(
      'pac_pdf_cache_v1',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 60,
    ),
  );

  String get apiBase {
    final base = BaseURL.base.replaceAll(RegExp(r'/+$'), '');
    return base.endsWith('/api') ? base : '$base/api';
  }

  Map<String, String> get authHeaders => {
    'Accept': 'application/json',
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache',
    if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
  };

  Map<String, String> get jsonHeaders => {
    ...authHeaders,
    'Content-Type': 'application/json',
  };

  Map<String, String> get pdfHeaders => {
    ...authHeaders,
    'Accept': 'application/pdf,*/*',
  };

  String get _cacheKey => 'pdf_item_$itemId';

  void _debug(String message) {
    if (kDebugMode) debugPrint('PDF_READER_DEBUG: $message');
  }

  Future<void> initToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token') ??
        '';
    _debug('TOKEN EXISTS: ${_token.isNotEmpty}');
  }

  Future<String> loadPdfUrl() async {
    if (itemId <= 0) throw Exception('Invalid item id');

    final uri = Uri.parse('$apiBase/items/$itemId');
    _debug('GET ITEM: $uri');

    final res = await http.get(uri, headers: authHeaders);
    _debug('ITEM STATUS: ${res.statusCode}');
    _debug('ITEM BODY: ${_shortBody(res.body)}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load item: ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    final item = decoded is Map && decoded['data'] is Map ? decoded['data'] : decoded;
    if (item is! Map) throw Exception('Invalid item response');

    final file = '${item['file_url'] ?? item['fileUrl'] ?? item['file'] ?? ''}'.trim();
    if (file.isEmpty || file == 'null') throw Exception('PDF file not found');

    _pdfUrl = _normalizeUrl(file);
    _debug('PDF URL: $_pdfUrl');
    return _pdfUrl;
  }

  String _normalizeUrl(String value) {
    final text = value.trim();
    final base = BaseURL.base.replaceAll(RegExp(r'/+$'), '');

    if (text.startsWith('http://') || text.startsWith('https://')) return text;
    if (text.startsWith('/')) return '$base$text';

    return '$base/storage/$text';
  }

  Future<File?> getCachedPdf() async {
    final cached = await _pdfCacheManager.getFileFromCache(_cacheKey);
    final file = cached?.file;
    if (file == null) return null;
    return await isValidPdf(file) ? file : null;
  }

  Future<bool> isValidPdf(File file) async {
    try {
      if (!await file.exists()) return false;
      if (await file.length() < 1024) return false;
      final bytes = await file.openRead(0, 4).first;
      return latin1.decode(bytes, allowInvalid: true) == '%PDF';
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteCachedPdf() async {
    await _pdfCacheManager.removeFile(_cacheKey);
  }

  Future<File> downloadPdf({
    required void Function(double progress) onProgress,
  }) async {
    if (_pdfUrl.isEmpty) throw Exception('PDF URL is empty');

    await deleteCachedPdf();

    final request = http.Request('GET', Uri.parse(_pdfUrl));
    request.headers.addAll(pdfHeaders);

    _debug('DOWNLOAD PDF: $_pdfUrl');

    final response = await request.send();
    _debug('PDF DOWNLOAD STATUS: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('PDF download failed: ${response.statusCode}');
    }

    final total = response.contentLength ?? 0;
    var received = 0;
    final chunks = <int>[];

    await for (final chunk in response.stream) {
      received += chunk.length;
      chunks.addAll(chunk);

      if (total > 0) {
        onProgress(
          (received / total).clamp(0.0, 1.0).toDouble(),
        );
      }
    }

    final file = await _pdfCacheManager.putFile(
      _pdfUrl,
      Uint8List.fromList(chunks),
      key: _cacheKey,
      fileExtension: 'pdf',
    );

    if (!await isValidPdf(file)) {
      await deleteCachedPdf();
      throw Exception('Invalid PDF file');
    }

    onProgress(1.0);
    return file;
  }

  Future<int> loadProgress() async {
    if (itemId <= 0) return 1;

    final uri = Uri.parse('$apiBase/pdf-progress').replace(
      queryParameters: {'item_id': itemId.toString()},
    );

    _debug('GET PROGRESS: $uri');

    final res = await http.get(uri, headers: authHeaders);
    _debug('PROGRESS STATUS: ${res.statusCode}');
    _debug('PROGRESS BODY: ${_shortBody(res.body)}');

    if (res.statusCode != 200) return 1;

    final decoded = jsonDecode(res.body);
    Map<String, dynamic>? row;

    if (decoded is Map<String, dynamic>) {
      if (decoded['last_page'] != null) {
        row = decoded;
      } else if (decoded['progress'] is Map) {
        row = Map<String, dynamic>.from(decoded['progress']);
      } else if (decoded['data'] is Map) {
        row = Map<String, dynamic>.from(decoded['data']);
      }
    }

    final page = int.tryParse('${row?['last_page'] ?? 1}') ?? 1;
    return page < 1 ? 1 : page;
  }

  Future<void> saveProgress({
    required int page,
    required int totalPages,
  }) async {
    if (itemId <= 0 || totalPages <= 0) return;

    final safePage = page.clamp(1, totalPages);
    final percent = ((safePage / totalPages) * 100).clamp(0.0, 100.0);

    final body = {
      'item_id': itemId,
      'last_page': safePage,
      'total_pages': totalPages,
      'percent': percent.toStringAsFixed(2),
    };

    final res = await http.post(
      Uri.parse('$apiBase/pdf-progress'),
      headers: jsonHeaders,
      body: jsonEncode(body),
    );

    _debug('SAVE PROGRESS STATUS: ${res.statusCode}');
    _debug('SAVE PROGRESS BODY: ${_shortBody(res.body)}');
  }

  Future<List<PdfNote>> loadNotes() async {
    if (itemId <= 0) return const [];

    final uri = Uri.parse('$apiBase/pdf-comment-highlights').replace(
      queryParameters: {'item_id': itemId.toString()},
    );

    final res = await http.get(uri, headers: authHeaders);
    _debug('GET NOTES STATUS: ${res.statusCode}');
    _debug('GET NOTES BODY: ${_shortBody(res.body)}');

    if (res.statusCode != 200) return const [];

    final decoded = jsonDecode(res.body);
    final rows = decoded is Map && decoded['data'] is List
        ? decoded['data'] as List
        : decoded is List
        ? decoded
        : const <dynamic>[];

    return rows
        .whereType<Map>()
        .map((e) => PdfNote.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => !e.isEmpty && e.hasRects)
        .toList(growable: false);
  }

  Future<bool> saveNote(PdfNote note) async {
    if (itemId <= 0) return false;

    final body = {
      'item_id': itemId,
      'page': note.page,
      'page_number': note.page,
      'selected_text': note.selectedText,
      'comment': note.comment,
      'highlight_color': note.color,
      'type': note.type,
      'annotation_type': note.type,
      'rects': note.rects.map((e) => e.toJson()).toList(growable: false),
    };

    _debug('SAVE NOTE BODY: ${jsonEncode(body)}');

    try {
      final res = await http.post(
        Uri.parse('$apiBase/pdf-comment-highlights'),
        headers: jsonHeaders,
        body: jsonEncode(body),
      );

      _debug('SAVE NOTE STATUS: ${res.statusCode}');
      _debug('SAVE NOTE RESPONSE: ${_shortBody(res.body)}');

      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      _debug('SAVE NOTE ERROR: $e');
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    final id = int.tryParse(noteId);
    if (id == null || id <= 0) return false;

    try {
      final res = await http.delete(
        Uri.parse('$apiBase/pdf-comment-highlights/$id'),
        headers: authHeaders,
      );

      _debug('DELETE NOTE STATUS: ${res.statusCode}');
      _debug('DELETE NOTE RESPONSE: ${_shortBody(res.body)}');

      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      _debug('DELETE NOTE ERROR: $e');
      return false;
    }
  }

  String localPageKey() => 'pdf_last_page_$itemId';
  String bookmarkKey() => 'pdf_bookmarks_$itemId';
  String notesKey() => 'pdf_notes_$itemId';

  String _shortBody(String body) {
    if (body.length <= 800) return body;
    return '${body.substring(0, 800)}...';
  }
}
