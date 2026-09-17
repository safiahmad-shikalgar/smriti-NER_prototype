import '../../models/model_metadata.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_tables.dart';

class ModelUpdateService {
  final AppDatabase _dbProvider;

  ModelUpdateService({AppDatabase? dbProvider})
    : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<ModelMetadata?> getActiveModel() async {
    final db = await _dbProvider.database;
    final results = await db.query(
      DatabaseTables.modelMetadata,
      where: 'status = ?',
      whereArgs: ['active'],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return ModelMetadata.fromMap(results.first);
    }
    return null;
  }

  Future<bool> activateModel(String modelId) async {
    final db = await _dbProvider.database;
    // Set all to inactive
    await db.update(
      DatabaseTables.modelMetadata,
      {'status': 'downloaded'},
      where: 'status = ?',
      whereArgs: ['active'],
    );
    // Set target to active
    final rowsAffected = await db.update(
      DatabaseTables.modelMetadata,
      {'status': 'active'},
      where: 'id = ?',
      whereArgs: [modelId],
    );
    return rowsAffected > 0;
  }

  Future<bool> rollbackToPreviousModel() async {
    final db = await _dbProvider.database;
    final downloaded = await db.query(
      DatabaseTables.modelMetadata,
      where: 'status = ?',
      whereArgs: ['downloaded'],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (downloaded.isNotEmpty) {
      final prevId = downloaded.first['id'] as String;
      return await activateModel(prevId);
    }
    return false;
  }
}
