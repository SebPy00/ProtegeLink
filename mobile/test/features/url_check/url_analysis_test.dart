import 'package:flutter_test/flutter_test.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';

void main() {
  test('parses backend JSON into UrlAnalysis', () {
    final analysis = UrlAnalysis.fromJson({
      'url': 'https://example.com',
      'domain': 'example.com',
      'status': 'SAFE',
      'risk_score': 0,
      'reasons': <String>[],
      'analyzed_at': '2026-09-15T12:00:00.000Z',
    });

    expect(analysis.status, AnalysisStatus.safe);
    expect(analysis.domain, 'example.com');
    expect(analysis.analyzedAt.isUtc, isTrue);
  });
}
