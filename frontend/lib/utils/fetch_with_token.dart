import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
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
    String filePath = "",
    Uint8List? fileBytes,
    String url = "",
    Map<String, String> headers = const {},
  }) async {
    var token = await _storage.read(key: "authToken") ?? "";
    var localHeaders = {...headers};
    localHeaders["Authorization"] = 'Bearer $token';

    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(url))
          ..headers.addAll(localHeaders);

    if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes("file", fileBytes,
          filename: "image.jpg"));
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }

    return request.send();
  }
}
