import 'package:frontend/interfaces/user.dart';

class VideoRoomDetails {
  final String connectionCode;
  final List<User> members;

  VideoRoomDetails({
    required this.connectionCode,
    required this.members,
  });

  factory VideoRoomDetails.fromJson(Map<String, dynamic> json) {
    return VideoRoomDetails(
      connectionCode: json['connectionCode'],
      members: json['connectedUsersDetails']
          .map((userJson) => User.fromJson(userJson))
          .toList()
          .cast<User>(),
    );
  }
}
