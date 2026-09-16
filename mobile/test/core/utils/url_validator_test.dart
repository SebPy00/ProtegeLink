import 'package:flutter_test/flutter_test.dart';
import 'package:protegelink/core/utils/url_validator.dart';

void main() {
  test('accepts complete HTTP and HTTPS URLs', () {
    expect(validateHttpUrl('https://example.com/path'), isNull);
    expect(validateHttpUrl('http://example.com'), isNull);
  });

  test('rejects unsupported or incomplete URLs', () {
    expect(validateHttpUrl('example.com'), isNotNull);
    expect(validateHttpUrl('ftp://example.com'), isNotNull);
    expect(validateHttpUrl(''), isNotNull);
  });
}
