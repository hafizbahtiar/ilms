class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.accessToken,
    this.tokenType,
    this.expiresAt,
    this.roles = const [],
    this.permissions = const [],
  });

  final String id;
  final String name;
  final String email;
  final String? accessToken;
  final String? tokenType;
  final DateTime? expiresAt;
  final List<String> roles;
  final List<String> permissions;
}
