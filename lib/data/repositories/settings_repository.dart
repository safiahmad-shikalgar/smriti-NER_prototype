import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

class SettingsRepository {
  final AppDatabase _dbProvider;

  SettingsRepository({AppDatabase? dbProvider})
    : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<void> setSetting(String key, String value) async {
    final db = await _dbProvider.database;
    await db.insert(
      DatabaseTables.appSettings,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await _dbProvider.database;
    final results = await db.query(
      DatabaseTables.appSettings,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first['value'] as String?;
    }
    return null;
  }
}
