import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/enums/join_or_leave_type.dart';
import 'package:frontend/interfaces/enums/video_room_signal_type.dart';
import 'package:frontend/interfaces/video_room_details.dart';
import 'package:frontend/interfaces/video_room_join_or_leave.dart';
import 'package:frontend/interfaces/video_room_signal.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/services/video_room_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/parse_duration.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoRoomPage extends StatefulWidget {
  final String connectionCode;
  const VideoRoomPage({super.key, required this.connectionCode});

  @override
  State<VideoRoomPage> createState() => _VideoRoomPageState();
}

class _VideoRoomPageState extends State<VideoRoomPage>
    with WidgetsBindingObserver {
  late VideoRoomService videoRoomService;
  final StompService stompService = StompService();
  late VideoRoomDetails videoRoomDetails;
  final initialVideoUrl = "https://www.youtube.com/watch?v=3nQNiWdeH2Q";
  late YoutubePlayerController youtubePlayerController;
  final TextEditingController _videoUrlController = TextEditingController();
  bool _isFullScreen = false;
  bool _pageLoaded = false;
  bool _isPlaying = false;
  bool _syncedVideo = false;
  bool _syncedPosition = false;
  Duration _lastPosition = const Duration(seconds: 0);
  bool _signalsOff = false;
  List<dynamic> unsubscribeFunctions = [];

  void handleVideoRoomSignalReceived(StompFrame frame) {
    if (frame.body == null) return;

    print("Received video room signal: ${frame.body} at ${DateTime.now()}");
    final videoRoomSignal = VideoRoomSignal.fromJson(jsonDecode(frame.body!));
    switch (videoRoomSignal.signalType) {
      case VideoRoomSignalType.SYNC_VIDEO:
        if (_syncedVideo && videoRoomDetails.members.length > 1) {
          videoRoomService.sendSyncVideoResponse(
            videoRoomDetails.connectionCode,
            youtubePlayerController.metadata.videoId,
          );
        }
        break;
      case VideoRoomSignalType.SYNC_POSITION:
        if (_syncedPosition) {
          videoRoomService.sendSyncPositionResponse(
            videoRoomDetails.connectionCode,
            youtubePlayerController.value.position,
            youtubePlayerController.value.isPlaying,
          );
        }
        break;
      case VideoRoomSignalType.SYNC_VIDEO_RESPONSE:
        if (!_syncedVideo) {
          videoRoomService
              .sendSyncPositionRequest(videoRoomDetails.connectionCode);
          if (!validVideoId(videoRoomSignal.signalData)) return;
          _signalsOff = true;
          youtubePlayerController.load(videoRoomSignal.signalData);
          _signalsOff = false;
          _syncedVideo = true;
        }
        break;
      case VideoRoomSignalType.SYNC_POSITION_RESPONSE:
        if (!_syncedPosition) {
          final [duration, isPlaying] =
              parseVideoPositionResponse(videoRoomSignal.signalData);
          if (duration == null) return;
          _signalsOff = true;
          youtubePlayerController.seekTo(duration);
          if (!isPlaying) {
            youtubePlayerController.pause();
          }
          _signalsOff = false;
          _syncedPosition = true;
        }
        break;
      case VideoRoomSignalType.PAUSE:
        if (_syncedPosition) {
          _signalsOff = true;
          youtubePlayerController.pause();
          _signalsOff = false;
        }
        break;
      case VideoRoomSignalType.RESUME:
        if (_syncedPosition) {
          _signalsOff = true;
          youtubePlayerController.play();
          _signalsOff = false;
        }
        break;
      case VideoRoomSignalType.CHANGE_VIDEO:
        if (!validVideoId(videoRoomSignal.signalData)) return;
        _signalsOff = true;
        youtubePlayerController.load(videoRoomSignal.signalData);
        youtubePlayerController.pause();
        _signalsOff = false;
        if (!_syncedVideo || !_syncedPosition) {
          _syncedPosition = true;
          _syncedVideo = true;
        }
        break;
      case VideoRoomSignalType.SEEK:
        if (_syncedPosition) {
          final [duration, isPlaying] =
              parseVideoPositionResponse(videoRoomSignal.signalData);
          if (duration == null) return;
          _lastPosition = duration;
          _signalsOff = true;
          youtubePlayerController.seekTo(duration);
          if (!isPlaying) {
            youtubePlayerController.pause();
          }
          _signalsOff = false;
        }
        break;
      default:
        return;
    }
  }

  bool validVideoId(String? videoId) {
    if (videoId == null || videoId.isEmpty) return false;

    final RegExp regExp = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    return regExp.hasMatch(videoId);
  }

  List<dynamic> parseVideoPositionResponse(String stringToParse) {
    final List<String> parts = stringToParse.split("|");
    final position = parseDuration(parts[0]);
    if (position == null) return [null, null];
    bool isPlaying;
    try {
      isPlaying = bool.parse(parts[1], caseSensitive: false);
    } on FormatException {
      return [null, null];
    }

    return [position, isPlaying];
  }

  void handleLoadNewVideo() {
    final videoUrl = _videoUrlController.text;
    print("Loading new video: $videoUrl");

    if (videoUrl.isEmpty) return;

    final videoId =
        YoutubePlayer.convertUrlToId(videoUrl, trimWhitespaces: true);

    if (videoId == null) {
      initFToast(context);
      showErrorToast("URL not valid");
      return;
    }

    videoRoomService.loadNewVideo(videoRoomDetails.connectionCode, videoId);
    _videoUrlController.clear();
  }

  void handlePauseVideo() {
    print("Pausing video");
    videoRoomService.sendPauseSignal(videoRoomDetails.connectionCode);
  }

  void handleResumeVideo() {
    print("Resuming video");
    videoRoomService.sendResumeSignal(videoRoomDetails.connectionCode);
  }

  void handleSeekToPosition(Duration position) {
    print("Seek to position: ${position.toString()}");
    videoRoomService.sendVideoPositionChange(
      videoRoomDetails.connectionCode,
      position,
      youtubePlayerController.value.isPlaying,
    );
  }

  void handleVideoRoomJoinOrLeaveReceived(StompFrame frame) {
    if (frame.body == null) return;
    print("Received video room join or leave signal: ${frame.body}");
    final VideoRoomJoinOrLeave videoRoomJoinOrLeave =
        VideoRoomJoinOrLeave.fromjson(jsonDecode(frame.body!));

    if (videoRoomJoinOrLeave.action == JoinOrLeaveType.JOIN) {
      setState(() {
        videoRoomDetails.members.add(videoRoomJoinOrLeave.userDetails);
      });
    } else {
      setState(() {
        videoRoomDetails.members.removeWhere((member) =>
            member.username == videoRoomJoinOrLeave.userDetails.username);
      });
    }
  }

  void subscribeToVideoRoom() {
    print("Subscribing to video room signals and join or leave");
    final unsubscribe1 = stompService.subscribeToVideoRoomSignals(
      videoRoomDetails.connectionCode,
      handleVideoRoomSignalReceived,
    );

    final unsubscribe2 = stompService.subscribeToVideoRoomJoinOrLeave(
      videoRoomDetails.connectionCode,
      handleVideoRoomJoinOrLeaveReceived,
    );

    unsubscribeFunctions = [unsubscribe1, unsubscribe2];
  }

  void signalLeaving() {
    videoRoomService.leaveVideoRoom(videoRoomDetails.connectionCode);
  }

  void unsubscribeFromVideoRoom() {
    print("Unsubscribing from video room signals and join or leave");
    for (var unsubscribe in unsubscribeFunctions) {
      unsubscribe();
    }
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
      if (videoRoomDetails.members.length == 1) {
        _syncedPosition = true;
        _syncedVideo = true;
      }
    });

    subscribeToVideoRoom();
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

  void videoControllerListener() {
    if (youtubePlayerController.value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = youtubePlayerController.value.isPlaying;
      });

      if (_signalsOff) return;

      if (_isPlaying) {
        handleResumeVideo();
      } else {
        handlePauseVideo();
      }
      return;
    }

    if (youtubePlayerController.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = youtubePlayerController.value.isFullScreen;
      });
      return;
    }

    Duration currentPosition = youtubePlayerController.value.position;
    if (_signalsOff) {
      _lastPosition = currentPosition;
      return;
    }

    if ((currentPosition - _lastPosition).abs() >
        const Duration(milliseconds: 1000)) {
      handleSeekToPosition(currentPosition);
    }
    _lastPosition = currentPosition;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    videoRoomService = Provider.of<VideoRoomService>(context, listen: false);
    youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(initialVideoUrl)!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    )..addListener(videoControllerListener);
    fetchVideoRoomDetailsAndInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unsubscribeFromVideoRoom();
    youtubePlayerController.dispose();
    removeCachedImages();
    signalLeaving();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      signalLeaving();
      unsubscribeFromVideoRoom();
      removeCachedImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        if (!_syncedVideo) {
                          videoRoomService.sendSyncVideoRequest(
                              videoRoomDetails.connectionCode);
                        }
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
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
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
