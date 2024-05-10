import 'package:frontend/interfaces/user.dart';

class FriendRequest {
  User sender;
  User receiver;
  DateTime sentAt;

  FriendRequest({
    required this.sender,
    required this.receiver,
    required this.sentAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      sentAt: DateTime.parse(json['sentAt']),
    );
  }
}
