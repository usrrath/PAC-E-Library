import '../services/library_detail_service.dart';
import '../services/user_service.dart';

String stringValue(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

int? intValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? doubleValue(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;

  if (value is String) {
    return const [
      'true',
      '1',
      'yes',
      'saved',
      'favorite',
      'favorited',
    ].contains(value.toLowerCase().trim());
  }

  return false;
}

String cleanError(Object error) {
  return error.toString().replaceFirst('Exception: ', '').trim();
}

List<String> stringList(dynamic value, {dynamic fallbackSingle}) {
  final result = <String>[];

  if (value is List) {
    for (final item in value) {
      if (item is Map) {
        final text = stringValue(
          item['name'] ??
              item['title'] ??
              item['tag_name'] ??
              item['category_name'],
        );
        if (text.isNotEmpty) result.add(text);
      } else {
        final text = stringValue(item);
        if (text.isNotEmpty) result.add(text);
      }
    }
  }

  if (value is Map) {
    final text = stringValue(
      value['name'] ?? value['title'] ?? value['tag_name'] ?? value['category_name'],
    );
    if (text.isNotEmpty) result.add(text);
  }

  final fallback = stringValue(fallbackSingle);
  if (result.isEmpty && fallback.isNotEmpty) result.add(fallback);

  return result.toSet().toList();
}

int viewCountValue(Map<String, dynamic> json) {
  return intValue(
    json['views_count'] ??
        json['view_count'] ??
        json['views'] ??
        json['total_views'] ??
        json['total_reads'] ??
        json['reads_count'],
  ) ??
      0;
}

String authorName(dynamic author, dynamic user, Map<String, dynamic> json) {
  if (author is Map) {
    final name = stringValue(author['name'] ?? author['full_name']);
    if (name.isNotEmpty) return name;
  }

  if (user is Map) {
    final name = stringValue(user['name'] ?? user['full_name']);
    if (name.isNotEmpty) return name;
  }

  return stringValue(
    json['author_name'] ?? json['author'] ?? json['created_by'],
    fallback: 'Unknown Author',
  );
}

String assetUrl(String value, LibraryDetailService? service) {
  final path = value.trim();
  if (path.isEmpty) return '';

  if (service != null) return service.fullUrl(path);

  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }

  final base = UserService().base.replaceAll(RegExp(r'/+$'), '');
  if (path.startsWith('/')) return '$base$path';

  return '$base/storage/$path';
}