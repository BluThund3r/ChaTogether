import 'dart:convert';

import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/fetch_with_token.dart';

class ChatRoomService {
  final AuthService _authService = AuthService();

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

  Future<dynamic> getFriendsWithNoPrivateChat() async {
    final response = await HttpWithToken.get(
        url: "$baseUrl/chatRoom/friendsWithNoPrivateChat");

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      return response.body;
    }
  }

  Future<dynamic> createPrivateChat(String username) async {
    print("Creating private chat with $username");
    final response = await HttpWithToken.post(
      url: "$baseUrl/chatRoom/createPrivate/$username", 
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      print("Error creating private chat: ${response.body}");
      return response.body;
    }
  }

  Future<dynamic> createGroupChat(
    List<String> usernames,
    String chatName,
  ) async {
    print("Creating group chat with ${usernames[0]}");
    usernames.add((await _authService.getLoggedInUser()).username);
    final response = await HttpWithToken.post(
      url: "$baseUrl/chatRoom/createGroup",
      body: {
        "memberUsernames": usernames,
        "chatRoomName": chatName,
      },
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      print("Error creating group chat: ${response.body}");
      return response.body;
    }
  }
}