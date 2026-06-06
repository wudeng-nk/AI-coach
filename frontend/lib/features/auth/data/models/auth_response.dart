class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final LoginUserInfo? user;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
    this.expiresIn = 1800,
    this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['access_token'],
        refreshToken: json['refresh_token'],
        tokenType: json['token_type'] ?? 'bearer',
        expiresIn: json['expires_in'] ?? 1800,
        user: json['user'] != null
            ? LoginUserInfo.fromJson(json['user'])
            : null,
      );
}

class LoginUserInfo {
  final String id;
  final String phone;
  final String name;
  final String? avatar;
  final String role;

  LoginUserInfo({
    required this.id,
    required this.phone,
    required this.name,
    this.avatar,
    required this.role,
  });

  factory LoginUserInfo.fromJson(Map<String, dynamic> json) => LoginUserInfo(
        id: json['id'],
        phone: json['phone'],
        name: json['name'],
        avatar: json['avatar'],
        role: json['role'],
      );
}
