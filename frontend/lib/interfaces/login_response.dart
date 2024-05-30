class LoginResponse {
  final String token;
  final String publicKey;
  final String encryptedPrivateKey;

  LoginResponse({
    required this.token,
    required this.publicKey,
    required this.encryptedPrivateKey,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      publicKey: json['publicKey'],
      encryptedPrivateKey: json['encryptedPrivateKey'],
    );
  }
}
