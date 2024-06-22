import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar_no_cache.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';
import 'package:frontend/interfaces/outgoing_chat_message.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/crypto_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChangeGroupPictureModal extends StatefulWidget {
  final ChatRoomDetails chatRoomDetails;
  final Uint8List chatRoomKey;
  final IV chatRoomIv;
  const ChangeGroupPictureModal({
    super.key,
    required this.chatRoomDetails,
    required this.chatRoomKey,
    required this.chatRoomIv,
  });

  @override
  State<ChangeGroupPictureModal> createState() =>
      _ChangeGroupPictureModalState();
}

class _ChangeGroupPictureModalState extends State<ChangeGroupPictureModal> {
  File? _selectedImage;
  late ChatRoomService chatRoomService;
  final StompService stompService = StompService();
  late AuthService authService;

  void _showChoiceDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Choose a source"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: const Text("Pick from Gallery"),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(source: ImageSource.gallery);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: const Text("Take a picture"),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(source: ImageSource.camera);
                    },
                  )
                ],
              ),
            ),
          );
        });
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

  void handleUploadGroupImage(context) async {
    final response = await chatRoomService.uploadGroupPicture(
        widget.chatRoomDetails.id, _selectedImage!.path);

    initFToast(context);
    if (response == null) {
      await CachedNetworkImage.evictFromCache(
        "$baseUrl/chatRoom/groupPicture?chatRoomId=${widget.chatRoomDetails.id}",
      );
      setState(() {
        _selectedImage = null;
      });

      final loggedInUser = await authService.getLoggedInUser();

      final plaintextContent =
          "${loggedInUser.username} changed the group picture";
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

      showOKToast("Group picture uploaded");
      Navigator.pop(context);
    } else {
      showErrorToast(response);
    }
  }

  @override
  void initState() {
    super.initState();
    chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Change Group Picture",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _selectedImage == null
                  ? CustomCircleAvatarNoCache(
                      name: "",
                      imageUrl:
                          "$baseUrl/chatRoom/groupPicture?chatRoomId=${widget.chatRoomDetails.id}",
                      isGroupConversation: true,
                      radius: 112,
                    )
                  : CircleAvatar(
                      radius: 112,
                      backgroundImage: FileImage(_selectedImage!),
                    ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () => _showChoiceDialog(context),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.blue,
                        ),
                      ),
                      child: const Text(
                        "Change",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_selectedImage != null) const Spacer(),
                  if (_selectedImage != null)
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () => handleUploadGroupImage(context),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
            ],
          )),
    );
  }
}
