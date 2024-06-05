import 'package:frontend/interfaces/enums/video_room_signal_type.dart';

class VideoRoomSignal {
  final String connectionCode;
  final VideoRoomSignalType signalType;
  final String signalData;

  VideoRoomSignal({
    required this.connectionCode,
    required this.signalType,
    required this.signalData,
  });

  factory VideoRoomSignal.fromJson(Map<String, dynamic> json) {
    return VideoRoomSignal(
      connectionCode: json['connectionCode'],
      signalType: VideoRoomSignalType.values.firstWhere(
          (e) => e.toString() == 'VideoRoomSignalType.${json['signalType']}'),
      signalData: json['signalData'],
    );
  }
}
