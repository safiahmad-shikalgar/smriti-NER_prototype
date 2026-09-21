import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../models/family_member.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import 'sync_repository.dart';
import '../../models/sync_queue_item.dart';

class FamilyRepository {
  final AppDatabase _dbProvider;

  FamilyRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<List<FamilyMember>> getAllFamilyMembers([String? patientId]) async {
    try {
      final db = await _dbProvider.database;
      final whereStr = patientId != null ? 'patient_id = ?' : null;
      final whereArgs = patientId != null ? [patientId] : null;
      final results = await db.query(
        DatabaseTables.familyMembers,
        where: whereStr,
        whereArgs: whereArgs,
        orderBy: 'created_at ASC',
      );
      return results.map((e) => FamilyMember.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<FamilyMember?> getFamilyMemberById(String id, [String? patientId]) async {
    try {
      final db = await _dbProvider.database;
      final whereStr = patientId != null ? 'id = ? AND patient_id = ?' : 'id = ?';
      final whereArgs = patientId != null ? [id, patientId] : [id];
      final results = await db.query(
        DatabaseTables.familyMembers,
        where: whereStr,
        whereArgs: whereArgs,
        limit: 1,
      );
      if (results.isNotEmpty) {
        return FamilyMember.fromMap(results.first);
      }
    } catch (_) {}
    return null;
  }

  Future<void> insertFamilyMember(FamilyMember member) async {
    try {
      final db = await _dbProvider.database;
      await db.insert(
        DatabaseTables.familyMembers,
        member.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Enqueue sync
      final syncRepo = SyncRepository(dbProvider: _dbProvider);
      await syncRepo.enqueue(SyncQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tableName: 'family_members',
        recordId: member.id,
        operation: 'UPSERT',
        payloadJson: jsonEncode(member.toMap()),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (_) {}
  }

  Future<void> deleteFamilyMember(String id) async {
    try {
      final db = await _dbProvider.database;
      await db.delete(
        DatabaseTables.familyMembers,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Enqueue sync (soft delete or hard delete payload)
      final syncRepo = SyncRepository(dbProvider: _dbProvider);
      await syncRepo.enqueue(SyncQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tableName: 'family_members',
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
