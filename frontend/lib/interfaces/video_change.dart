class VideoChange {
  final String newVideoId;

  VideoChange({
    required this.newVideoId,
  });

  Map<String, dynamic> toJson() {
    return {
      "newVideoId": newVideoId,
    };
  }

  factory VideoChange.fromJson(Map<String, dynamic> json) {
    return VideoChange(
      newVideoId: json['newVideoId'],
    );
  }
}
