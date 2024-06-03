import 'package:frontend/services/auth_service.dart';

class User {
  int id;
  String username;
  String email;
  String firstName;
  String lastName;
  bool online;
  bool isAdminInChat;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.online,
    required this.isAdminInChat,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      online: json['online'],
      isAdminInChat: json['isAdminInChat'] ?? false,
    );
  }

  factory User.empty() {
    return User(
      id: 0,
      username: '',
      email: '',
      firstName: '',
      lastName: '',
      online: false,
      isAdminInChat: false,
    );
  }

  factory User.fromLoggedIn(LoggedUserInfo loggedUserInfo) {
    return User(
      id: loggedUserInfo.userId,
      username: loggedUserInfo.username,
      email: loggedUserInfo.email,
      firstName: loggedUserInfo.firstName,
      lastName: loggedUserInfo.lastName,
      online: false,
      isAdminInChat: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'online': online,
      'isAdminInChat': isAdminInChat,
    };
  }
}
