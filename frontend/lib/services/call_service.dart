import 'dart:convert';

import 'package:frontend/interfaces/call_details.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/fetch_with_token.dart';

class CallService {
  Future<String?> joinCall(String chatRoomId) async {
    final response =
        await HttpWithToken.post(url: "$baseUrl/calls/joinCall/$chatRoomId");

    if (response.statusCode != 200) return response.body;
    return null;
  }

  Future<String?> leaveCall(String chatRoomId) async {
    final response =
        await HttpWithToken.delete(url: "$baseUrl/calls/leaveCall/$chatRoomId");

    if (response.statusCode != 200) return response.body;
    return null;
  }

  Future<dynamic> getMyCalls() async {
    final response = await HttpWithToken.get(url: "$baseUrl/calls/getMyCalls");
    if (response.statusCode != 200) return response.body;
    final responseJson = jsonDecode(response.body);
    return responseJson
        .map((callJson) => CallDetails.fromJson(callJson))
        .toList()
        .cast<CallDetails>();
  }
}
