class CallDetails {
  final String roomName;
  final String pictureString;
  final bool isPrivateChat;
  final DateTime startTime;
  final DateTime endTime;
  final List<int> userIds;

  CallDetails({
    required this.roomName,
    required this.pictureString,
    required this.isPrivateChat,
    required this.startTime,
    required this.endTime,
    required this.userIds,
  });

  factory CallDetails.fromJson(Map<String, dynamic> json) {
    return CallDetails(
      roomName: json['roomName'],
      pictureString: json['pictureString'],
      isPrivateChat: json['privateChat'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      userIds: List<int>.from(json['userIds']),
    );
  }
}
