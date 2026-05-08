import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'base_url.dart';

class ApiUserServiceReading {
  final String base = BaseURL.base;

  Map<String, String> _headers(String token) {
    return {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /// GET: /api/pdf-progress/pdf-progress-list
  Future<List<dynamic>> getUserReadingProgress(String token) async {
    final uri = Uri.parse("$base/api/pdf-progress/pdf-progress-list");

    try {
      final response = await http.get(
        uri,
        headers: _headers(token),
      );

      final data = _handleResponse(
        response,
        "Failed to load reading progress",
      );

      return _extractList(data);
    } catch (e) {
      debugPrint("READING PROGRESS ERROR: $e");
      throw Exception(_cleanError(e));
    }
  }

  Map<String, dynamic> _handleResponse(
      http.Response response,
      String fallback,
      ) {
    dynamic body;

    debugPrint("READING STATUS: ${response.statusCode}");
    debugPrint("READING BODY: ${response.body}");

    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) return body;
      if (body is List) return {"data": body};
      return {};
    }

    String message = fallback;

    if (body is Map) {
      message = body["message"]?.toString() ?? fallback;

      final errors = body["errors"];

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        } else {
          message = firstError.toString();
        }
      }
    }

    throw Exception(message);
  }

  List<dynamic> _extractList(Map<String, dynamic> data) {
    final value = data["data"] ??
        data["reading_progress"] ??
        data["progress"] ??
        data["items"] ??
        data["books"] ??
        data["results"];

    if (value is List) return value;

    if (value is Map) {
      final nested = value["data"] ??
          value["items"] ??
          value["books"] ??
          value["progress"] ??
          value["reading_progress"] ??
          value["results"];

      if (nested is List) return nested;
    }

    return [];
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst("Exception: ", "");
  }
}