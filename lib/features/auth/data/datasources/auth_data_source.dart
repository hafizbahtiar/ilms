abstract class AuthDataSource {
  Future<Map<String, String>> login({required String email, required String password});
}
