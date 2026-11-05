import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protegelink/core/network/api_client.dart';
import 'package:protegelink/core/errors/api_exception.dart';
import 'package:protegelink/features/history/domain/history_repository.dart';
import 'package:protegelink/features/history/presentation/history_providers.dart';
import 'package:protegelink/features/url_check/data/remote_url_analysis_repository.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
import 'package:protegelink/features/url_check/domain/url_analysis_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final urlAnalysisRepositoryProvider = Provider<UrlAnalysisRepository>(
  (ref) => RemoteUrlAnalysisRepository(ref.watch(apiClientProvider)),
);

final urlCheckControllerProvider = StateNotifierProvider.autoDispose<
    UrlCheckController, AsyncValue<UrlAnalysis?>>((ref) {
  return UrlCheckController(
    ref.watch(urlAnalysisRepositoryProvider),
    ref.watch(historyRepositoryProvider),
    onSaved: () => ref.invalidate(historyAnalysesProvider),
  );
});

class UrlCheckController extends StateNotifier<AsyncValue<UrlAnalysis?>> {
  UrlCheckController(
    this._repository,
    this._historyRepository, {
    required void Function() onSaved,
  })  : _onSaved = onSaved,
        super(const AsyncData(null));

  final UrlAnalysisRepository _repository;
  final HistoryRepository _historyRepository;
  final void Function() _onSaved;

  Future<UrlAnalysis?> analyze(String url) async {
    state = const AsyncLoading();
    try {
      final analysis = await _repository.analyzeUrl(url);
      await _historyRepository.saveAnalysis(analysis);
      _onSaved();
      state = AsyncData(analysis);
      return analysis;
    } catch (error, stackTrace) {
      final safeError = error is ApiException
          ? error
          : const ApiException(
              'No pudimos revisar el enlace en este momento. Verificá tu conexión e intentá nuevamente.',
            );
      state = AsyncError(safeError, stackTrace);
      return null;
    }
  }
}
