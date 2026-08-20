class LoginResponseModel {
  const LoginResponseModel({this.status, this.message, this.data});

  final String? status;
  final String? message;
  final LoginDataModel? data;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic> ? LoginDataModel.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
}

class LoginDataModel {
  const LoginDataModel({
    this.accessToken,
    this.tokenType,
    this.expiresAt,
    this.name,
    this.email,
    this.roles = const [],
    this.permissions = const [],
  });

  final String? accessToken;
  final String? tokenType;
  final DateTime? expiresAt;
  final String? name;
  final String? email;
  final List<String> roles;
  final List<String> permissions;

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      accessToken: json['access_token']?.toString(),
      tokenType: json['token_type']?.toString(),
      expiresAt: _parseExpiresAt(json['expires_at']),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      roles: _parseStringList(json['roles']),
      permissions: _parseStringList(json['permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_at': expiresAt?.toIso8601String(),
      'name': name,
      'email': email,
      'roles': roles,
      'permissions': permissions,
    };
  }

  Map<String, dynamic> toSessionJson() {
    return {'token_type': tokenType, 'name': name, 'email': email, 'roles': roles, 'permissions': permissions};
  }
}

DateTime? _parseExpiresAt(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

List<String> _parseStringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}
