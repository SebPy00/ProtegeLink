import 'package:protegelink/core/network/api_client.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
import 'package:protegelink/features/url_check/domain/url_analysis_repository.dart';

class RemoteUrlAnalysisRepository implements UrlAnalysisRepository {
  RemoteUrlAnalysisRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UrlAnalysis> analyzeUrl(String url) async {
    final json = await _apiClient.post(
      '/api/v1/urls/analyze',
      body: {'url': url},
    );
    return UrlAnalysis.fromJson(json);
  }
}
