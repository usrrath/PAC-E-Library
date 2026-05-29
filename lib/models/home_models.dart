import '../models/library_models.dart';
import '../services/library_detail_service.dart';

class HomeBook {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String category;
  final String fileUrl;
  final int viewsCount;
  final bool isFavorite;
  final List<String> tags;

  const HomeBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.category,
    required this.fileUrl,
    required this.viewsCount,
    required this.isFavorite,
    this.tags = const [],
  });

  HomeBook copyWith({
    String? coverUrl,
    String? fileUrl,
    String? category,
    List<String>? tags,
    int? viewsCount,
  }) {
    return HomeBook(
      id: id,
      title: title,
      author: author,
      coverUrl: coverUrl ?? this.coverUrl,
      category: category ?? this.category,
      fileUrl: fileUrl ?? this.fileUrl,
      viewsCount: viewsCount ?? this.viewsCount,
      isFavorite: isFavorite,
      tags: tags ?? this.tags,
    );
  }

  factory HomeBook.fromJson(Map<String, dynamic> json) {
    final map = _unwrapBook(json);

    return HomeBook(
      id: _text(map, ['id', 'book_id', 'item_id']),
      title: _text(map, ['title', 'name'], fallback: 'Untitled'),
      author: _author(map),
      coverUrl: _text(map, [
        'cover_url',
        'cover',
        'image',
        'image_url',
        'thumbnail',
        'thumbnail_url',
      ]),
      category: _category(map),
      fileUrl: _text(map, ['file_url', 'file', 'pdf', 'pdf_url']),
      viewsCount: _int(map, [
        'views_count',
        'view_count',
        'views',
        'total_views',
        'reads_count',
      ]),
      isFavorite: map['is_favorite'] == true || map['favorite'] == true,
      tags: _tags(map['tags']),
    );
  }

  Book toDetailBook(LibraryDetailService detailService) {
    return Book.fromJson({
      'id': id,
      'title': title,
      'author_name': author,
      'cover_url': coverUrl,
      'file_url': fileUrl,
      'category_name': category,
      'tags': tags,
      'views_count': viewsCount,
    }, detailService);
  }
}

class HomeNotification {
  final String id;
  final String title;
  final String message;
  final bool read;

  const HomeNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
  });

  factory HomeNotification.fromJson(Map<String, dynamic> json) {
    return HomeNotification(
      id: _text(json, ['id']),
      title: _text(json, ['title'], fallback: 'Notification'),
      message: _text(json, ['message', 'body']),
      read: json['read_at'] != null || json['read'] == true,
    );
  }
}

Map<String, dynamic> _unwrapBook(Map<String, dynamic> json) {
  for (final key in ['book', 'item', 'data']) {
    final value = json[key];
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
  }
  return json;
}

String _text(
    Map<String, dynamic> json,
    List<String> keys, {
      String fallback = '',
    }) {
  for (final key in keys) {
    final value = json[key];

    if (value == null) continue;

    if (value is Map) {
      final name = value['name'] ?? value['title'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
      continue;
    }

    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }

  return fallback;
}

int _int(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;

    if (value is int) return value;
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  }

  return 0;
}

String _author(Map<String, dynamic> json) {
  final author = json['author'];

  if (author is Map) {
    return _text(
      Map<String, dynamic>.from(author),
      ['name', 'username', 'full_name'],
      fallback: 'Unknown Author',
    );
  }

  return _text(
    json,
    ['author_name', 'author', 'writer', 'created_by_name'],
    fallback: 'Unknown Author',
  );
}

String _category(Map<String, dynamic> json) {
  final category = json['category'];

  if (category is Map) {
    return _text(
      Map<String, dynamic>.from(category),
      ['name', 'title', 'category_name'],
    );
  }

  return _text(json, ['category_name', 'category']);
}

List<String> _tags(dynamic value) {
  if (value is! List) return [];

  final result = <String>[];

  for (final item in value) {
    String text = '';

    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      final tag = map['tag'];

      if (tag is Map) {
        text = _text(Map<String, dynamic>.from(tag), ['name', 'title']);
      } else {
        text = _text(map, ['name', 'title', 'tag_name']);
      }
    } else {
      text = item.toString().trim();
    }

    if (text.isEmpty) continue;
    if (text.startsWith('{') || text.startsWith('[')) continue;

    result.add(text);
  }

  return result.toSet().toList();
}