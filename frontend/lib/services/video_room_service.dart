import 'dart:convert';

import 'package:frontend/interfaces/video_room_details.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/fetch_with_token.dart';

class VideoRoomService {
  final StompService stompService = StompService();
  final AuthService authService = AuthService();

  Future<dynamic> createVideoRoom() async {
    final response = await HttpWithToken.post(
      url: "$baseUrl/videoRoom/createNew",
    );

    print("Response for create video room: ${response.body}");

    if (response.statusCode == 200) {
      return VideoRoomDetails.fromJson(jsonDecode(response.body));
    } else {
      return response.body;
    }
  }

  Future<dynamic> joinVideoRoom(String connectionCode) async {
    final response = await HttpWithToken.post(
      url: "$baseUrl/videoRoom/join/$connectionCode",
    );

    print("Response for join video room: ${response.body}");

    if (response.statusCode == 200) {
      return VideoRoomDetails.fromJson(jsonDecode(response.body));
    } else {
      return response.body;
    }
  }

  void leaveVideoRoom(String connectionCode) async {
    stompService.sendLeaveSignal(connectionCode);
  }

  void sendVideoPositionChange(
      String connectionCode, Duration position, bool isPlaying) {
    stompService.sendSeekSignal(connectionCode, position.toString(), isPlaying);
  }

  void sendVideoChange(String connectionCode, String videoId) {
    stompService.sendChangeVideoSignal(connectionCode, videoId);
  }

  void sendPauseSignal(String connectionCode) {
    stompService.sendPauseSignal(connectionCode);
  }

  void sendResumeSignal(String connectionCode) {
    stompService.sendResumeSignal(connectionCode);
  }

  void sendSyncVideoRequest(String connectionCode) {
    stompService.sendSyncVideoRequest(connectionCode);
  }

  void sendSyncPositionRequest(String connectionCode) {
    stompService.sendSyncPositionRequest(connectionCode);
  }

  void sendSyncVideoResponse(String connectionCode, String videoId) {
    stompService.sendSyncVideoResponse(connectionCode, videoId);
  }

  void sendSyncPositionResponse(
    String connectionCode,
    Duration position,
    bool isPlaying,
  ) {
    stompService.sendSyncPositionResponse(
      connectionCode,
      position.toString(),
      isPlaying,
    );
  }

  void loadNewVideo(String connectionCode, String videoId) {
    stompService.sendChangeVideoSignal(connectionCode, videoId);
  }
}
