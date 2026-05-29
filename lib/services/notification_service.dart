import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/profile_service.dart';
import '../services/user_service.dart';
import '../utils/notification_utils.dart';

class NotificationService {
  final UserService _service = UserService();

  Future<String> token() async {
    return (await ProfileService.getToken())?.trim() ?? '';
  }

  Future<Map<String, String>> headers() async {
    final tokenValue = await token();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (tokenValue.isNotEmpty)
        'Authorization': 'Bearer $tokenValue',
    };
  }

  Future<Map<String, dynamic>> getNotifications() async {
    final uri = Uri.parse(
      _service.apiUrl('/api/notifications'),
    );

    final response = await http.get(
      uri,
      headers: await headers(),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final text = response.body.trim();

      if (text.isEmpty) return {};

      final decoded = jsonDecode(text);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      if (decoded is List) {
        return {'notifications': decoded};
      }

      return {};
    }

    throw Exception(
      errorMessage(
        response,
        'Failed to load notifications',
      ),
    );
  }

  Future<void> request(
      String path, {
        required String method,
      }) async {
    final uri = Uri.parse(_service.apiUrl(path));

    final requestHeaders = await headers();

    late http.Response response;

    switch (method.toUpperCase()) {
      case 'PATCH':
        response = await http.patch(
          uri,
          headers: requestHeaders,
        );
        break;

      case 'DELETE':
        response = await http.delete(
          uri,
          headers: requestHeaders,
        );
        break;

      case 'POST':
        response = await http.post(
          uri,
          headers: requestHeaders,
        );
        break;

      default:
        response = await http.get(
          uri,
          headers: requestHeaders,
        );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        errorMessage(response, 'Request failed'),
      );
    }
  }
}