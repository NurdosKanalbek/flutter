import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http_pkg;

import 'api_exception.dart';

export 'package:http/http.dart' show Client;

// ignore: camel_case_types
abstract final class http {
  // ignore: non_constant_identifier_names
  static http_pkg.Client Client() => http_pkg.Client();
}

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http_pkg.Client _client;
  final String host;

  Map<String, String> get headers => const {'Accept': 'application/json'};

  Future<http_pkg.Response> _send(
    Future<http_pkg.Response> Function() call,
  ) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        developer.log(
          '${response.request?.method ?? 'HTTP'} ${response.request?.url ?? ''} -> ${response.statusCode}',
          name: 'api',
        );
      }
      _check(response);
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  void _check(http_pkg.Response r) {
    if (r.statusCode == 401) {
      throw const UnauthorizedException();
    }
    if (r.statusCode == 404) {
      throw const NotFoundException();
    }
    if (r.statusCode >= 500) {
      throw ServerException(r.statusCode);
    }
  }

  dynamic _decode(http_pkg.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException(e.message);
    }
  }

  dynamic decode(http_pkg.Response r) => _decode(r);

  Future<http_pkg.Response> get(Uri uri) {
    return _send(() => _client.get(uri, headers: headers));
  }

  Future<http_pkg.Response> post(
    Uri uri, {
    required String body,
    Map<String, String>? additionalHeaders,
  }) {
    final mergedHeaders = {...headers, ...?additionalHeaders};
    return _send(() => _client.post(uri, headers: mergedHeaders, body: body));
  }
}
