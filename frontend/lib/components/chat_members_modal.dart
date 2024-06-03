import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';
import 'package:frontend/interfaces/outgoing_chat_message.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/crypto_utils.dart';
import 'package:provider/provider.dart';

class ChatMembersModal extends StatefulWidget {
  final ChatRoomDetails chatRoomDetails;
  final LoggedUserInfo loggedUserInfo;
  final Uint8List chatRoomKey;
  final IV chatRoomIv;
  const ChatMembersModal({
    super.key,
    required this.chatRoomDetails,
    required this.loggedUserInfo,
    required this.chatRoomKey,
    required this.chatRoomIv,
  });

  @override
  State<ChatMembersModal> createState() => _ChatMembersModalState();
}

class _ChatMembersModalState extends State<ChatMembersModal> {
  late ChatRoomService _chatRoomService;
  final StompService _stompService = StompService();

  Future<OutgoingChatMessage> prepareAnnouncement(String announcement) async {
    final encryptedMessage = await CryptoUtils.encryptWithAES(
        announcement, widget.chatRoomKey, widget.chatRoomIv);

    return OutgoingChatMessage(
      encryptedContent: encryptedMessage,
      type: ChatMessageType.ANNOUNCEMENT,
    );
  }

  void handleMakeAdmin(User member) async {
    final response = await _chatRoomService.grantChatAdminToUser(
      widget.chatRoomDetails.id,
      member.id,
    );

    if (response != null) {
      initFToast(context);
      showErrorToast(response);
    }

    setState(() {
      member.isAdminInChat = true;
    });

    _stompService.sendChatMessage(
      await prepareAnnouncement(
        "${widget.loggedUserInfo.username} granted admin to ${member.username}",
      ),
      widget.chatRoomDetails.id,
    );

    Navigator.of(context).pop();
  }

  void handleRemoveAdmin(User member) async {
    final response = await _chatRoomService.revokeChatAdminFromUser(
      widget.chatRoomDetails.id,
      member.id,
    );

    if (response != null) {
      initFToast(context);
      showErrorToast(response);
    }

    setState(() {
      member.isAdminInChat = false;
    });

    _stompService.sendChatMessage(
      await prepareAnnouncement(
        "${widget.loggedUserInfo.username} revoked admin from ${member.username}",
      ),
      widget.chatRoomDetails.id,
    );

    Navigator.of(context).pop();
  }

  void handleRemoveMember(User member) async {
    final response = await _chatRoomService.removeUserFromChat(
      widget.chatRoomDetails.id,
      member.id,
    );

    if (response != null) {
      initFToast(context);
      showErrorToast(response);
    }

    setState(() {
      widget.chatRoomDetails.members.remove(member);
    });

    _stompService.sendChatMessage(
      await prepareAnnouncement(
        "${widget.loggedUserInfo.username} removed ${member.username} from chat",
      ),
      widget.chatRoomDetails.id,
    );

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedInUserAdmin = widget.chatRoomDetails.members
        .firstWhere(
            (member) => member.username == widget.loggedUserInfo.username)
        .isAdminInChat;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              "Chat members",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final member = widget.chatRoomDetails.members[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CustomCircleAvatar(
                      imageUrl:
                          '$baseUrl/user/profilePicture?username=${member.username}',
                      name: member.firstName,
                      radius: 25,
                    ),
                    title: Row(
                      children: [
                        Text(member.username),
                        const SizedBox(width: 10),
                        member.isAdminInChat
                            ? const Icon(
                                Icons.star_rounded,
                                color: Colors.grey,
                              )
                            : const SizedBox(),
                      ],
                    ),
                    trailing: member.username != widget.loggedUserInfo.username
                        ? isLoggedInUserAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.cancel_rounded,
                                        color: Colors.red),
                                    onPressed: () => handleRemoveMember(member),
                                  ),
                                  member.isAdminInChat
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.admin_panel_settings_rounded,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              handleRemoveAdmin(member),
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.admin_panel_settings_rounded,
                                            color: Colors.green,
                                          ),
                                          onPressed: () =>
                                              handleMakeAdmin(member),
                                        ),
                                ],
                              )
                            : null
                        : const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Text(
                              "You",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                  ),
                );
              },
              itemCount: widget.chatRoomDetails.members.length,
            ),
          )
        ],
      ),
    );
  }
}
