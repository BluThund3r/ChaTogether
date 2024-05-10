import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:http/http.dart' as http;

class LoggedUserInfo {
  final String username;
  final String email;
  final String firstName;
  final String lastName;

  LoggedUserInfo({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory LoggedUserInfo.fromJson(Map<String, dynamic> json) {
    return LoggedUserInfo(
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}

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

  LoggedUserInfo _getTokenInfo(String token) {
    final parts = token.split('.');
    final payload = parts[1];
    final String normalizedPayload = base64Url.normalize(payload);
    final jsonPayload = utf8.decode(base64.decode(normalizedPayload));
    final tokenPayload = LoggedUserInfo.fromJson(jsonDecode(jsonPayload));
    return tokenPayload;
  }

  Future<dynamic> getEmailVerificationTrialsLeft(String email) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/auth/getRemainingEmailConfirmationTrials?email=$email'),
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      return response.body;
    }
  }

  Future<String?> resendVerificationCode(String email) async {
    const headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/auth/resendConfirmationEmail'),
      headers: headers,
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
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

  Future<LoggedUserInfo> getLoggedInUser() async {
    final token = await _storage.read(key: 'authToken');
    return _getTokenInfo(token!);
  }
}
