import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
import 'package:protegelink/features/url_check/presentation/analysis_status_card.dart';

void main() {
  Widget subject(AnalysisStatus status) {
    return MaterialApp(
      home: Scaffold(
        body: AnalysisStatusCard(
          analysis: UrlAnalysis(
            url: 'https://example.com',
            domain: 'example.com',
            status: status,
            riskScore: 0,
            reasons: const [],
            analyzedAt: DateTime(2026),
          ),
        ),
      ),
    );
  }

  testWidgets('renders SAFE with text and icon', (tester) async {
    await tester.pumpWidget(subject(AnalysisStatus.safe));

    expect(find.text('SEGURO'), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);
  });

  testWidgets('renders DANGEROUS with text and icon', (tester) async {
    await tester.pumpWidget(subject(AnalysisStatus.dangerous));

    expect(find.text('PELIGROSO'), findsOneWidget);
    expect(find.byIcon(Icons.gpp_bad_outlined), findsOneWidget);
  });
}
