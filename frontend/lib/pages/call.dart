import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/call_service.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:provider/provider.dart';

class CallPage extends StatefulWidget {
  final String chatRoomId;
  const CallPage({
    super.key,
    required this.chatRoomId,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late ChatRoomDetails chatRoomDetails;
  late LoggedUserInfo loggedUserInfo;
  late AgoraClient client;
  late AuthService authService;
  late ChatRoomService chatRoomService;
  late CallService callService;
  bool initialized = false;
  bool isSpeakerOn = true;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
    callService = Provider.of<CallService>(context, listen: false);
    loadDetailsAndInitAgora();
  }

  void loadDetailsAndInitAgora() async {
    loggedUserInfo = await authService.getLoggedInUser();
    chatRoomDetails = await chatRoomService.getChatRoomById(widget.chatRoomId);
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: dotenv.env["AGORA_ID"] ?? "Missing Agora App ID",
        channelName: chatRoomDetails.id,
        username: loggedUserInfo.username,
      ),
    );
    await client.initialize();
    setState(() => initialized = true);
    await callService.joinCall(chatRoomDetails.id);
    print(
        "Initialized everything: ${chatRoomDetails.roomName}, ${loggedUserInfo.username}");
  }

  @override
  void dispose() {
    client.release();
    callService.leaveCall(chatRoomDetails.id);
    super.dispose();
  }

  void _toggleSpeaker() {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
    client.engine.setEnableSpeakerphone(isSpeakerOn);
  }

  @override
  Widget build(BuildContext context) {
    return !initialized
        ? const Scaffold(
            body: Center(
            child: CircularProgressIndicator(),
          ))
        : Scaffold(
            appBar: AppBar(
              title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Video Call in ${chatRoomDetails.roomName}')),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon:
                      Icon(isSpeakerOn ? Icons.volume_up : Icons.phone_rounded),
                  onPressed: _toggleSpeaker,
                ),
              ],
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  AgoraVideoViewer(
                    showNumberOfUsers: true,
                    client: client,
                    layoutType: Layout.floating,
                    enableHostControls:
                        true, 
                  ),
                  AgoraVideoButtons(
                    client: client,
                    addScreenSharing:
                        false,
                  ),
                ],
              ),
            ),
          );
  }
}
