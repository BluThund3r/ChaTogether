import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar_no_cache.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/chat_room_add_or_remove.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/interfaces/enums/chat_room_action.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late ChatRoomService chatRoomService;
  late AuthService authService;
  List<ChatRoomDetails> chatRoomsDetails = [];
  bool loading = true;
  final StompService _stompService = StompService();
  final List<Function({Map<String, String>? unsubscribeHeaders})>
      _unsubscribeFunctions = [];
  bool _subscribedToWsChannels = false;
  late LoggedUserInfo _loggedInUser;

  void subscribeToWsChannels() {
    _stompService.subscribeToChatRoomAddOrRemove(chatRoomAddOrRemoveHandler);
    _stompService.subscribeToChatRoomUpdates(chatRoomUpdatesHandler);
    setState(() => _subscribedToWsChannels = true);
    print("Subscribed to ws channels");
  }

  void unsubscribeFromWsChannels() {
    if (!_subscribedToWsChannels) return;
    for (var element in _unsubscribeFunctions) {
      element();
    }
    print("Unsubscribed from ws channels");
  }

  void chatRoomUpdatesHandler(StompFrame frame) async {
    // TODO: implement this
  }

  void addChatRoom(ChatRoomAddOrRemove chatRoomAddOrRemove) async {
    final user = _loggedInUser;
    if (chatRoomAddOrRemove.affectedUserIds.contains(user.userId)) {
      print("Adding chat room");
      setState(() {
        chatRoomsDetails.insert(
            0, ChatRoomDetails.fromAddOrRemove(chatRoomAddOrRemove));
      });
    }
  }

  void removeChatRoom(ChatRoomAddOrRemove chatRoomAddOrRemove) async {
    final user = _loggedInUser;
    print("Removing chat room");
    if (chatRoomAddOrRemove.affectedUserIds.contains(user.userId)) {
      setState(() {
        chatRoomsDetails
            .removeWhere((element) => element.id == chatRoomAddOrRemove.id);
      });
    }
  }

  void chatRoomAddOrRemoveHandler(StompFrame frame) {
    print("Received chat room add or remove: ${frame.body}");
    if (frame.body == null) return;
    ChatRoomAddOrRemove chatRoomAddOrRemove =
        ChatRoomAddOrRemove.fromJson(jsonDecode(frame.body!));
    print("Chat room add or remove: $chatRoomAddOrRemove");

    if (chatRoomAddOrRemove.action == ChatRoomAction.ADD) {
      addChatRoom(chatRoomAddOrRemove);
    } else {
      removeChatRoom(chatRoomAddOrRemove);
    }
  }

  void fetchDataAndSubscribeToWs() async {
    _loggedInUser = await authService.getLoggedInUser();
    final response = await chatRoomService.getChatsOfUser();
    if (response is! List<ChatRoomDetails> && mounted) {
      initFToast(context);
      showErrorToast(response);
      setState(() => loading = false);
      return;
    }

    if (mounted) {
      print("Setting the chats in the page");
      setState(() {
        chatRoomsDetails = response;
        loading = false;
      });
      // print("Chats: ${chatRoomsDetails}");
      subscribeToWsChannels();
    }
  }

  @override
  void initState() {
    super.initState();
    chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    fetchDataAndSubscribeToWs();
  }

  @override
  void dispose() {
    unsubscribeFromWsChannels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : chatRoomsDetails.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.forum,
                      size: 150,
                      color: Colors.grey,
                    ),
                    Text(
                      "No chats found",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Click on the blue button to create a new chat",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: chatRoomsDetails.length,
                        itemBuilder: (context, index) {
                          final chatRoom = chatRoomsDetails[index];
                          final privateChat = chatRoom.isPrivateChat();
                          final otherMember =
                              chatRoom.otherMember(_loggedInUser.userId);
                          final seenLastMessage = chatRoom.lastMessage.seenBy
                              .contains(_loggedInUser.userId);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: privateChat
                                  ? CustomCircleAvatarNoCache(
                                      imageUrl:
                                          "$baseUrl/user/profilePicture?username=${otherMember.username}",
                                      name: otherMember.firstName,
                                      radius: 25,
                                    )
                                  : const CircleAvatar(
                                      radius: 25,
                                      child:
                                          Icon(Icons.group_rounded, size: 30),
                                    ),
                              title: Row(
                                children: [
                                  Text(
                                    privateChat
                                        ? otherMember.username
                                        : chatRoom.roomName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: !seenLastMessage
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!seenLastMessage)
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Colors.blue,
                                          size: 15,
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  Text(
                                    chatRoom.isPrivateChat()
                                        ? "Private"
                                        : "Group",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                              onTap: () {
                                GoRouter.of(context)
                                    .push('/chat/${chatRoom.id}');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
  }
}
