import 'package:frontend/interfaces/enums/chat_message_type.dart';

class OutgoingChatMessage {
  String encryptedContent;
  ChatMessageType type;

  OutgoingChatMessage({
    required this.encryptedContent,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'encryptedContent': encryptedContent,
      'type': type.toString().split('.').last,
    };
  }
}
