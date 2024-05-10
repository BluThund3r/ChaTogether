import 'dart:convert';

import 'package:frontend/interfaces/friend_request.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/utils/fetch_with_token.dart';
import 'package:frontend/utils/backend_details.dart';

class FriendService {
  Future<dynamic> fetchReceivedFriendRequests() async {
    final response =
        await HttpWithToken.get(url: "$baseUrl/friendship/receivedRequests");

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => FriendRequest.fromJson(item)).toList();
    } else {
      return response.body;
    }
  }

  Future<dynamic> fetchSentFriendRequests() async {
    final response =
        await HttpWithToken.get(url: "$baseUrl/friendship/sentRequests");

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => FriendRequest.fromJson(item)).toList();
    } else {
      return response.body;
    }
  }

  Future<String?> sendFriendRequest(String username) async {
    final response = await HttpWithToken.post(
        url: "$baseUrl/friendship/sendRequest/$username");

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<String?> cancelFriendRequest(String receiverUsername) async {
    final response = await HttpWithToken.delete(
        url: "$baseUrl/friendship/cancelRequest/$receiverUsername");

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<String?> acceptFriendRequest(String senderUsername) async {
    final response = await HttpWithToken.post(
        url: "$baseUrl/friendship/acceptRequest/$senderUsername");

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<String?> rejectFriendRequest(String senderUsername) async {
    final response = await HttpWithToken.delete(
        url: "$baseUrl/friendship/rejectRequest/$senderUsername");

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<dynamic> fetchFriends() async {
    final response =
        await HttpWithToken.get(url: "$baseUrl/friendship/friends");

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      return response.body;
    }
  }

  Future<String?> unfriend(String friendUsername) async {
    final response = await HttpWithToken.delete(
        url: "$baseUrl/friendship/removeFriend/$friendUsername");

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<dynamic> fetchBlockedUsers() async {
    final response =
        await HttpWithToken.get(url: "$baseUrl/friendship/blockedUsers");

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      return response.body;
    }
  }

  Future<String?> blockUser(String username) async {
    final response = await HttpWithToken.post(
        url: "$baseUrl/friendship/blockUser/$username");

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<String?> unblockUser(String username) async {
    final response = await HttpWithToken.delete(
        url: "$baseUrl/friendship/unblockUser/$username");

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }
}
