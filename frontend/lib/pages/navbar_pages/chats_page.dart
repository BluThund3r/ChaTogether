import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
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
  final StompService stompService = StompService();
  late ChatRoomService chatRoomService;
  List<ChatRoomDetails> chatRoomsDetails = [];
  dynamic _unsubscribeFromChatRoomsUpdates = (StompFrame frame) {};
  bool loading = true;

  void fetchDataAndOpenWsConnection() async {
    final response = await chatRoomService.getChatsOfUser();
    if (response is! List<ChatRoomDetails>) {
      initFToast(context);
      showErrorToast(response);
      setState(() => loading = false);
      return;
    }

    setState(() {
      chatRoomsDetails = response;
      loading = false;
    });

    stompService.subscribeToChatRoomUpdates(onChatUpdateReceived);
  }

  void onChatUpdateReceived(StompFrame frame) {
    // TODO: Implement this
  }

  @override
  void initState() {
    super.initState();
    chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
    fetchDataAndOpenWsConnection();
  }

  @override
  void dispose() {
    _unsubscribeFromChatRoomsUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: loading
            ? const CircularProgressIndicator()
            : chatRoomsDetails.isEmpty
                ? const Column(
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
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: chatRoomsDetails.length,
                    itemBuilder: (context, index) {
                      final chatRoom = chatRoomsDetails[index];
                      return ListTile(
                        // title: Text(chatRoom.name),
                        onTap: () {
                          GoRouter.of(context).go('/chat/${chatRoom.id}');
                        },
                      );
                    },
                  ));
  }
}
