import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/video_room_details.dart';
import 'package:frontend/services/video_room_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  final TextEditingController _connectionCodeController =
      TextEditingController();
  late VideoRoomService videoRoomService;

  void handleCreateRoom() async {
    final videoRoomDetails = await videoRoomService.createVideoRoom();

    if (videoRoomDetails is! VideoRoomDetails && mounted) {
      initFToast(context);
      showErrorToast(videoRoomDetails);
      print("Error creating video room: $videoRoomDetails");
      return;
    }

    GoRouter.of(context).push(
      "/videoRoom/${videoRoomDetails.connectionCode}",
    );
  }

  void handleUserJoinRoom() {
    final connectionCode = _connectionCodeController.text;

    if (connectionCode.isEmpty) {
      initFToast(context);
      showInfoToast("Connection code is required");
      return;
    }

    GoRouter.of(context).push("/videoRoom/$connectionCode");
  }

  void showJoinRoomModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Join Room",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _connectionCodeController,
                  decoration: const InputDecoration(
                    labelText: "Connection Code (6 digits)",
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => handleUserJoinRoom(),
                  child: const Text("Join"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    videoRoomService = Provider.of<VideoRoomService>(context, listen: false);
  }

  @override
  void dispose() {
    _connectionCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.live_tv_rounded,
            size: 150,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          const Text(
            "Watch YouTube videos with friends",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => handleCreateRoom(),
                    child: const Text("Create Room"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => showJoinRoomModal(context),
                    child: const Text("Join Room"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "Create a room and share the connection code",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "OR",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Join a room with the connection code received",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
