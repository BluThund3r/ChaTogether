import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/enums/chat_room_action.dart';

class ChatRoomAddOrRemove extends ChatRoomDetails {
  final ChatRoomAction action;
  final List<int> affectedUserIds;

  ChatRoomAddOrRemove({
    required super.id,
    required super.roomName,
    required super.maxUsers,
    required super.lastMessage,
    required super.members,
    required this.action,
    required this.affectedUserIds,
  });

  factory ChatRoomAddOrRemove.fromJson(Map<String, dynamic> json) {
    final chatRoomDetails = ChatRoomDetails.fromJson(json);
    return ChatRoomAddOrRemove(
      id: chatRoomDetails.id,
      roomName: chatRoomDetails.roomName,
      maxUsers: chatRoomDetails.maxUsers,
      lastMessage: chatRoomDetails.lastMessage,
      members: chatRoomDetails.members,
      action: ChatRoomAction.values.firstWhere(
          (e) => e.toString() == 'ChatRoomAction.${json['action']}'),
      affectedUserIds: List<int>.from(json['affectedUserIds'].map((x) => x)),
    );
  }
}
