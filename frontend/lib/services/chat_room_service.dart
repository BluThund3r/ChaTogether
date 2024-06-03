import 'dart:convert';

import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/crypto_utils.dart';
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

  Future<dynamic> getChatRoomSecretKeyAndIv(String chatRoomId) async {
    final response = await HttpWithToken.get(
        url: "$baseUrl/chatRoom/getChatRoomKey/${chatRoomId}");
    if (response.statusCode != 200) {
      return response.body;
    }

    return await CryptoUtils.decryptConversationKeyAndIv(response.body);
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

  Future<dynamic> getChatRoomById(String chatId) async {
    final response = await HttpWithToken.get(
      url: "$baseUrl/chatRoom/getChatDetailsById/$chatId",
    );

    if (response.statusCode == 200) {
      print("Chat room details: ${response.body}");
      return ChatRoomDetails.fromJson(jsonDecode(response.body));
    } else {
      return response.body;
    }
  }

  Future<dynamic> getFriendsNotInChat(String chatId) async {
    final response = await HttpWithToken.get(
      url: "$baseUrl/chatRoom/friendsNotInChat/$chatId",
    );

    print("Fetched friends not in chat: ${response.body}");
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      return response.body;
    }
  }

  Future<dynamic> addMemberToChat(
    String chatId,
    int userId,
    String encryptedChatKey,
  ) async {
    final response = await HttpWithToken.post(
      url: "$baseUrl/chatRoom/addUser",
      body: {
        "chatRoomId": chatId,
        "userId": userId,
        "encryptedKey": encryptedChatKey,
      },
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<dynamic> grantChatAdminToUser(String chatRoomId, int userId) async {
    final response = await HttpWithToken.post(
      url: "$baseUrl/chatRoom/makeAdmin/$chatRoomId/$userId",
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<dynamic> revokeChatAdminFromUser(String chatRoomId, int userId) async {
    final response = await HttpWithToken.delete(
      url: "$baseUrl/chatRoom/removeAdmin/$chatRoomId/$userId",
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<dynamic> removeUserFromChat(String chatRoomId, int userId) async {
    final response = await HttpWithToken.delete(
      url: "$baseUrl/chatRoom/removeUser/$chatRoomId/$userId",
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<dynamic> leaveChat(String chatRoomId) async {
    final response = await HttpWithToken.delete(
      url: "$baseUrl/chatRoom/leaveChat/$chatRoomId",
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }
}
