import 'dart:convert';

import 'package:frontend/interfaces/video_room_details.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/fetch_with_token.dart';

class VideoRoomService {
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

  Future<dynamic> leaveVideoRoom(String connectionCode) async {
    // TODO: implement this
  }
}
