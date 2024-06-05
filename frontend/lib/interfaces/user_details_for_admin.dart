import 'package:frontend/interfaces/user.dart';

class UserDetailsForAdmin extends User {
  bool isAppAdmin;

  UserDetailsForAdmin({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.online,
    required super.isAdminInChat,
    required this.isAppAdmin,
  });

  factory UserDetailsForAdmin.withUserDetails(User user, bool isAppAdmin) {
    return UserDetailsForAdmin(
      id: user.id,
      username: user.username,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      online: user.online,
      isAdminInChat: user.isAdminInChat,
      isAppAdmin: isAppAdmin,
    );
  }

  factory UserDetailsForAdmin.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(json);
    final isAppAdmin = json['isAppAdmin'];
    return UserDetailsForAdmin.withUserDetails(user, isAppAdmin);
  }
}
