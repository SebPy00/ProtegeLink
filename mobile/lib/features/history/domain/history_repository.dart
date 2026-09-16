import 'package:protegelink/features/url_check/domain/url_analysis.dart';

abstract class HistoryRepository {
  Future<List<UrlAnalysis>> getAll();
  Future<void> save(UrlAnalysis analysis);
  Future<void> clear();
}
