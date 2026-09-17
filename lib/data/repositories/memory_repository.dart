import 'package:sqflite/sqflite.dart';
import '../../models/memory.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

class MemoryRepository {
  final AppDatabase _dbProvider;

  MemoryRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<List<Memory>> getAllMemories() async {
    try {
      final db = await _dbProvider.database;
      final results = await db.query(
        DatabaseTables.memories,
        orderBy: 'is_highlight DESC, created_at DESC',
      );
      return results.map((e) => Memory.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Memory?> getHighlightMemory() async {
    try {
      final db = await _dbProvider.database;
      final results = await db.query(
        DatabaseTables.memories,
        where: 'is_highlight = 1',
        limit: 1,
      );
      if (results.isNotEmpty) {
        return Memory.fromMap(results.first);
      }
      final all = await getAllMemories();
      return all.isNotEmpty ? all.first : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> insertMemory(Memory memory) async {
    try {
      final db = await _dbProvider.database;
      await db.insert(
        DatabaseTables.memories,
        memory.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }
}
