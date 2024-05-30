import 'package:frontend/interfaces/chat_message.dart';
import 'package:frontend/interfaces/chat_room_add_or_remove.dart';
import 'package:frontend/interfaces/user.dart';

class ChatRoomDetails {
  String id;
  String roomName;
  int maxUsers;
  ChatMessage lastMessage;
  List<User> members;

  ChatRoomDetails({
    required this.id,
    required this.roomName,
    required this.maxUsers,
    required this.lastMessage,
    required this.members,
  });

  factory ChatRoomDetails.fromJson(Map<String, dynamic> json) {
    return ChatRoomDetails(
      id: json['id'],
      roomName: json['roomName'],
      maxUsers: json['maxUsers'],
      lastMessage: json['lastMessage'] == null
          ? ChatMessage.empty()
          : ChatMessage.fromJson(json['lastMessage']),
      members: json['users']
          .map((userJson) => User.fromJson(userJson))
          .toList()
          .cast<User>(),
    );
  }

  bool isPrivateChat() {
    return maxUsers == 2;
  }

  User otherMember(int firstId) {
    return members.firstWhere((element) => element.id != firstId);
  }

  factory ChatRoomDetails.fromAddOrRemove(
      ChatRoomAddOrRemove chatRoomAddOrRemove) {
    return ChatRoomDetails(
      id: chatRoomAddOrRemove.id,
      roomName: chatRoomAddOrRemove.roomName,
      maxUsers: chatRoomAddOrRemove.maxUsers,
      lastMessage: chatRoomAddOrRemove.lastMessage,
      members: chatRoomAddOrRemove.members,
    );
  }

  @override
  String toString() {
    return 'ChatRoomDetails{id: $id, roomName: $roomName, maxUsers: $maxUsers, lastMessage: $lastMessage, members: $members}';
  }
}
