import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/interfaces/chat_message.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final bool privateChat;
  final List<User> members;

  const ChatMessageWidget(
      {super.key,
      required this.message,
      required this.isCurrentUser,
      required this.privateChat,
      required this.members});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yy');
    final timeFormat = DateFormat('HH:mm');

    if (message.type == ChatMessageType.ANNOUNCEMENT) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            message.content!,
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    var imageBytes;
    if (message.type == ChatMessageType.IMAGE) {
      imageBytes = base64Decode(message.content!);
    }

    final sender =
        members.where((element) => element.id == message.senderId).firstOrNull;
    final bool senderStillInChat = sender != null;
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCurrentUser && !privateChat)
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: CustomCircleAvatar(
                imageUrl: senderStillInChat
                    ? '$baseUrl/user/profilePictureById?userId=${message.senderId}'
                    : '$baseUrl/user/profilePictureById?userId=0',
                name: senderStillInChat ? sender.firstName : '?',
                radius: 20,
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue : Colors.grey[700],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (message.content != null && !message.isDeleted)
                      message.type == ChatMessageType.TEXT
                          ? Text(
                              message.content!,
                              style: const TextStyle(color: Colors.white),
                            )
                          : Container(
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                                maxWidth: 200,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: InstaImageViewer(
                                child: Image.memory(imageBytes),
                              ),
                            ),
                    if (message.isDeleted)
                      const Text(
                        'Message deleted',
                        style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${dateFormat.format(message.sentAt)} ${timeFormat.format(message.sentAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 5),
                        if (message.isEdited)
                          const Icon(
                            Icons.edit,
                            size: 12,
                            color: Colors.white70,
                          ),
                        const SizedBox(width: 2),
                        if (isCurrentUser)
                          Icon(
                            message.seenBy.length > 1
                                ? Icons.remove_red_eye
                                : Icons.check,
                            size: 12,
                            color: Colors.white70,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
