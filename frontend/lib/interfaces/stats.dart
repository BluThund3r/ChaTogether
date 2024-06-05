class Stats {
  final int id;
  final int month;
  final int year;
  final int newUsersCount;
  final int videoRoomsCount;
  final int groupChatsCount;
  final int privateChatsCount;

  Stats({
    required this.id,
    required this.month,
    required this.year,
    required this.newUsersCount,
    required this.videoRoomsCount,
    required this.groupChatsCount,
    required this.privateChatsCount,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      id: json['id'],
      month: json['month'],
      year: json['year'],
      newUsersCount: json['newUsersCount'],
      videoRoomsCount: json['videoRoomsCount'],
      groupChatsCount: json['groupChatsCount'],
      privateChatsCount: json['privateChatsCount'],
    );
  }
}
