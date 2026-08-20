import 'package:ilms/features/auth/data/models/login_response_model.dart';

class ResolvedAuthSession {
  const ResolvedAuthSession({
    required this.model,
    required this.needsMigration,
    required this.needsSessionStrip,
    required this.migratedAccessToken,
    required this.migratedExpiresAt,
    required this.strippedSessionJson,
  });

  final LoginDataModel model;
  final bool needsMigration;
  final bool needsSessionStrip;
  final String? migratedAccessToken;
  final String? migratedExpiresAt;
  final Map<String, dynamic> strippedSessionJson;
}

class AuthSessionResolver {
  static const accessTokenKey = 'access_token';
  static const expiresAtKey = 'expires_at';

  static String? sessionTokenToRestore(LoginDataModel? data, DateTime now) {
    final accessToken = data?.accessToken;
    final expiresAt = data?.expiresAt;
    if (accessToken == null || accessToken.isEmpty) return null;
    if (expiresAt == null) return accessToken;
    if (!now.isBefore(expiresAt)) return null;
    return accessToken;
  }

  static ResolvedAuthSession resolve({
    required Map<String, dynamic> sessionJson,
    required String? secureAccessToken,
    required String? secureExpiresAt,
  }) {
    var accessToken = secureAccessToken;
    var expiresAt = secureExpiresAt;
    var needsMigration = false;

    if ((accessToken == null || accessToken.isEmpty) && sessionJson[accessTokenKey] != null) {
      accessToken = sessionJson[accessTokenKey]?.toString();
      expiresAt = sessionJson[expiresAtKey]?.toString();
      needsMigration = true;
    }

    final mergedJson = Map<String, dynamic>.from(sessionJson)
      ..[accessTokenKey] = accessToken
      ..[expiresAtKey] = expiresAt;

    final needsSessionStrip = sessionJson.containsKey(accessTokenKey) || sessionJson.containsKey(expiresAtKey);

    return ResolvedAuthSession(
      model: LoginDataModel.fromJson(mergedJson),
      needsMigration: needsMigration,
      needsSessionStrip: needsSessionStrip,
      migratedAccessToken: accessToken,
      migratedExpiresAt: expiresAt,
      strippedSessionJson: withoutTokenFields(sessionJson),
    );
  }

  static Map<String, dynamic> withoutTokenFields(Map<String, dynamic> json) {
    return Map<String, dynamic>.from(json)
      ..remove(accessTokenKey)
      ..remove(expiresAtKey);
  }
}
