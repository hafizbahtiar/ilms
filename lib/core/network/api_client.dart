abstract class ApiClient {
  Future<T> get<T>(String path, {Map<String, dynamic>? query});
  Future<T> post<T>(String path, {Object? data});
}
