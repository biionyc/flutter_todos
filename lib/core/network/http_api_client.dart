import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import 'api_client.dart';

class HttpApiClient implements ApiClient {
  final http.Client _client;

  HttpApiClient({http.Client? client}) : _client = client ?? http.Client();

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw ServerException(
      message: response.reasonPhrase ?? 'Unknown error',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<dynamic> get(String endpoint) async {
    final http.Response response;
    try {
      response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 0);
    }
    return _handleResponse(response);
  }

  @override
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final http.Response response;
    try {
      response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 0);
    }
    return _handleResponse(response);
  }

  @override
  Future<dynamic> patch(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final http.Response response;
    try {
      response = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 0);
    }
    return _handleResponse(response);
  }

  @override
  Future<void> delete(String endpoint) async {
    final http.Response response;
    try {
      response = await _client.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 0);
    }
    _handleResponse(response);
  }
}
