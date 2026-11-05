import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protegelink/core/errors/api_exception.dart';
import 'package:protegelink/features/history/domain/history_repository.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
import 'package:protegelink/features/url_check/domain/url_analysis_repository.dart';
import 'package:protegelink/features/url_check/presentation/url_check_controller.dart';

void main() {
  test('saves every successful analysis and notifies history', () async {
    final analysis = UrlAnalysis(
      url: 'https://example.com',
      domain: 'example.com',
      status: AnalysisStatus.safe,
      riskScore: 0,
      reasons: const [],
      analyzedAt: DateTime.utc(2026),
    );
    final history = _FakeHistoryRepository();
    var notifications = 0;
    final controller = UrlCheckController(
      _FakeUrlRepository(result: analysis),
      history,
      onSaved: () => notifications++,
    );

    final result = await controller.analyze('https://example.com');

    expect(result, same(analysis));
    expect(history.saved, [analysis]);
    expect(notifications, 1);
  });

  test('converts unexpected errors into a user-facing message', () async {
    final controller = UrlCheckController(
      _FakeUrlRepository(error: StateError('database details')),
      _FakeHistoryRepository(),
      onSaved: () {},
    );

    final result = await controller.analyze('https://example.com');

    expect(result, isNull);
    expect(controller.state, isA<AsyncError<UrlAnalysis?>>());
    final failure = (controller.state as AsyncError<UrlAnalysis?>).error;
    expect(failure, isA<ApiException>());
    expect(failure.toString(), isNot(contains('database details')));
  });
}

class _FakeUrlRepository implements UrlAnalysisRepository {
  _FakeUrlRepository({this.result, this.error});

  final UrlAnalysis? result;
  final Object? error;

  @override
  Future<UrlAnalysis> analyzeUrl(String url) async {
    if (error != null) throw error!;
    return result!;
  }
}

class _FakeHistoryRepository implements HistoryRepository {
  final saved = <UrlAnalysis>[];

  @override
  Future<void> deleteAll() async {}

  @override
  Future<List<UrlAnalysis>> getAnalyses() async => saved;

  @override
  Future<void> saveAnalysis(UrlAnalysis analysis) async {
    saved.add(analysis);
  }
}
