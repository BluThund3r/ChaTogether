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
}
