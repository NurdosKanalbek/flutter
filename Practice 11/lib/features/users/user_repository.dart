import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final uri = Uri.https(_api.host, '/users');
    final http.Response response = await _api.get(uri);
    final dynamic data = _api.decode(response);
    try {
      if (data is! List) {
        throw const BadResponseException('users: expected JSON list');
      }
      return data
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw BadResponseException('users: $e');
    }
  }

  Future<User> getById(int id) async {
    final uri = Uri.https(_api.host, '/users/$id');
    final http.Response response = await _api.get(uri);
    final dynamic data = _api.decode(response);
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw BadResponseException('users/$id: $e');
    }
  }

  Future<User> create(User draft) async {
    final uri = Uri.https(_api.host, '/users');
    final http.Response response = await _api.post(
      uri,
      body: jsonEncode(draft.toJson()),
      additionalHeaders: const {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 201) {
      throw ServerException(response.statusCode);
    }
    final dynamic data = _api.decode(response);
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw BadResponseException('create user: $e');
    }
  }
}
