class LibraryDetailModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final String year;
  final List<String> categories;
  final List<String> tags;

  const LibraryDetailModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.fileUrl,
    required this.year,
    required this.categories,
    required this.tags,
  });

  factory LibraryDetailModel.fromJson(Map<String, dynamic> json) {
    final title = _string(json, const ['title', 'name']);
    final author = _author(json);
    final description = _string(json, const ['description', 'summary']);

    return LibraryDetailModel(
      id: _string(json, const ['id', 'book_id', 'item_id']),
      title: title.isEmpty ? 'Untitled' : title,
      author: author.isEmpty ? 'Unknown Author' : author,
      description:
      description.isEmpty ? 'No description available.' : description,
      coverUrl: _string(json, const [
        'cover_url',
        'cover',
        'image',
        'image_url',
      ]),
      fileUrl: _string(json, const [
        'file_url',
        'file',
        'pdf',
        'pdf_url',
      ]),
      year: _string(json, const ['publish_year', 'year']),
      categories: _list(json, const ['categories', 'category']),
      tags: _list(json, const ['tags', 'tag', 'book_tags']),
    );
  }

  static String _author(Map<String, dynamic> json) {
    final direct = _string(json, const ['author_name', 'writer']);
    if (direct.isNotEmpty) return direct;

    for (final key in const ['author', 'user']) {
      final value = json[key];

      if (value is String) return value.trim();

      if (value is Map) {
        final name = _string(
          Map<String, dynamic>.from(value),
          const ['name', 'full_name', 'email'],
        );

        if (name.isNotEmpty) return name;
      }
    }

    return '';
  }

  static String _string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value == null) continue;

      if (value is String) {
        final text = value.trim();
        if (text.isNotEmpty) return text;
      }

      if (value is num) return value.toString();
    }

    return '';
  }

  static List<String> _list(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value is List) {
        return value
            .map(_listItemToString)
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();
      }

      final text = _listItemToString(value);
      if (text.isNotEmpty) return [text];
    }

    return const [];
  }

  static String _listItemToString(dynamic value) {
    if (value == null) return '';

    if (value is String) return value.trim();

    if (value is num) return value.toString();

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      final direct = _string(map, const ['name', 'title', 'tag_name']);
      if (direct.isNotEmpty) return direct;

      final tag = map['tag'];
      if (tag is Map) {
        return _string(
          Map<String, dynamic>.from(tag),
          const ['name', 'title', 'tag_name'],
        );
      }
    }

    return value.toString().trim();
  }
}