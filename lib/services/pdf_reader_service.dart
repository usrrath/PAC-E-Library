import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pdf_note_model.dart';
import '../services/base_url.dart';

class PdfReaderService {
  PdfReaderService({
    required this.bookId,
  });

  final String bookId;

  String token = '';
  String docKey = '';
  String pdfUrl = '';

  String get apiBase {
    final base = BaseURL.base.replaceAll(RegExp(r'/+$'), '');
    return base.endsWith('/api') ? base : '$base/api';
  }

  Map<String, String> get authHeaders {
    return {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> get pdfHeaders {
    return {
      ...authHeaders,
      'Accept': 'application/pdf,*/*',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    };
  }

  Future<void> initToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token') ??
        '';
  }

  Future<String> loadPdfUrl() async {
    final res = await http.get(
      Uri.parse('$apiBase/items/$bookId'),
      headers: authHeaders,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load item: ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    final dynamic item =
    decoded is Map && decoded['data'] is Map ? decoded['data'] : decoded;

    if (item is! Map) {
      throw Exception('Invalid item response');
    }

    final file = '${item['file_url'] ?? item['fileUrl'] ?? item['file'] ?? ''}'
        .trim();

    if (file.isEmpty || file == 'null') {
      throw Exception('PDF file not found');
    }

    pdfUrl = _normalizeUrl(file);
    docKey = sha256.convert(utf8.encode(pdfUrl)).toString();

    return pdfUrl;
  }

  String _normalizeUrl(String value) {
    final text = value.trim();
    final base = BaseURL.base.replaceAll(RegExp(r'/+$'), '');

    if (text.startsWith('http://') || text.startsWith('https://')) {
      return text;
    }

    if (text.startsWith('/')) {
      return '$base$text';
    }

    return '$base/storage/$text';
  }

  Future<File> getCacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/pdf_cache');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return File('${cacheDir.path}/$docKey.pdf');
  }

  Future<bool> isValidPdf(File file) async {
    if (!await file.exists()) return false;
    if (await file.length() < 1024) return false;

    final bytes = await file.openRead(0, 4).first;
    return latin1.decode(bytes, allowInvalid: true) == '%PDF';
  }

  Future<void> deleteCachedPdf() async {
    final file = await getCacheFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> downloadPdf({
    required void Function(double progress) onProgress,
  }) async {
    await deleteCachedPdf();

    final file = await getCacheFile();
    final request = http.Request('GET', Uri.parse(pdfUrl));
    request.headers.addAll(pdfHeaders);

    final response = await request.send();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('PDF download failed: ${response.statusCode}');
    }

    final sink = file.openWrite();
    final total = response.contentLength ?? 0;
    int received = 0;

    try {
      await for (final chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);

        if (total > 0) {
          onProgress((received / total).clamp(0.0, 1.0).toDouble());
        }
      }
    } finally {
      await sink.flush();
      await sink.close();
    }

    if (!await isValidPdf(file)) {
      await deleteCachedPdf();
      throw Exception('Invalid PDF file');
    }

    onProgress(1.0);
    return file;
  }

  Future<int> loadProgress() async {
    final itemId = int.tryParse(bookId);
    if (itemId == null || itemId <= 0) return 1;

    final res = await http.get(
      Uri.parse('$apiBase/pdf-progress?item_id=$itemId'),
      headers: {
        ...authHeaders,
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );

    if (res.statusCode != 200) return 1;

    final decoded = jsonDecode(res.body);
    Map<String, dynamic>? item;

    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('last_page')) {
        item = decoded;
      } else if (decoded['progress'] is Map<String, dynamic>) {
        item = decoded['progress'];
      } else if (decoded['data'] is Map<String, dynamic>) {
        item = decoded['data'];
      }
    }

    final page = int.tryParse('${item?['last_page'] ?? 1}') ?? 1;
    return page < 1 ? 1 : page;
  }

  Future<void> saveProgress({
    required int page,
    required int totalPages,
  }) async {
    if (totalPages <= 0) return;

    final itemId = int.tryParse(bookId);
    if (itemId == null || itemId <= 0) return;

    final safePage = page.clamp(1, totalPages);
    final percent = ((safePage / totalPages) * 100).clamp(0.0, 100.0);

    await http.post(
      Uri.parse('$apiBase/pdf-progress'),
      headers: {
        ...authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'item_id': itemId,
        'doc_key': docKey,
        'last_page': safePage,
        'total_pages': totalPages,
        'percent': percent.toStringAsFixed(2),
      }),
    );
  }

  Future<List<PdfNote>> loadNotes() async {
    final res = await http.get(
      Uri.parse('$apiBase/pdf-comment-highlights?item_id=$bookId&doc_key=$docKey'),
      headers: authHeaders,
    );

    if (res.statusCode != 200) return [];

    final decoded = jsonDecode(res.body);
    final List<dynamic> raw;

    if (decoded is List) {
      raw = decoded;
    } else if (decoded is Map && decoded['data'] is List) {
      raw = decoded['data'];
    } else {
      raw = [];
    }

    return raw
        .whereType<Map>()
        .map((e) => PdfNote.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveNote(PdfNote note) async {
    await http.post(
      Uri.parse('$apiBase/pdf-comment-highlights'),
      headers: {
        ...authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'item_id': bookId,
        'doc_key': docKey,
        'page_number': note.page,
        'selected_text': note.selectedText,
        'comment': note.comment,
        'highlight_color': note.color,
        'rects': <dynamic>[],
      }),
    );
  }

  String localPageKey() => 'pdf_last_page_${bookId}_$docKey';
  String bookmarkKey() => 'pdf_bookmarks_${bookId}_$docKey';
  String notesKey() => 'pdf_notes_${bookId}_$docKey';
}