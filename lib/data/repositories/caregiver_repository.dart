import 'package:sqflite/sqflite.dart';

import '../../models/caregiver_pairing.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

class CaregiverRepository {
  final AppDatabase _dbProvider;

  CaregiverRepository({AppDatabase? dbProvider})
    : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<CaregiverPairing?> getPairing() async {
    final db = await _dbProvider.database;
    final results = await db.query(DatabaseTables.caregiverPairings, limit: 1);
    if (results.isNotEmpty) {
      return CaregiverPairing.fromMap(results.first);
    }
    return null;
  }

  Future<void> updatePairing(CaregiverPairing pairing) async {
    final db = await _dbProvider.database;
    await db.insert(
      DatabaseTables.caregiverPairings,
      pairing.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deletePairing() async {
    final db = await _dbProvider.database;
    await db.delete(DatabaseTables.caregiverPairings);
  }
}
