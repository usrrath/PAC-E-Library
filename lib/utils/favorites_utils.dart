Map<String, dynamic> extractBook(Map<String, dynamic> json) {
  final book = json['book'] ?? json['item'];

  if (book is Map<String, dynamic>) {
    return Map<String, dynamic>.from(book);
  }

  if (book is Map) {
    return Map<String, dynamic>.from(book);
  }

  return Map<String, dynamic>.from(json);
}

List<dynamic> extractFavorites(dynamic json) {
  if (json is List) return json;

  if (json is Map) {
    if (json['favorites'] is List) return json['favorites'];
    if (json['favorite_books'] is List) return json['favorite_books'];
    if (json['books'] is List) return json['books'];
    if (json['data'] is List) return json['data'];

    final data = json['data'];

    if (data is Map) {
      if (data['favorites'] is List) return data['favorites'];
      if (data['favorite_books'] is List) return data['favorite_books'];
      if (data['books'] is List) return data['books'];
      if (data['data'] is List) return data['data'];
    }
  }

  return [];
}

List<String> listFromValue(dynamic value) {
  if (value == null) return const [];

  if (value is List) {
    return value.map(itemName).where((e) => e.isNotEmpty).toSet().toList();
  }

  final text = itemName(value);
  if (text.isEmpty) return const [];

  if (text.contains(',')) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  return [text];
}

String itemName(dynamic value) {
  if (value == null) return '';

  if (value is String) return clean(value);
  if (value is num) return value.toString();

  if (value is Map) {
    final map = Map<String, dynamic>.from(value);

    final direct = clean(
      map['name'] ?? map['title'] ?? map['tag_name'] ?? map['category_name'],
    );

    if (direct.isNotEmpty) return direct;

    final tag = map['tag'];
    if (tag is Map) return itemName(tag);
  }

  return clean(value);
}

String clean(dynamic value) {
  if (value == null) return '';

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') return '';

  return text;
}

bool invalidCategory(String value) {
  final text = value.trim().toLowerCase();

  return text.isEmpty ||
      text == 'general' ||
      text == 'null' ||
      text == '0' ||
      text == 'unknown' ||
      text == 'មិនមានប្រភេទ';
}

int extractViewCount(Map<String, dynamic> json) {
  for (final key in const [
    'views_count',
    'view_count',
    'views',
    'total_views',
    'total_reads',
  ]) {
    final value = json[key];

    if (value is int) return value;

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }

  final data = json['data'];
  if (data is Map) {
    return extractViewCount(Map<String, dynamic>.from(data));
  }

  return 0;
}

int yearValue(String value) {
  final match = RegExp(r'\d{4}').firstMatch(value);
  return int.tryParse(match?.group(0) ?? '') ?? 0;
}