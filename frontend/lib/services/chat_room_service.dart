import 'dart:convert';

import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/fetch_with_token.dart';

class ChatRoomService {
  Future<dynamic> getChatsOfUser() async {
    final response = await HttpWithToken.get(url: "$baseUrl/chatRoom/myChats");

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((dynamic item) => ChatRoomDetails.fromJson(item))
          .toList();
    } else {
      return response.body;
    }
  }
}
