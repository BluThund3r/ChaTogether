import 'package:frontend/interfaces/chat_message.dart';

class ChatRoomDetails {
  int id;
  String roomName;
  int maxUsers;
  ChatMessage lastMessage;

  ChatRoomDetails({
    required this.id,
    required this.roomName,
    required this.maxUsers,
    required this.lastMessage,
  });

  factory ChatRoomDetails.fromJson(Map<String, dynamic> json) {
    return ChatRoomDetails(
      id: json['id'],
      roomName: json['roomName'],
      maxUsers: json['maxUsers'],
      lastMessage: ChatMessage.fromJson(json['lastMessage']),
    );
  }

  bool isPrivateChat() {
    return maxUsers == 2;
  }
}
