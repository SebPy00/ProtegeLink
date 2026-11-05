import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:protegelink/core/errors/api_exception.dart';
import 'package:protegelink/core/network/api_client.dart';

void main() {
  test('returns a friendly message for an HTTP error', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example',
      client: MockClient((request) async => http.Response('error', 503)),
    );

    await expectLater(
      client.get('/health'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          contains('No pudimos revisar'),
        ),
      ),
    );
  });

  test('returns a friendly message for invalid JSON', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example',
      client: MockClient((request) async => http.Response('not-json', 200)),
    );

    await expectLater(
      client.get('/health'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          contains('interpretar la respuesta'),
        ),
      ),
    );
  });

  test('does not expose a technical network exception', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example',
      client: MockClient(
          (request) async => throw http.ClientException('socket details')),
    );

    await expectLater(
      client.get('/health'),
      throwsA(
        isA<ApiException>()
            .having(
                (error) => error.message, 'message', isNot(contains('socket')))
            .having((error) => error.message, 'message',
                contains('Verificá tu conexión')),
      ),
    );
  });

  test('returns a friendly message when the request times out', () async {
    final client = ApiClient(
      baseUrl: 'https://api.example',
      timeout: const Duration(milliseconds: 1),
      client: MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      client.get('/health'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          contains('tardó demasiado'),
        ),
      ),
    );
  });

  test('loads the configured backend URL for every request', () async {
    var currentBaseUrl = 'http://192.168.100.18:8000';
    final requestedUrls = <Uri>[];
    final client = ApiClient(
      baseUrlLoader: () async => currentBaseUrl,
      client: MockClient((request) async {
        requestedUrls.add(request.url);
        return http.Response('{}', 200);
      }),
    );

    await client.get('/health');
    currentBaseUrl = 'http://192.168.43.25:8000';
    await client.get('/health');

    expect(
      requestedUrls,
      [
        Uri.parse('http://192.168.100.18:8000/health'),
        Uri.parse('http://192.168.43.25:8000/health'),
      ],
    );
  });
}
