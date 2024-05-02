class RegexValidator {
  final RegExp _usernameRegex = RegExp(r'^[a-zA-Z_][a-zA-Z0-9._]{3,19}$');
  final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$');
  final RegExp _passwordRegex = RegExp(
      r'''^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!?()*\[\]+\-_.,:;<=>@'"])[A-Za-z\d!?()*\[\]+\-_.,:;<=>@'"]{8,}$''');
  final RegExp _nameRegex = RegExp(r"^\b([A-ZÀ-ÿ][-,a-z. ']+ *)+$");

  bool validateUsername(String username) {
    return _usernameRegex.hasMatch(username);
  }

  bool validateEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  bool validatePassword(String password) {
    return _passwordRegex.hasMatch(password);
  }

  bool validateName(String name) {
    return _nameRegex.hasMatch(name);
  }
}
