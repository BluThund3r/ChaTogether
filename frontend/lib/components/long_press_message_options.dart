import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/edit_message_modal.dart';
import 'package:frontend/interfaces/chat_message.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/stomp_service.dart';

class LongPressMessageOptions extends StatelessWidget {
  final ChatMessage message;
  final LoggedUserInfo loggedUserInfo;
  final Uint8List chatRoomKey;
  final IV chatRoomIv;
  final StompService stompService = StompService();
  LongPressMessageOptions(
      {super.key,
      required this.message,
      required this.loggedUserInfo,
      required this.chatRoomKey,
      required this.chatRoomIv});

  void handleDelete(BuildContext context) {
    stompService.deleteChatMessage(message.id);
    Navigator.pop(context);
  }

  void handleCopy(context) async {
    await Clipboard.setData(ClipboardData(text: message.content!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.grey[700],
        content: const Center(
            child: Text(
          "Copied to clipboard",
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
    Navigator.pop(context);
  }

  void handleRestore(BuildContext context) {
    stompService.restoreChatMessage(message.id);
    Navigator.pop(context);
  }

  void handleEdit(ChatMessage message, BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: EditMessageModal(
            message: message,
            chatRoomKey: chatRoomKey,
            chatRoomIv: chatRoomIv,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userSendMessage = loggedUserInfo.userId == message.senderId;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!message.isDeleted)
            Column(
              children: [
                if(message.type == ChatMessageType.TEXT)
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text("Copy"),
                  onTap: () => handleCopy(context),
                ),
                if (userSendMessage && message.type == ChatMessageType.TEXT)
                  ListTile(
                    leading: const Icon(Icons.edit_rounded),
                    title: const Text("Edit"),
                    onTap: () => handleEdit(message, context),
                  ),
                if (userSendMessage)
                  ListTile(
                    leading: const Icon(Icons.delete_rounded),
                    title: const Text("Delete"),
                    onTap: () => handleDelete(context),
                  ),
              ],
            ),
          if (message.isDeleted && userSendMessage)
            ListTile(
              leading: const Icon(Icons.restore_rounded),
              title: const Text("Restore"),
              onTap: () => handleRestore(context),
            ),
          if (message.isDeleted && !userSendMessage)
            const Center(
              child: Text(
                "No actions available",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
