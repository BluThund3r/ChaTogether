import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpWithToken {
  static const _storage = FlutterSecureStorage();

  static Future<http.Response> get(
      {String url = "", Map<String, String> headers = const {}}) async {
    var token = await _storage.read(key: "authToken") ?? "";
    var localHeaders = {...headers};
    localHeaders["Authorization"] = 'Bearer $token';

    return http.get(
      Uri.parse(url),
      headers: localHeaders,
    );
  }

  static Future<http.Response> post(
      {String url = "",
      Map<String, String> headers = const {},
      Map<String, dynamic> body = const {}}) async {
    var token = await _storage.read(key: "authToken") ?? "";
    var localHeaders = {...headers};
    localHeaders["Authorization"] = 'Bearer $token';

    return http.post(
      Uri.parse(url),
      headers: localHeaders,
      body: json.encode(body),
    );
  }

  static Future<http.Response> put(
      {String url = "",
      Map<String, String> headers = const {},
      Map<String, dynamic> body = const {}}) async {
    var token = await _storage.read(key: "authToken") ?? "";
    var localHeaders = {...headers};
    localHeaders["Authorization"] = 'Bearer $token';

    return http.put(
      Uri.parse(url),
      headers: localHeaders,
      body: json.encode(body),
    );
  }

  static Future<http.Response> patch(
      {String url = "",
      Map<String, String> headers = const {},
      Map<String, dynamic> body = const {}}) async {
    var token = await _storage.read(key: "authToken") ?? "";
    var localHeaders = {...headers};
    localHeaders["Authorization"] = 'Bearer $token';

    return http.patch(
      Uri.parse(url),
      headers: localHeaders,
      body: json.encode(body),
    );
  }

  static Future<http.Response> delete(
      {String url = "", Map<String, String> headers = const {}}) async {
    var token = await _storage.read(key: "authToken") ?? "";
    var localHeaders = {...headers};
    localHeaders["Authorization"] = 'Bearer $token';

    return http.delete(
      Uri.parse(url),
      headers: localHeaders,
    );
  }

  static Future<http.StreamedResponse> postFile({
    required String filePath,
    String url = "",
    Map<String, String> headers = const {},
  }) async {
    var token = await _storage.read(key: "authToken") ?? "";
    var localHeaders = {...headers};
    localHeaders["Authorization"] = 'Bearer $token';

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..files.add(await http.MultipartFile.fromPath('file', filePath))
      ..headers.addAll(localHeaders);

    return request.send();
  }
}
