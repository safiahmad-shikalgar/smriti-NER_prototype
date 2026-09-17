import 'package:sqflite/sqflite.dart';
import '../../models/family_member.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

class FamilyRepository {
  final AppDatabase _dbProvider;

  FamilyRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<List<FamilyMember>> getAllFamilyMembers() async {
    try {
      final db = await _dbProvider.database;
      final results = await db.query(
        DatabaseTables.familyMembers,
        orderBy: 'created_at ASC',
      );
      return results.map((e) => FamilyMember.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<FamilyMember?> getFamilyMemberById(String id) async {
    try {
      final db = await _dbProvider.database;
      final results = await db.query(
        DatabaseTables.familyMembers,
        where: 'id = ?',
        whereArgs: [id],
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
    } catch (_) {}
  }
}
