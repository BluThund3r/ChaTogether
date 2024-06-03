import 'package:frontend/interfaces/enums/join_or_leave_type.dart';
import 'package:frontend/interfaces/user.dart';

class VideoRoomJoinOrLeave {
  final String connectionCode;
  final JoinOrLeaveType action;
  final User userDetails;

  VideoRoomJoinOrLeave({
    required this.connectionCode,
    required this.action,
    required this.userDetails,
  });

  factory VideoRoomJoinOrLeave.fromjson(Map<String, dynamic> json) {
    return VideoRoomJoinOrLeave(
      connectionCode: json['connectionCode'],
      action: JoinOrLeaveType.values.firstWhere(
          (e) => e.toString() == 'JoinOrLeaveType.${json['action']}'),
      userDetails: User.fromJson(json['userDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connectionCode': connectionCode,
      'action': action.toString(),
      'userDetails': userDetails.toJson(),
    };
  }
}
