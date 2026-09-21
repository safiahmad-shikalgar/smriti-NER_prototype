import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../models/memory.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import 'sync_repository.dart';
import '../../models/sync_queue_item.dart';

class MemoryRepository {
  final AppDatabase _dbProvider;

  MemoryRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<List<Memory>> getAllMemories([String? patientId]) async {
    try {
      final db = await _dbProvider.database;
      final whereStr = patientId != null ? 'patient_id = ?' : null;
      final whereArgs = patientId != null ? [patientId] : null;
      final results = await db.query(
        DatabaseTables.memories,
        where: whereStr,
        whereArgs: whereArgs,
        orderBy: 'is_highlight DESC, created_at DESC',
      );
      return results.map((e) => Memory.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Memory?> getHighlightMemory([String? patientId]) async {
    try {
      final db = await _dbProvider.database;
      final whereStr = patientId != null ? 'is_highlight = 1 AND patient_id = ?' : 'is_highlight = 1';
      final whereArgs = patientId != null ? [patientId] : [];
      final results = await db.query(
        DatabaseTables.memories,
        where: whereStr,
        whereArgs: whereArgs,
        limit: 1,
      );
      if (results.isNotEmpty) {
        return Memory.fromMap(results.first);
      }
      final all = await getAllMemories(patientId);
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
      
      // Enqueue sync
      final syncRepo = SyncRepository(dbProvider: _dbProvider);
      await syncRepo.enqueue(SyncQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tableName: 'memories',
        recordId: memory.id,
        operation: 'UPSERT',
        payloadJson: jsonEncode(memory.toMap()),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (_) {}
  }

  Future<void> deleteMemory(String id) async {
    try {
      final db = await _dbProvider.database;
      await db.delete(
        DatabaseTables.memories,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Enqueue sync (soft delete or hard delete payload)
      final syncRepo = SyncRepository(dbProvider: _dbProvider);
      await syncRepo.enqueue(SyncQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tableName: 'memories',
        recordId: id,
        operation: 'DELETE',
        payloadJson: jsonEncode({'id': id}),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (_) {}
  }
}
