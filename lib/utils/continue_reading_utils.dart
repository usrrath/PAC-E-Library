import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/user_service.dart';

Map<String, dynamic> itemJson(Map<String, dynamic> json) {
  final item = json['item'] ?? json['book'] ?? json['data'];

  if (item is Map<String, dynamic>) return item;
  if (item is Map) return Map<String, dynamic>.from(item);

  return json;
}

List<dynamic> extractList(dynamic decoded) {
  if (decoded is List) return decoded;

  if (decoded is Map) {
    final data = decoded['data'];

    if (data is List) return data;

    if (data is Map) {
      if (data['data'] is List) return data['data'];
      if (data['items'] is List) return data['items'];
      if (data['books'] is List) return data['books'];
      if (data['progress'] is List) return data['progress'];
    }

    if (decoded['items'] is List) return decoded['items'];
    if (decoded['books'] is List) return decoded['books'];
    if (decoded['progress'] is List) return decoded['progress'];
    if (decoded['pdf_progress'] is List) return decoded['pdf_progress'];
    if (decoded['result'] is List) return decoded['result'];
    if (decoded['results'] is List) return decoded['results'];
  }

  return [];
}

String authorName(Map<String, dynamic> item) {
  final author = item['author'];
  final user = item['user'];

  if (author is Map) {
    return stringValue(
      author,
      ['name', 'username', 'full_name'],
      fallback: 'Unknown Author',
    );
  }

  if (user is Map) {
    return stringValue(
      user,
      ['name', 'username', 'full_name'],
      fallback: 'Unknown Author',
    );
  }

  return stringValue(
    item,
    ['author_name', 'author', 'writer', 'created_by'],
    fallback: 'Unknown Author',
  );
}

String fullUrl(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return '';

  if (clean.startsWith('http://') || clean.startsWith('https://')) {
    return clean;
  }

  final root = UserService().apiRoot;
  final path = clean.startsWith('/storage/')
      ? clean.substring(1)
      : clean.startsWith('storage/')
      ? clean
      : 'storage/$clean';

  return '$root/$path';
}

String stringValue(
    Map<dynamic, dynamic> json,
    List<String> keys, {
      String fallback = '',
    }) {
  for (final key in keys) {
    final value = json[key];

    if (value != null && value.toString().trim().isNotEmpty) {
      final text = value.toString().trim();
      if (text != 'null') return text;
    }
  }

  return fallback;
}

int intAny(List<dynamic> values) {
  for (final value in values) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value?.toString().trim() ?? '');
    if (parsed != null) return parsed;
  }

  return 0;
}

double doubleAny(List<dynamic> values) {
  for (final value in values) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    final parsed = double.tryParse(value?.toString().trim() ?? '');
    if (parsed != null) return parsed;
  }

  return 0;
}

String errorMessage(http.Response response, String fallback) {
  try {
    final body = jsonDecode(response.body);

    if (body is Map) {
      final message = body['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
  } catch (_) {}

  return '$fallback (${response.statusCode})';
}