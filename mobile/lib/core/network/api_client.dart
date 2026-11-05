import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:protegelink/core/constants/app_config.dart';
import 'package:protegelink/core/errors/api_exception.dart';
import 'package:protegelink/core/preferences/backend_preferences.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
    Duration? timeout,
    Future<String> Function()? baseUrlLoader,
  })  : _client = client ?? http.Client(),
        _timeout = timeout ?? AppConfig.requestTimeout,
        _fixedBaseUrl = baseUrl,
        _baseUrlLoader = baseUrlLoader ?? BackendPreferences().getApiBaseUrl;

  final http.Client _client;
  final Duration _timeout;
  final String? _fixedBaseUrl;
  final Future<String> Function() _baseUrlLoader;

  Future<Map<String, dynamic>> get(String path) async {
    return _send(() async => _client.get(await _uri(path)));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    return _send(
      () async => _client.post(
        await _uri(path),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
  }

  Future<Uri> _uri(String path) async {
    final configuredBaseUrl = _fixedBaseUrl ?? await _baseUrlLoader();
    final baseUrl = configuredBaseUrl.replaceFirst(RegExp(r'/$'), '');
    return Uri.parse('$baseUrl$path');
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'No pudimos revisar el enlace en este momento. Verificá tu conexión e intentá nuevamente.',
          statusCode: response.statusCode,
        );
      }
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is! Map<String, dynamic>) {
        throw const FormatException('La respuesta no es un objeto JSON.');
      }
      return decodedBody;
    } on TimeoutException {
      throw const ApiException(
        'La revisión tardó demasiado. Intentá nuevamente.',
      );
    } on FormatException {
      throw const ApiException(
        'No pudimos interpretar la respuesta del servicio. Intentá nuevamente.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No pudimos revisar el enlace en este momento. Verificá tu conexión e intentá nuevamente.',
      );
    }
  }
}
