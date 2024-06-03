class VideoPositionChange {
  final String position;
  final bool isPlaying;

  VideoPositionChange({
    required this.position,
    required this.isPlaying,
  });

  Map<String, dynamic> toJson() {
    return {
      "position": position,
      "isPlaying": isPlaying,
    };
  }
}
