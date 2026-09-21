import 'package:sqflite/sqflite.dart';

import '../../models/reminder.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

class ReminderRepository {
  final AppDatabase _dbProvider;

  ReminderRepository({AppDatabase? dbProvider})
    : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<List<Reminder>> getAllReminders() async {
    final db = await _dbProvider.database;
    final results = await db.query(
      DatabaseTables.reminders,
      orderBy: 'created_at ASC',
    );
    return results.map((e) => Reminder.fromMap(e)).toList();
  }

  Future<Reminder?> getReminderByType(String type) async {
    final db = await _dbProvider.database;
    final results = await db.query(
      DatabaseTables.reminders,
      where: 'type = ?',
      whereArgs: [type],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return Reminder.fromMap(results.first);
    }
    return null;
  }

  Future<void> updateReminder(Reminder reminder) async {
    final db = await _dbProvider.database;
    await db.update(
      DatabaseTables.reminders,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> logReminderAction(String reminderId, String action) async {
    final db = await _dbProvider.database;
    await db.insert(DatabaseTables.reminderLogs, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'reminder_id': reminderId,
      'action_taken': action,
      'logged_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getReminderLogs(String reminderId) async {
    final db = await _dbProvider.database;
    return await db.query(
      DatabaseTables.reminderLogs,
      where: 'reminder_id = ?',
      whereArgs: [reminderId],
      orderBy: 'logged_at DESC',
    );
  }

  Future<void> deleteReminderLog(String logId) async {
    final db = await _dbProvider.database;
    await db.delete(
      DatabaseTables.reminderLogs,
      where: 'id = ?',
      whereArgs: [logId],
    );
  }
}
