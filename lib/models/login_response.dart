class LoginResponse {
  final String token;
  final int userId;
  final String role;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print("LOGIN JSON RECEIVED: $json"); // debug

    return LoginResponse(
      token: json['token'] as String,

      // 🔥 IMPORTANT: explicit cast from num → int
      userId: (json['userId'] as num).toInt(),

      role: json['role'] as String,
    );
  }
}
