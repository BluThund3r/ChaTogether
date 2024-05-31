import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/interfaces/chat_message.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/utils/backend_details.dart';
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
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCurrentUser && !privateChat)
            CustomCircleAvatar(
              imageUrl:
                  '$baseUrl/user/profilePictureById?username=${message.senderId}',
              name: members
                  .where((element) => element.id == message.senderId)
                  .first
                  .firstName,
              radius: 20,
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
                    if (message.content != null)
                      Text(
                        message.content!,
                        style: const TextStyle(color: Colors.white),
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
                        Icon(
                          message.seenBy.isNotEmpty
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
