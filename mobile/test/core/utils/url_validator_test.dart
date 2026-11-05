import 'package:flutter_test/flutter_test.dart';
import 'package:protegelink/core/utils/url_validator.dart';

void main() {
  test('accepts complete HTTP and HTTPS URLs', () {
    expect(validateHttpUrl('https://example.com/path'), isNull);
    expect(validateHttpUrl('http://example.com'), isNull);
    expect(validateHttpUrl('  https://example.com  '), isNull);
  });

  test('rejects unsupported or incomplete URLs', () {
    expect(validateHttpUrl('ftp://example.com'), isNotNull);
    expect(validateHttpUrl('texto arbitrario'), isNotNull);
    expect(validateHttpUrl('solamente-una-palabra'), isNotNull);
    expect(validateHttpUrl(''), isNotNull);
  });

  test('normalizes accidental surrounding spaces', () {
    expect(normalizeUrlInput('  https://example.com/path  '),
        'https://example.com/path');
    expect(normalizeUrlInput('google.com'), 'https://google.com');
    expect(validateHttpUrl('google.com'), isNull);
  });

  test('extracts the first HTTP URL from shared text', () {
    expect(
      extractFirstHttpUrl('Mirá este enlace: https://example.com/path.'),
      'https://example.com/path',
    );
    expect(extractFirstHttpUrl('Texto sin enlaces'), isNull);
  });
}
