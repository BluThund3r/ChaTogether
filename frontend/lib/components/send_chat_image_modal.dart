import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';
import 'package:frontend/interfaces/outgoing_chat_message.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/utils/crypto_utils.dart';
import 'package:image_picker/image_picker.dart';

class SendChatImageModal extends StatefulWidget {
  final ChatRoomDetails chatRoomDetails;
  final Uint8List chatRoomKey;
  final IV chatRoomIv;
  final ImageSource source;
  const SendChatImageModal({
    super.key,
    required this.chatRoomKey,
    required this.chatRoomIv,
    required this.chatRoomDetails,
    required this.source,
  });

  @override
  State<SendChatImageModal> createState() => _SendChatImageModalState();
}

class _SendChatImageModalState extends State<SendChatImageModal> {
  File? _selectedImage;
  final StompService stompService = StompService();

  Future<Uint8List> compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 800,
      minHeight: 800,
      quality: 85,
    );
    return result!;
  }

  Future _pickImage({required ImageSource source}) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  void sendImageMessage(BuildContext context) async {
    if (_selectedImage == null) {
      return;
    }

    final compressedImageBytes = await compressImage(_selectedImage!);

    final plaintext = base64Encode(compressedImageBytes);
    print("Length of the plaintext: ${plaintext.length}");
    print("Length of the plaintext bytes: {${base64Decode(plaintext).length}}");
    final ciphertext = await CryptoUtils.encryptWithAES(
      plaintext,
      widget.chatRoomKey,
      widget.chatRoomIv,
    );
    print("Length of the ciphertext: ${ciphertext.length}");
    print(
        "Length of the ciphertext bytes: {${base64Decode(ciphertext).length}}");

    final imageMessage = OutgoingChatMessage(
      encryptedContent: ciphertext,
      type: ChatMessageType.IMAGE,
    );

    stompService.sendChatMessage(imageMessage, widget.chatRoomDetails.id);

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _pickImage(source: widget.source);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                if (widget.source == ImageSource.gallery)
                  const Text(
                    "Select image from gallery",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                else
                  const Text(
                    "Take a picture",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
              ],
            ),
            if (_selectedImage == null) const SizedBox(height: 75),
            if (_selectedImage == null)
              const Column(
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 150,
                  ),
                  Text(
                    "No image yet",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              )
            else
              Image.file(
                _selectedImage!,
                width: 300,
                height: 300,
              ),
            if (_selectedImage == null) const SizedBox(height: 75),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickImage(source: widget.source),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.blue,
                        ),
                      ),
                      child: Text(
                        widget.source == ImageSource.gallery
                            ? "Change Image"
                            : "Take Again",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => sendImageMessage(context),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.green,
                        ),
                      ),
                      child: const Text(
                        "Send",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
