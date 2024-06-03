import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/video_room_details.dart';
import 'package:frontend/services/video_room_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoRoomPage extends StatefulWidget {
  final String connectionCode;
  const VideoRoomPage({super.key, required this.connectionCode});

  @override
  State<VideoRoomPage> createState() => _VideoRoomPageState();
}

class _VideoRoomPageState extends State<VideoRoomPage> {
  late VideoRoomService videoRoomService;
  late VideoRoomDetails videoRoomDetails;
  final initialVideoUrl = "https://www.youtube.com/watch?v=3nQNiWdeH2Q";
  late YoutubePlayerController youtubePlayerController;
  final TextEditingController _videoUrlController = TextEditingController();
  bool _isFullScreen = false;
  bool totalDuration = true;
  bool _pageLoaded = false;

  void subscribeToVideoRoom() {
    // TODO: implement this
  }

  void unsubscribeFromVideoRoom() {
    // TODO: implement this
  }

  void handleLoadNewVideo() {
    // TODO: implement this
  }

  void handleCopyConnectionCode() async {
    await Clipboard.setData(
      ClipboardData(text: videoRoomDetails.connectionCode),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.grey[700],
        content: const Center(
            child: Text(
          "Copied to clipboard",
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
  }

  void fetchVideoRoomDetailsAndInit() async {
    final _videoRoomDetails =
        await videoRoomService.joinVideoRoom(widget.connectionCode);

    if (_videoRoomDetails is! VideoRoomDetails && mounted) {
      initFToast(context);
      showErrorToast(_videoRoomDetails);
      Navigator.pop(context);
      return;
    }

    setState(() {
      videoRoomDetails = _videoRoomDetails;
      _pageLoaded = true;
    });
  }

  void removeCachedImages() async {
    final profilePictureUrlList = videoRoomDetails.members
        .map((member) =>
            "$baseUrl/user/profilePicture?username=${member.username}")
        .toList();

    for (var url in profilePictureUrlList) {
      await CachedNetworkImage.evictFromCache(url);
    }
  }

  @override
  void initState() {
    super.initState();
    videoRoomService = Provider.of<VideoRoomService>(context, listen: false);
    youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(initialVideoUrl)!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    fetchVideoRoomDetailsAndInit();
  }

  @override
  void dispose() {
    unsubscribeFromVideoRoom();
    youtubePlayerController.dispose();
    removeCachedImages();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      appBar: _isFullScreen || !_pageLoaded
          ? null
          : AppBar(
              title: Row(
                children: [
                  const Text(
                    "Video Room",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => handleCopyConnectionCode(),
                    child: Text(
                      videoRoomDetails.connectionCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
              actions: _pageLoaded
                  ? ([
                      // const Text("Room Code:"),
                      // const SizedBox(width: 10),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ])
                  : [],
            ),
      body: _pageLoaded
          ? Center(
              child: Column(
                children: [
                  Expanded(
                    child: YoutubePlayer(
                      controller: youtubePlayerController,
                      onReady: () {
                        youtubePlayerController.addListener(() {
                          if (youtubePlayerController.value.isFullScreen !=
                              _isFullScreen) {
                            setState(() {
                              _isFullScreen =
                                  youtubePlayerController.value.isFullScreen;
                            });
                          }
                        });
                      },
                      bottomActions: [
                        CurrentPosition(),
                        ProgressBar(
                          isExpanded: true,
                          colors: const ProgressBarColors(
                            playedColor: Colors.blue,
                            handleColor: Color.fromARGB(255, 27, 103, 233),
                          ),
                        ),
                        RemainingDuration(),
                        FullScreenButton(),
                      ],
                    ),
                  ),
                  if (!_isFullScreen) ...[
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _videoUrlController,
                              decoration: const InputDecoration(
                                labelText: "YouTube Video URL",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => handleLoadNewVideo(),
                              child: const Text("Play"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Text(
                              "Members",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              videoRoomDetails.members.length.toString(),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.people_rounded,
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        children: videoRoomDetails.members
                            .map(
                              (member) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    CustomCircleAvatar(
                                      imageUrl:
                                          "$baseUrl/user/profilePicture?username=${member.username}",
                                      name: member.firstName,
                                      radius: 35,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      member.username,
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ]
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
