import 'package:protegelink/features/url_check/domain/url_analysis.dart';

abstract class UrlAnalysisRepository {
  Future<UrlAnalysis> analyzeUrl(String url);
}
