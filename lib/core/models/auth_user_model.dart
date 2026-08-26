/// Authenticated user profile returned by the backend.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  final int id;
  final String email;
  final String fullName;
  final String role;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'role': role,
      };
}

/// A full authentication session (JWT pair + user profile).
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access'] as String? ?? '',
      refreshToken: json['refresh'] as String? ?? '',
      user: json['user'] != null
          ? AuthUser.fromJson(Map<String, dynamic>.from(json['user']))
          : const AuthUser(id: 0, email: '', fullName: '', role: ''),
    );
  }

  final String accessToken;
  final String refreshToken;
  final AuthUser user;
}
