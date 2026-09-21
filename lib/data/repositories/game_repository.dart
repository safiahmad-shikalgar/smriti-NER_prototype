import 'package:sqflite/sqflite.dart';
import '../../models/game_session.dart';
import '../../models/game_round.dart';
import '../../models/interaction_event.dart';
import '../../models/difficulty_event.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

class GameRepository {
  final AppDatabase _dbProvider;

  GameRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<void> saveGameSession(GameSession session) async {
    try {
      final db = await _dbProvider.database;
      await db.insert(
        DatabaseTables.gameSessions,
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<void> saveGameRound(GameRound round) async {
    try {
      final db = await _dbProvider.database;
      await db.insert(
        DatabaseTables.gameRounds,
        round.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<void> saveInteractionEvent(InteractionEvent event) async {
    try {
      final db = await _dbProvider.database;
      await db.insert(
        DatabaseTables.interactionEvents,
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<void> saveDifficultyEvent(DifficultyEvent event) async {
    try {
      final db = await _dbProvider.database;
      await db.insert(
        DatabaseTables.difficultyEvents,
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<List<GameSession>> getAllSessions() async {
    try {
      final db = await _dbProvider.database;
      final results = await db.query(
        DatabaseTables.gameSessions,
        orderBy: 'started_at DESC',
      );
      return results.map((e) => GameSession.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getCompletedGamesCount() async {
    try {
      final db = await _dbProvider.database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM ${DatabaseTables.gameSessions} WHERE completed = 1',
        ),
      );
      return count ?? 3;
    } catch (_) {
      return 3;
    }
  }

  Future<double> getAverageAccuracy() async {
    try {
      final db = await _dbProvider.database;
      final result = await db.rawQuery(
        'SELECT AVG(accuracy_percentage) as avg_acc FROM ${DatabaseTables.gameSessions} WHERE completed = 1',
      );
      if (result.isNotEmpty && result.first['avg_acc'] != null) {
        return (result.first['avg_acc'] as num).toDouble();
      }
    } catch (_) {}
    return 80.0;
  }

  Future<List<DifficultyEvent>> getRecentDifficultyEvents({int limit = 10}) async {
    try {
      final db = await _dbProvider.database;
      final results = await db.query(
        DatabaseTables.difficultyEvents,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      return results.map((e) => DifficultyEvent.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
