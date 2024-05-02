import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<String?> verifyEmail(String verificationCode) async {
    const headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/auth/confirmEmail'),
      headers: headers,
      body: jsonEncode({'token': verificationCode}),
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<String?> login(String usernameOrEmail, String password) async {
    const headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      await _storage.write(key: 'authToken', value: response.body);
      return null;
    } else {
      return response.body;
    }
  }

  Future<String?> register(Map<String, String> info) async {
    const headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers,
      body: jsonEncode(info),
    );

    if (response.statusCode == 201) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'authToken');
  }

  Future<bool> isLoggedIn() async {
    return await _storage.containsKey(key: 'authToken');
  }
}
