import 'package:shared_preferences/shared_preferences.dart';

import '../models/book_mini_model.dart';

class ProfileService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token');
  }

  static Map<String, dynamic> toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static List<dynamic> extractList(dynamic response) {
    if (response is List) return response;

    final map = toMap(response);

    final data = map['data'] ??
        map['items'] ??
        map['books'] ??
        map['favorites'] ??
        map['favorite_books'] ??
        map['progress'] ??
        map['reading_progress'];

    if (data is List) return data;

    final nested = toMap(data);

    final nestedList = nested['data'] ??
        nested['items'] ??
        nested['books'] ??
        nested['favorites'] ??
        nested['reading_progress'];

    return nestedList is List ? nestedList : [];
  }

  static Map<String, dynamic> extractUser(dynamic response) {
    final map = toMap(response);

    final user = map['user'] ??
        toMap(map['data'])['user'] ??
        map['data'] ??
        map['account'] ??
        map['profile'];

    final userMap = toMap(user);

    if (userMap.isNotEmpty) return userMap;

    if (map.containsKey('id') ||
        map.containsKey('name') ||
        map.containsKey('email')) {
      return map;
    }

    return {};
  }

  static BookMini bookFromJson(
      Map<String, dynamic> json, {
        required String baseUrl,
      }) {
    final book = toMap(
      json['book'] ??
          json['item'] ??
          json['items'] ??
          json['favorite_book'] ??
          json['progress_book'] ??
          json['book_data'],
    );

    final source = book.isNotEmpty ? book : json;

    final isProgressRow = json.containsKey('item_id') ||
        json.containsKey('doc_key') ||
        json.containsKey('last_page') ||
        json.containsKey('total_pages');

    final id = isProgressRow
        ? _firstText([
      json['item_id'],
      source['item_id'],
      source['book_id'],
      source['id'],
    ])
        : _firstText([
      source['id'],
      json['id'],
      source['item_id'],
      json['item_id'],
      source['book_id'],
      json['book_id'],
    ]);

    final cover = _firstText([
      source['cover_url'],
      source['coverUrl'],
      source['cover'],
      source['thumbnail'],
      source['image'],
      json['cover_url'],
      json['coverUrl'],
      json['image'],
    ]);

    final file = _firstText([
      source['file_url'],
      source['fileUrl'],
      source['file'],
      source['pdf_url'],
      json['file_url'],
      json['fileUrl'],
      json['file'],
      json['pdf_url'],
    ]);

    final lastPage = _toInt(
      json['last_page'] ??
          json['current_page'] ??
          json['page'] ??
          source['last_page'],
    );

    final totalPages = _toInt(
      json['total_pages'] ??
          source['total_pages'] ??
          source['pages'] ??
          json['pages'],
    );

    return BookMini(
      id: id,
      title: _firstText([
        source['title'],
        json['title'],
        id.isEmpty ? 'Untitled' : 'Book #$id',
      ]),
      author: _authorName(source),
      category: _categoryName(source),
      description: _firstText([
        source['description'],
        json['description'],
        'No description available.',
      ]),
      coverUrl: fullUrl(cover, baseUrl),
      fileUrl: fullUrl(file, baseUrl),
      publishYear: _firstText([
        source['publish_year'],
        source['publishYear'],
        source['year'],
        json['publish_year'],
        json['year'],
      ]),
      progress: _progressValue(json, source, lastPage, totalPages),
      lastPage: lastPage,
      totalPages: totalPages,
    );
  }

  static String fullUrl(String value, String baseUrl) {
    final url = value.trim();

    if (url.isEmpty || url == 'null') return '';

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    final host = baseUrl
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceFirst(RegExp(r'/$'), '');

    if (url.startsWith('/storage/')) return '$host$url';
    if (url.startsWith('storage/')) return '$host/$url';
    if (url.startsWith('/')) return '$host$url';

    return '$host/storage/$url';
  }

  static String cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  static String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') return fallback;
    return text;
  }

  static String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = _text(value);
      if (text.isNotEmpty) return text;
    }

    return '';
  }

  static String _authorName(Map<String, dynamic> book) {
    final author = toMap(book['author'] ?? book['user']);

    return _text(
      author['name'] ?? book['author_name'] ?? book['author'],
      fallback: 'Unknown Author',
    );
  }

  static String _categoryName(Map<String, dynamic> book) {
    final category = toMap(book['category']);

    return _text(
      category['name'] ?? book['category_name'] ?? book['category'],
      fallback: 'Uncategorized',
    );
  }

  static double _progressValue(
      Map<String, dynamic> json,
      Map<String, dynamic> book,
      int lastPage,
      int totalPages,
      ) {
    final direct = _firstProgress([
      json['percent'],
      json['progress'],
      json['progress_value'],
      json['percent_read'],
      json['reading_percentage'],
      book['percent'],
      book['progress'],
      book['reading_percentage'],
    ]);

    if (direct > 0) return direct;

    if (lastPage > 0 && totalPages > 0) {
      return (lastPage / totalPages).clamp(0.0, 1.0).toDouble();
    }

    return 0.0;
  }

  static double _firstProgress(List<dynamic> values) {
    for (final value in values) {
      final progress = _progress(value);
      if (progress > 0) return progress;
    }

    return 0.0;
  }

  static double _progress(dynamic value) {
    if (value == null) return 0.0;

    var text = value.toString().trim();

    if (text.isEmpty || text == 'null') return 0.0;

    text = text.replaceAll('%', '').replaceAll(',', '');

    final number = double.tryParse(text) ?? 0.0;

    if (number <= 0) return 0.0;

    if (number > 0) {
      return (number / 100).clamp(0.0, 1.0).toDouble();
    }

    return number.clamp(0.0, 1.0).toDouble();
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') return 0;

    return int.tryParse(text) ?? 0;
  }
}