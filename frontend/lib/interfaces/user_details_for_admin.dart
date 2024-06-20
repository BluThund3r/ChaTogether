import 'package:frontend/interfaces/user.dart';

class UserDetailsForAdmin extends User {
  bool isAppAdmin;
  bool confirmedMail;

  UserDetailsForAdmin({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.online,
    required super.isAdminInChat,
    required this.isAppAdmin,
    required this.confirmedMail,
  });

  factory UserDetailsForAdmin.withUserDetails(
      User user, bool isAppAdmin, bool confirmedMail) {
    return UserDetailsForAdmin(
      id: user.id,
      username: user.username,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      online: user.online,
      isAdminInChat: user.isAdminInChat,
      isAppAdmin: isAppAdmin,
      confirmedMail: confirmedMail,
    );
  }

  factory UserDetailsForAdmin.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(json);
    final isAppAdmin = json['isAppAdmin'];
    final confirmedMail = json['confirmedMail'];
    return UserDetailsForAdmin.withUserDetails(user, isAppAdmin, confirmedMail);
  }
}
