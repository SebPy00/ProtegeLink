import 'package:protegelink/features/history/domain/history_repository.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';

/// Frontera local preparada para sustituirse por una implementación con sqflite.
/// La persistencia se deja para la siguiente iteración académica.
class LocalHistoryRepository implements HistoryRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<List<UrlAnalysis>> getAll() async => const [];

  @override
  Future<void> save(UrlAnalysis analysis) async {}
}
