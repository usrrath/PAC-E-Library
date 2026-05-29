import 'dart:convert';

import 'package:http/http.dart' as http;

import '../l10n/app_localizations.dart';

List<dynamic> extractNotificationList(dynamic decoded) {
  if (decoded is List) return decoded;

  if (decoded is Map) {
    final data = decoded['data'];

    if (data is List) return data;

    if (data is Map) {
      if (data['notifications'] is List) {
        return data['notifications'];
      }

      if (data['items'] is List) {
        return data['items'];
      }

      if (data['data'] is List) {
        return data['data'];
      }
    }

    if (decoded['notifications'] is List) {
      return decoded['notifications'];
    }

    if (decoded['items'] is List) {
      return decoded['items'];
    }
  }

  return [];
}

String formatNotificationTime(
    String value,
    AppLocalizations t,
    ) {
  if (value.trim().isEmpty) return '';

  try {
    final date = DateTime.parse(value).toLocal();

    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) {
      return t.notificationsJustNow;
    }

    if (diff.inMinutes < 60) {
      return t.notificationsMinAgo(diff.inMinutes);
    }

    if (diff.inHours < 24) {
      return t.notificationsHourAgo(diff.inHours);
    }

    if (diff.inDays < 7) {
      return t.notificationsDayAgo(diff.inDays);
    }

    return '${date.day}/${date.month}/${date.year}';
  } catch (_) {
    return value;
  }
}

String strValue(
    Map<dynamic, dynamic> json,
    List<String> keys, {
      String fallback = '',
    }) {
  for (final key in keys) {
    final value = json[key];

    if (value != null &&
        value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }

  return fallback;
}

bool boolValue(
    Map<dynamic, dynamic> json,
    List<String> keys,
    ) {
  for (final key in keys) {
    final value = json[key];

    if (value is bool) return value;

    if (value is int) return value == 1;

    final text = value
        ?.toString()
        .toLowerCase()
        .trim();

    if (text == 'true' ||
        text == '1' ||
        text == 'yes') {
      return true;
    }
  }

  return false;
}

String errorMessage(
    http.Response response,
    String fallback,
    ) {
  try {
    final body = jsonDecode(response.body);

    if (body is Map) {
      final message = body['message'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      final error = body['error'];

      if (error != null &&
          error.toString().trim().isNotEmpty) {
        return error.toString();
      }
    }
  } catch (_) {}

  return '$fallback (${response.statusCode})';
}