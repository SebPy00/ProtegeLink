import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:protegelink/core/constants/app_config.dart';
import 'package:protegelink/core/errors/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceFirst(
        RegExp(r'/$'),
        '',
      );

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> get(String path) async {
    return _send(() => _client.get(_uri(path)));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    return _send(
      () => _client.post(
        _uri(path),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(AppConfig.requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'El servidor no pudo completar la solicitud.',
          statusCode: response.statusCode,
        );
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw const ApiException(
        'La revisión tardó demasiado. Intentá nuevamente.',
      );
    } on FormatException {
      throw const ApiException('El servidor devolvió una respuesta no válida.');
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con el servicio. Revisá la red y la dirección del backend.',
      );
    }
  }
}
