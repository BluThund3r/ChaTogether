import 'package:frontend/interfaces/enums/action_type.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';

class ChatMessage {
  String id;
  String chatRoomId;
  int senderId;
  String encryptedContent;
  String sentAt;
  ChatMessageType type;
  bool isEdited;
  bool isDeleted;
  List<int> seenBy;
  ActionType action;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.encryptedContent,
    required this.sentAt,
    required this.type,
    required this.isEdited,
    required this.isDeleted,
    required this.seenBy,
    required this.action,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chatRoomId: json['chatRoomId'],
      senderId: json['senderId'],
      encryptedContent: json['encryptedContent'],
      sentAt: json['sentAt'],
      type: ChatMessageType.values
          .firstWhere((e) => e.toString() == 'ChatMessageType.${json['type']}'),
      isEdited: json['isEdited'],
      isDeleted: json['isDeleted'],
      seenBy: json['seenBy'],
      action: ActionType.values
          .firstWhere((e) => e.toString() == 'ActionType.${json['action']}'),
    );
  }

  factory ChatMessage.empty() {
    return ChatMessage(
      id: "",
      chatRoomId: "",
      senderId: -1,
      encryptedContent: '',
      sentAt: '',
      type: ChatMessageType.TEXT,
      isEdited: false,
      isDeleted: false,
      seenBy: [],
      action: ActionType.GET,
    );
  }
}
