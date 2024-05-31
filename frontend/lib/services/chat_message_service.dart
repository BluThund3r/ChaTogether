import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:frontend/interfaces/chat_message.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/crypto_utils.dart';
import 'package:frontend/utils/fetch_with_token.dart';

class ChatMessageService {
  Future<List<ChatMessage>> getChatMessagesDecryptedBefore(
    String chatRoomId,
    Uint8List chatRoomKey,
    IV chatRoomIV,
    DateTime before,
  ) async {
    final response = await HttpWithToken.get(
        url:
            '$baseUrl/chatMessages?chatRoomId=$chatRoomId&before=${before.toIso8601String()}');

    final messagesDynamic = jsonDecode(response.body);
    print("Response body for chat messages: $messagesDynamic");

    final encryptedMessages = messagesDynamic
        .map((messageDynamic) => ChatMessage.fromJson(messageDynamic))
        .toList()
        .cast<ChatMessage>();

    final decryptedMessages = await CryptoUtils.decryptChatMessages(
        encryptedMessages, chatRoomKey, chatRoomIV);

    return decryptedMessages;
  }

  Future<List<ChatMessage>> getChatMessagesDecrypted(
      String chatRoomId, Uint8List chatRoomKey, IV chatRoomIV) async {
    return await getChatMessagesDecryptedBefore(
      chatRoomId,
      chatRoomKey,
      chatRoomIV,
      DateTime.now(),
    );
  }
}
