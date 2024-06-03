import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/chat_message.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/utils/crypto_utils.dart';

class EditMessageModal extends StatefulWidget {
  final ChatMessage message;
  final Uint8List chatRoomKey;
  final IV chatRoomIv;
  const EditMessageModal(
      {super.key,
      required this.message,
      required this.chatRoomKey,
      required this.chatRoomIv});

  @override
  State<EditMessageModal> createState() => _EditMessageModalState();
}

class _EditMessageModalState extends State<EditMessageModal> {
  final TextEditingController _messageController = TextEditingController();
  final StompService stompService = StompService();
  late String initialContent;

  @override
  void initState() {
    initialContent = widget.message.content!;
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void handleEditConfirm(context) {
    if (_messageController.text == initialContent && mounted) {
      initFToast(context);
      showInfoToast("Message not modified");
      return;
    }

    if (_messageController.text.isEmpty && mounted) {
      initFToast(context);
      showInfoToast("Message cannot be empty");
      return;
    }

    if (!mounted) return;

    final plaintext = _messageController.text;
    print("Trying to edit message: $plaintext");
    CryptoUtils.encryptWithAES(
      plaintext,
      widget.chatRoomKey,
      widget.chatRoomIv,
    ).then(
      (encryptedNewContent) {
        stompService.editChatMessage(
          widget.message.id,
          encryptedNewContent,
        );
      },
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _messageController.text = widget.message.content!;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Edit message",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: "Message",
                  ),
                ),
              ),
              const Spacer(),
              Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  onPressed: () => handleEditConfirm(context),
                  icon: const Icon(Icons.check),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
