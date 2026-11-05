import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protegelink/features/history/data/local_history_repository.dart';
import 'package:protegelink/features/history/domain/history_repository.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => LocalHistoryRepository(),
);

final historyAnalysesProvider = FutureProvider<List<UrlAnalysis>>(
  (ref) => ref.watch(historyRepositoryProvider).getAnalyses(),
);
