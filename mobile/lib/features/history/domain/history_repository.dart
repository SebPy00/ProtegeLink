import 'package:protegelink/features/url_check/domain/url_analysis.dart';

abstract class HistoryRepository {
  Future<void> saveAnalysis(UrlAnalysis analysis);
  Future<List<UrlAnalysis>> getAnalyses();
  Future<void> deleteAll();
}
