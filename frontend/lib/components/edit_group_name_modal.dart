import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';
import 'package:frontend/interfaces/outgoing_chat_message.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/utils/crypto_utils.dart';
import 'package:provider/provider.dart';

class EditGroupNameModal extends StatefulWidget {
  final ChatRoomDetails chatRoomDetails;
  final Uint8List chatRoomKey;
  final IV chatRoomIv;
  const EditGroupNameModal({
    super.key,
    required this.chatRoomDetails,
    required this.chatRoomKey,
    required this.chatRoomIv,
  });

  @override
  State<EditGroupNameModal> createState() => _EditGroupNameModalState();
}

class _EditGroupNameModalState extends State<EditGroupNameModal> {
  final TextEditingController newGroupNameController = TextEditingController();
  late ChatRoomService chatRoomService;
  final StompService stompService = StompService();
  late AuthService authService;

  void handleChangeGroupName(context) async {
    final newGroupName = newGroupNameController.text;
    if (newGroupName.isEmpty) return;
    if (newGroupName == widget.chatRoomDetails.roomName) {
      initFToast(context);
      showInfoToast("Group name not changed");
      return;
    }

    final response = await chatRoomService.changeGroupName(
      widget.chatRoomDetails.id,
      newGroupName,
    );

    if (response == null) {
      final loggedInUser = await authService.getLoggedInUser();
      final plaintextContent =
          '${loggedInUser.username} changed the group name to "$newGroupName"';
      final encryptedContent = await CryptoUtils.encryptWithAES(
        plaintextContent,
        widget.chatRoomKey,
        widget.chatRoomIv,
      );

      stompService.sendChatMessage(
        OutgoingChatMessage(
          type: ChatMessageType.ANNOUNCEMENT,
          encryptedContent: encryptedContent,
        ),
        widget.chatRoomDetails.id,
      );

      Navigator.of(context).pop();
    } else {
      initFToast(context);
      showErrorToast(response);
    }
  }

  @override
  void initState() {
    super.initState();
    newGroupNameController.text = widget.chatRoomDetails.roomName;
    chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit Group Name",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newGroupNameController,
              decoration: const InputDecoration(
                labelText: "New Group Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => handleChangeGroupName(context),
              child: const Text("Change Name"),
            ),
          ],
        ),
      ),
    );
  }
}
