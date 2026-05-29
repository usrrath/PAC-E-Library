import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/device_log_model.dart';
import 'base_url.dart';
import 'profile_service.dart';

class DeviceLogsService {
  Future<List<DeviceLog>> getDeviceLogs({
    int page = 1,
    int perPage = 10,
  }) async {
    final token = await ProfileService.getToken();

    final uri = Uri.parse('${BaseURL.api}/login-history').replace(
      queryParameters: {
        'page': '$page',
        'per_page': '$perPage',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load device logs');
    }

    final body = jsonDecode(response.body);

    final rawList = body is List
        ? body
        : body['data'] is List
        ? body['data']
        : body['data']?['data'] is List
        ? body['data']['data']
        : body['login_history'] is List
        ? body['login_history']
        : [];

    return rawList
        .map<DeviceLog>((e) => DeviceLog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}