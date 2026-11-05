import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:protegelink/features/history/domain/history_repository.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
import 'package:sqflite/sqflite.dart';

class LocalHistoryRepository implements HistoryRepository {
  static const _databaseName = 'protegelink.db';
  static const _databaseVersion = 1;
  static const _tableName = 'url_analyses';

  Future<Database>? _database;

  Future<Database> get _db => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final databasesDirectory = await getDatabasesPath();
    return openDatabase(
      path.join(databasesDirectory, _databaseName),
      version: _databaseVersion,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL,
            domain TEXT NOT NULL,
            status TEXT NOT NULL,
            risk_score INTEGER NOT NULL,
            reasons TEXT NOT NULL,
            analyzed_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> saveAnalysis(UrlAnalysis analysis) async {
    final database = await _db;
    await database.insert(_tableName, analysisToMap(analysis));
  }

  @override
  Future<List<UrlAnalysis>> getAnalyses() async {
    final database = await _db;
    final rows = await database.query(_tableName, orderBy: 'analyzed_at DESC');
    return rows.map(analysisFromMap).toList(growable: false);
  }

  @override
  Future<void> deleteAll() async {
    final database = await _db;
    await database.delete(_tableName);
  }

  static Map<String, Object?> analysisToMap(UrlAnalysis analysis) => {
        'url': analysis.url,
        'domain': analysis.domain,
        'status': analysis.status.name,
        'risk_score': analysis.riskScore,
        'reasons': jsonEncode(analysis.reasons),
        'analyzed_at': analysis.analyzedAt.toUtc().millisecondsSinceEpoch,
      };

  static UrlAnalysis analysisFromMap(Map<String, Object?> row) {
    final decodedReasons =
        jsonDecode(row['reasons']! as String) as List<dynamic>;
    return UrlAnalysis(
      url: row['url']! as String,
      domain: row['domain']! as String,
      status: AnalysisStatus.values.byName(row['status']! as String),
      riskScore: row['risk_score']! as int,
      reasons: decodedReasons.cast<String>(),
      analyzedAt: DateTime.fromMillisecondsSinceEpoch(
        row['analyzed_at']! as int,
        isUtc: true,
      ),
    );
  }
}
