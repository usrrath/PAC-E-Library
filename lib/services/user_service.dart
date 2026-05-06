// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
// import '../models/success_user.dart';
// import 'base_url.dart';
//
// class UserService {
//   final base = BaseURL.base;
//
//   Future<SuccessUser> login(String email, String password) async {
//     final url = "$base/api/signin";
//     try {
//       http.Response response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           "Accept": "application/json",
//         },
//         body: jsonEncode({"email": email, "password": password}),
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return compute(successUserFromJson, response.body);
//       } else {
//         throw Exception("Error status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       throw Exception("Network Error: ${e.toString()}");
//     }
//   }
// }

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/success_user.dart';
import 'base_url.dart';

class UserService {
  final base = BaseURL.base;

  Future<SuccessUser> login(String email, String password) async {
    final url = "$base/api/signin";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return compute(successUserFromJson, response.body);
      }

      // ✅ Better error message from Laravel
      throw Exception(body["message"] ?? "Login failed");
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }



  // Future<void> logout(String token) async {
  //   final uri = Uri.parse('$base/api/signout');
  //
  //   try {
  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         "Accept": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //     );
  //
  //     if (response.statusCode != 200) {
  //       throw Exception("Logout failed");
  //     }
  //   } catch (e) {
  //     throw Exception("Logout error: $e");
  //   }
  // }

  Future<void> logout(String token) async {
    final uri = Uri.parse('$base/api/signout');

    try {
      final response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Logout failed");
      }
    } catch (e) {
      throw Exception("Logout error: $e");
    }
  }
}
