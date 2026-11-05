import 'package:flutter_test/flutter_test.dart';
import 'package:protegelink/features/url_check/presentation/analysis_reason_translator.dart';

void main() {
  test('translates every backend reason used by the analyzer', () {
    expect(translateAnalysisReason('insecure_http'),
        'El sitio no utiliza una conexión segura.');
    expect(translateAnalysisReason('ip_address_host'),
        contains('dirección numérica'));
    expect(translateAnalysisReason('suspicious_keywords'),
        contains('datos sensibles'));
    expect(translateAnalysisReason('too_many_subdomains'),
        contains('estructura poco habitual'));
    expect(translateAnalysisReason('very_long_url'),
        contains('inusualmente larga'));
    expect(translateAnalysisReason('safe_browsing_match'),
        contains('servicio de reputación'));
    expect(translateAnalysisReason('unicode_or_punycode'),
        contains('imitar otros sitios'));
    expect(translateAnalysisReason('brand_impersonation'),
        contains('empresa conocida'));
    expect(translateAnalysisReason('demo_mode_case'),
        contains('demostración controlado'));
  });

  test('does not expose unknown technical reason codes', () {
    expect(translateAnalysisReason('future_backend_code'),
        isNot(contains('future_backend_code')));
  });
}
