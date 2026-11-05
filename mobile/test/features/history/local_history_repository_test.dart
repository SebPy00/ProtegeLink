import 'package:flutter_test/flutter_test.dart';
import 'package:protegelink/features/history/data/local_history_repository.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';

void main() {
  test('round-trips an analysis through the SQLite map format', () {
    final original = UrlAnalysis(
      url: 'https://example.com',
      domain: 'example.com',
      status: AnalysisStatus.suspicious,
      riskScore: 40,
      reasons: const ['insecure_http', 'ip_address_host'],
      analyzedAt: DateTime.utc(2026, 9, 26, 12, 30),
    );

    final restored = LocalHistoryRepository.analysisFromMap(
      LocalHistoryRepository.analysisToMap(original),
    );

    expect(restored.url, original.url);
    expect(restored.status, original.status);
    expect(restored.riskScore, original.riskScore);
    expect(restored.reasons, original.reasons);
    expect(restored.analyzedAt, original.analyzedAt);
  });
}
