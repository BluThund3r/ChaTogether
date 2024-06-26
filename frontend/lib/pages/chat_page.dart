import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/add_member_to_chat_modal.dart';
import 'package:frontend/components/change_group_picture.dart';
import 'package:frontend/components/chat_members_modal.dart';
import 'package:frontend/components/chat_message_widget.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/components/edit_group_name_modal.dart';
import 'package:frontend/components/long_press_message_options.dart';
import 'package:frontend/components/send_chat_image_modal.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/chat_message.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/enums/action_type.dart';
import 'package:frontend/interfaces/enums/chat_message_type.dart';
import 'package:frontend/interfaces/outgoing_chat_message.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/chat_message_service.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:frontend/services/friend_service.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/crypto_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  late Uint8List chatRoomKey;
  late IV chatRoomIv;
  late ChatMessageService chatMessageService;
  late ChatRoomService chatRoomService;
  late FriendService friendService;
  final StompService stompService = StompService();
  late ChatRoomDetails chatRoomDetails;
  late AuthService authService;
  late LoggedUserInfo loggedInUser;
  late bool pageLoading = true;
  late bool? blockedUsers = false;
  late bool partOfChat = true;
  late bool areMessagesLeftToFetch = true;
  late User? otherMember;
  bool isLockedToBottom = true;
  List<String> profilePictureUrls = [];
  List<ChatMessage> messages = [];
  final TextEditingController messageSendController = TextEditingController();
  final TextEditingController messageEditController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late dynamic unsubscribeWS;
  final FocusNode focusNode = FocusNode();
  late int imageKey;
  bool isTypingMessage = false;

  bool allowedToSendMessage() {
    return !blockedUsers! && partOfChat;
  }

  bool isLoggedInUserChatAdmin() {
    return chatRoomDetails.members
        .firstWhere((element) => element.id == loggedInUser.userId)
        .isAdminInChat;
  }

  void sendTextMessage() async {
    final plaintext = messageSendController.text;
    print("Trying to send message: $plaintext");
    if (plaintext.isEmpty) return;
    messageSendController.clear();
    final encryptedMessage =
        await CryptoUtils.encryptWithAES(plaintext, chatRoomKey, chatRoomIv);
    final messageToSend = OutgoingChatMessage(
        encryptedContent: encryptedMessage, type: ChatMessageType.TEXT);
    stompService.sendChatMessage(messageToSend, widget.chatId);
  }

  void onMessageReceived(StompFrame frame) async {
    if (frame.body == null) return;
    print("Received message: ${frame.body}");
    final message = ChatMessage.fromJson(jsonDecode(frame.body!));

    if (message.action == ActionType.BLOCK) {
      setState(() {
        blockedUsers = true;
      });
      return;
    }

    if (message.action == ActionType.UNBLOCK) {
      setState(() {
        blockedUsers = false;
      });
      return;
    }

    if (message.action != ActionType.SEND) {
      final messageIndex =
          messages.indexWhere((element) => element.id == message.id);
      final decryptedMessage = await CryptoUtils.decryptChatMessage(
          message, chatRoomKey, chatRoomIv);
      if (messageIndex != -1) {
        print("Updating message: ${message.id} at index: $messageIndex");
        setState(() {
          messages[messageIndex] = decryptedMessage;
        });
      }
    } else {
      final decryptedMessage = await CryptoUtils.decryptChatMessage(
          message, chatRoomKey, chatRoomIv);

      setState(() {
        messages.add(decryptedMessage);
      });
      if (message.type == ChatMessageType.ANNOUNCEMENT &&
          message.content!.contains("changed the group name to")) {
        chatRoomDetails.roomName = message.content!.split('"')[1];
      }
      if (message.type == ChatMessageType.ANNOUNCEMENT &&
          message.content!.contains("changed the group picture")) {
        CachedNetworkImage.evictFromCache(
          "$baseUrl/chatRoom/groupPicture?chatRoomId=${chatRoomDetails.id}",
        );
        setState(() {
          imageKey = DateTime.now().millisecondsSinceEpoch;
        });
      }

      if (decryptedMessage.senderId != loggedInUser.userId) {
        stompService.seeMessage(decryptedMessage.id, widget.chatId);
        if (isLockedToBottom) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _scrollToBottom();
          });
        }
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToBottom();
        });
      }
    }
  }

  void fetchMoreMessages() async {
    if (!areMessagesLeftToFetch) return;
    final oldestMessageSentAt = messages.first.sentAt;
    final newMessages = await chatMessageService.getChatMessagesDecryptedBefore(
        widget.chatId, chatRoomKey, chatRoomIv, oldestMessageSentAt);
    if (newMessages.isEmpty) {
      setState(() => areMessagesLeftToFetch = false);
      return;
    }
    setState(() {
      messages.insertAll(0, newMessages);
    });
    if (newMessages.length < messagesFetchedOnce) {
      setState(() => areMessagesLeftToFetch = false);
    }
  }

  void fetchDataAndSubscribeWS() async {
    loggedInUser = await authService.getLoggedInUser();
    chatRoomDetails = await chatRoomService.getChatRoomById(widget.chatId);
    if (chatRoomDetails is String && mounted) {
      initFToast(context);
      showErrorToast("Failed to fetch chat details");
      return;
    }
    if (chatRoomDetails.isPrivateChat()) {
      otherMember = chatRoomDetails.otherMember(loggedInUser.userId);
      blockedUsers = await friendService.areUsersBlocked(
        loggedInUser.userId,
        otherMember!.id,
      );
    }

    messages = await chatMessageService.getChatMessagesDecrypted(
        widget.chatId, chatRoomKey, chatRoomIv);

    if (messages.isEmpty || messages.length < messagesFetchedOnce) {
      setState(() => areMessagesLeftToFetch = false);
    }

    for (var member in chatRoomDetails.members) {
      profilePictureUrls
          .add('$baseUrl/user/profilePicture?username=${member.username}');
      profilePictureUrls
          .add('$baseUrl/user/profilePictureById?userId=${member.id}');
    }

    unsubscribeWS =
        stompService.subscribeToChatRoom(widget.chatId, onMessageReceived);
    print("Subscribed to chat room: ${widget.chatId}");

    setState(() {
      pageLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToBottom();
    });

    stompService.seeAllMessages(chatRoomDetails.id);
  }

  void evictAllProfilePicturesFromCache() async {
    for (final url in profilePictureUrls) {
      await CachedNetworkImage.evictFromCache(url);
    }

    await CachedNetworkImage.evictFromCache(
        "$baseUrl/chatRoom/groupPicture?chatRoomId=${chatRoomDetails.id}");
  }

  void showAddMemberModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddMemberToChatModal(
          chatRoomDetails: chatRoomDetails,
          chatKey: chatRoomKey,
          chatIv: chatRoomIv,
          loggedUserInfo: loggedInUser,
        );
      },
    );
  }

  void showMembersModal(
      context, ChatRoomDetails chatRoomDetails, LoggedUserInfo loggedUserInfo) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ChatMembersModal(
          chatRoomDetails: chatRoomDetails,
          loggedUserInfo: loggedUserInfo,
          chatRoomKey: chatRoomKey,
          chatRoomIv: chatRoomIv,
        );
      },
    );
  }

  void handleLeaveChat() async {
    final plaintextContent = "${loggedInUser.username} left the chat";
    final encryptedContent = await CryptoUtils.encryptWithAES(
      plaintextContent,
      chatRoomKey,
      chatRoomIv,
    );

    stompService.sendChatMessage(
      OutgoingChatMessage(
        type: ChatMessageType.ANNOUNCEMENT,
        encryptedContent: encryptedContent,
      ),
      widget.chatId,
    );

    await CryptoUtils.removeConversationKeyAndIV(widget.chatId);
    chatRoomService.leaveChat(widget.chatId);
    GoRouter.of(context).go('/');
  }

  void showGroupPictureUpdateModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ChangeGroupPictureModal(
            chatRoomDetails: chatRoomDetails,
            chatRoomKey: chatRoomKey,
            chatRoomIv: chatRoomIv,
          );
        });
  }

  void showEditGroupNameModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EditGroupNameModal(
          chatRoomDetails: chatRoomDetails,
          chatRoomKey: chatRoomKey,
          chatRoomIv: chatRoomIv,
        );
      },
    );
  }

  void showOptionsModal(context) {
    bool isLoggedInUserAdmin = chatRoomDetails.members
        .firstWhere((member) => member.id == loggedInUser.userId)
        .isAdminInChat;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!chatRoomDetails.isPrivateChat())
              ListTile(
                leading: const Icon(Icons.people_rounded),
                title: const Text("View members"),
                onTap: () {
                  showMembersModal(context, chatRoomDetails, loggedInUser);
                },
              ),
            if (isLoggedInUserAdmin && !chatRoomDetails.isPrivateChat())
              ListTile(
                leading: const Icon(Icons.person_add_rounded),
                title: const Text("Add new member"),
                onTap: () {
                  showAddMemberModal(context);
                },
              ),
            if (isLoggedInUserAdmin && !chatRoomDetails.isPrivateChat())
              ListTile(
                leading: const Icon(Icons.image_rounded),
                title: const Text("Change Group Picture"),
                onTap: () {
                  showGroupPictureUpdateModal(context);
                },
              ),
            if (isLoggedInUserAdmin && !chatRoomDetails.isPrivateChat())
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text("Change Group Name"),
                onTap: () {
                  showEditGroupNameModal(context);
                },
              ),
            if (!chatRoomDetails.isPrivateChat())
              ListTile(
                leading: const Icon(Icons.exit_to_app_rounded),
                title: const Text("Leave chat"),
                onTap: () => handleLeaveChat(),
              ),
            if (chatRoomDetails.isPrivateChat())
              ListTile(
                leading: blockedUsers!
                    ? const Icon(Icons.lock_open)
                    : const Icon(Icons.block_rounded),
                title: blockedUsers!
                    ? const Text("Unblock user")
                    : const Text("Block user"),
                onTap: () async {
                  if (blockedUsers!) {
                    final response =
                        await friendService.unblockUser(otherMember!.username);
                    if (response == null) {
                      setState(() {
                        blockedUsers = false;
                      });
                    } else {
                      initFToast(context);
                      showErrorToast(response);
                    }
                  } else {
                    final response =
                        await friendService.blockUser(otherMember!.username);
                    if (response == null) {
                      setState(() {
                        blockedUsers = true;
                      });
                    } else {
                      initFToast(context);
                      showErrorToast(response);
                    }
                  }
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }

  void loadChatRoomKeyAndIv() async {
    final keyAndIv = await CryptoUtils.getConversationKeyAndIV(widget.chatId);
    if (keyAndIv == null) {
      initFToast(context);
      showErrorToast("Failed to load chat key and IV.");
      Navigator.pop(context);
      return;
    }
    chatRoomKey = keyAndIv[0] as Uint8List;
    chatRoomIv = keyAndIv[1] as IV;
  }

  void _jumpToBottom() {
    if (messages.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _scrollToBottom() {
    if (messages.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    });
  }

  void unsubscribeFromWS() {
    if (unsubscribeWS != null) {
      unsubscribeWS();
      unsubscribeWS = null;
    }
  }

  void handleMessageLongPress(ChatMessage message, BuildContext context) {
    if (message.type == ChatMessageType.IMAGE &&
        message.senderId != loggedInUser.userId) return;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return LongPressMessageOptions(
          message: message,
          loggedUserInfo: loggedInUser,
          chatRoomKey: chatRoomKey,
          chatRoomIv: chatRoomIv,
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    evictAllProfilePicturesFromCache();
    messageSendController.dispose();
    messageEditController.dispose();
    _scrollController.dispose();
    focusNode.dispose();
    unsubscribeFromWS();
    print("Unsubscribed from chat room: ${widget.chatId}");
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    imageKey = DateTime.now().millisecondsSinceEpoch;
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        isLockedToBottom = true;
      }
      if (_scrollController.position.pixels <
          _scrollController.position.maxScrollExtent) {
        isLockedToBottom = false;
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.offset == 0) {
        fetchMoreMessages();
      }
    });

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() => isTypingMessage = true);
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => _scrollToBottom(),
        );
      }

      if (!focusNode.hasFocus) {
        setState(() => isTypingMessage = false);
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => _scrollToBottom(),
        );
      }
    });

    chatMessageService =
        Provider.of<ChatMessageService>(context, listen: false);
    chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    friendService = Provider.of<FriendService>(context, listen: false);
    loadChatRoomKeyAndIv();
    fetchDataAndSubscribeWS();
  }

  void showSendImageModal(ImageSource imageSource, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SendChatImageModal(
          source: imageSource,
          chatRoomKey: chatRoomKey,
          chatRoomIv: chatRoomIv,
          chatRoomDetails: chatRoomDetails,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? otherMember;
    if (!pageLoading) {
      otherMember = chatRoomDetails.isPrivateChat()
          ? chatRoomDetails.otherMember(loggedInUser.userId)
          : null;
    }
    return Scaffold(
      appBar: !pageLoading
          ? AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: chatRoomDetails.isPrivateChat()
                    ? CustomCircleAvatar(
                        imageUrl:
                            '$baseUrl/user/profilePicture?username=${otherMember!.username}',
                        name: otherMember.firstName,
                        radius: 25,
                      )
                    : CustomCircleAvatar(
                        name: "",
                        key: ValueKey(imageKey),
                        imageUrl:
                            "$baseUrl/chatRoom/groupPicture?chatRoomId=${chatRoomDetails.id}",
                        isGroupConversation: true,
                        radius: 25,
                      ),
              ),
              title: Row(
                children: [
                  Text(
                    chatRoomDetails.isPrivateChat()
                        ? chatRoomDetails
                            .otherMember(loggedInUser.userId)
                            .username
                        : chatRoomDetails.roomName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
              actions: [
                Text(
                  chatRoomDetails.isPrivateChat() ? "Private" : "Group",
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      GoRouter.of(context).push("/call/${widget.chatId}"),
                  icon: const Icon(Icons.add_ic_call_rounded),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () => showOptionsModal(context),
                ),
              ],
            )
          : null,
      body: pageLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                messages.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No messages yet",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Type a message and send it to start chatting",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return ListView.builder(
                              addAutomaticKeepAlives: true,
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              controller: _scrollController,
                              itemCount: messages.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0 && areMessagesLeftToFetch) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (index == 0) {
                                  return const SizedBox(height: 0);
                                }
                                final message = messages[index - 1];
                                return GestureDetector(
                                  onLongPress: () =>
                                      handleMessageLongPress(message, context),
                                  child: ChatMessageWidget(
                                    message: message,
                                    isCurrentUser:
                                        message.senderId == loggedInUser.userId,
                                    privateChat:
                                        chatRoomDetails.isPrivateChat(),
                                    members: chatRoomDetails.members,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                const Divider(
                  height: 0,
                ),
                allowedToSendMessage()
                    ? Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 5, 29, 48),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              if (!isTypingMessage)
                                IconButton(
                                  onPressed: () => showSendImageModal(
                                      ImageSource.camera, context),
                                  icon: const Icon(Icons.camera_alt_rounded),
                                  padding: EdgeInsets.zero,
                                ),
                              if (!isTypingMessage)
                                IconButton(
                                  icon: const Icon(Icons.photo_rounded),
                                  onPressed: () => showSendImageModal(
                                      ImageSource.gallery, context),
                                  padding: EdgeInsets.zero,
                                ),
                              Expanded(
                                child: TextField(
                                  focusNode: focusNode,
                                  controller: messageSendController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    hintText: "Type a message...",
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[600]!,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(25),
                                      ),
                                      gapPadding: 0,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[600]!,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(25),
                                      ),
                                      gapPadding: 0,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: sendTextMessage,
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "You can't send messages to this chat.",
                            style: TextStyle(
                              color: Color.fromARGB(255, 211, 89, 81),
                              // fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
}
