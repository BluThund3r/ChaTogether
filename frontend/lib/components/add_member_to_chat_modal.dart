import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/components/custom_search_bar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';
import 'package:frontend/interfaces/outgoing_chat_message.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/crypto_utils.dart';
import 'package:provider/provider.dart';

class AddMemberToChatModal extends StatefulWidget {
  final ChatRoomDetails chatRoomDetails;
  final Uint8List chatKey;
  final IV chatIv;
  final LoggedUserInfo loggedUserInfo;
  const AddMemberToChatModal({
    super.key,
    required this.chatRoomDetails,
    required this.chatKey,
    required this.chatIv,
    required this.loggedUserInfo,
  });

  @override
  State<AddMemberToChatModal> createState() => _AddMemberToChatModalState();
}

class _AddMemberToChatModalState extends State<AddMemberToChatModal> {
  late ChatRoomService chatRoomService;
  late UserService userService;
  final StompService stompService = StompService();
  final TextEditingController _searchController = TextEditingController();
  List<User> friendsNotInChat = [];
  List<User> displayedFriends = [];
  bool loaded = false;

  void handleAddMember(User userToAdd) async {
    final userPublicKey =
        await userService.getPublicKeyOfOtherUser(userToAdd.username);
    final encryptedKeyAndIv = await CryptoUtils.encryptChatKeyForNewUser(
      widget.chatKey!,
      widget.chatIv,
      userPublicKey,
    );

    final response = await chatRoomService.addMemberToChat(
      widget.chatRoomDetails.id,
      userToAdd.id,
      encryptedKeyAndIv,
    );

    if (response != null && mounted) {
      initFToast(context);
      showErrorToast("Couldn't add member");
      return;
    }

    final plaintextMessage =
        "${widget.loggedUserInfo.username} added ${userToAdd.username} to the chat";
    final encryptedMessage = await CryptoUtils.encryptWithAES(
      plaintextMessage,
      widget.chatKey,
      widget.chatIv,
    );
    final announcement = OutgoingChatMessage(
      encryptedContent: encryptedMessage,
      type: ChatMessageType.ANNOUNCEMENT,
    );

    stompService.sendChatMessage(announcement, widget.chatRoomDetails.id);
    Navigator.pop(context);
  }

  void fetchFriendsNotInChat() async {
    final response =
        await chatRoomService.getFriendsNotInChat(widget.chatRoomDetails.id);

    if (response is! List<User>) {
      initFToast(context);
      showErrorToast("Couldn't fetch friends");
      return;
    }

    setState(() {
      friendsNotInChat = response;
      displayedFriends = friendsNotInChat;
      loaded = true;
    });
  }

  void onClear() {
    setState(() {
      displayedFriends = friendsNotInChat;
    });
  }

  void onSearch(String value) {
    setState(() {
      displayedFriends = friendsNotInChat
          .where((friend) =>
              friend.username.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
    userService = Provider.of<UserService>(context, listen: false);
    fetchFriendsNotInChat();
  }

  @override
  Widget build(BuildContext context) {
    return !loaded
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Text(
                    "Add member",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: CustomSearchBar(
                    controller: _searchController,
                    onSubmit: onSearch,
                    onClear: onClear,
                  ),
                ),
                const SizedBox(height: 10),
                displayedFriends.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            final friend = displayedFriends[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: CustomCircleAvatar(
                                  imageUrl:
                                      '$baseUrl/user/profilePicture?username=${friend.username}',
                                  name: friend.firstName,
                                  radius: 25,
                                ),
                                title: Row(
                                  children: [
                                    Text(friend.username),
                                    const SizedBox(width: 10),
                                    friend.isAdminInChat
                                        ? const Icon(
                                            Icons.star_rounded,
                                            color: Colors.grey,
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.person_add_rounded),
                                  onPressed: () => handleAddMember(friend),
                                ),
                              ),
                            );
                          },
                          itemCount: displayedFriends.length,
                        ),
                      )
                    : const Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No friends to add",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          );
  }
}
