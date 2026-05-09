abstract class ApiClient {
  Future<dynamic> get(String endpoint);
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body});
  Future<dynamic> patch(String endpoint, {required Map<String, dynamic> body});
  Future<void> delete(String endpoint);
}
