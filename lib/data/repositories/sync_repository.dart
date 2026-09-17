import 'package:sqflite/sqflite.dart';

import '../../models/sync_queue_item.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

class SyncRepository {
  final AppDatabase _dbProvider;

  SyncRepository({AppDatabase? dbProvider})
    : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<void> enqueue(SyncQueueItem item) async {
    final db = await _dbProvider.database;
    await db.insert(
      DatabaseTables.syncQueue,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SyncQueueItem>> getPendingItems() async {
    final db = await _dbProvider.database;
    final results = await db.query(
      DatabaseTables.syncQueue,
      where: 'status = ? OR status = ?',
      whereArgs: ['pending', 'failed'],
      orderBy: 'created_at ASC',
    );
    return results.map((e) => SyncQueueItem.fromMap(e)).toList();
  }

  Future<void> updateItemStatus(
    String id,
    String status, {
    String? error,
  }) async {
    final db = await _dbProvider.database;
    await db.update(
      DatabaseTables.syncQueue,
      {
        'status': status,
        'last_error': error,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getPendingCount() async {
    final db = await _dbProvider.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT COUNT(*) FROM ${DatabaseTables.syncQueue} WHERE status = 'pending'",
      ),
    );
    return count ?? 0;
  }
}
