import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protegelink/core/network/api_client.dart';
import 'package:protegelink/features/url_check/data/remote_url_analysis_repository.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
import 'package:protegelink/features/url_check/domain/url_analysis_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final urlAnalysisRepositoryProvider = Provider<UrlAnalysisRepository>(
  (ref) => RemoteUrlAnalysisRepository(ref.watch(apiClientProvider)),
);

final urlCheckControllerProvider =
    StateNotifierProvider<UrlCheckController, AsyncValue<UrlAnalysis?>>((ref) {
      return UrlCheckController(ref.watch(urlAnalysisRepositoryProvider));
    });

class UrlCheckController extends StateNotifier<AsyncValue<UrlAnalysis?>> {
  UrlCheckController(this._repository) : super(const AsyncData(null));

  final UrlAnalysisRepository _repository;

  Future<UrlAnalysis?> analyze(String url) async {
    state = const AsyncLoading();
    try {
      final analysis = await _repository.analyzeUrl(url);
      state = AsyncData(analysis);
      return analysis;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}
