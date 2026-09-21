import 'package:sqflite/sqflite.dart';
import '../../models/patient.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

class PatientRepository {
  final AppDatabase _dbProvider;

  PatientRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<Patient?> getPatient([String? authUserId]) async {
    try {
      final db = await _dbProvider.database;
      final results = authUserId != null
          ? await db.query(DatabaseTables.patients, where: 'id = ?', whereArgs: ['patient_$authUserId'], limit: 1)
          : await db.query(DatabaseTables.patients, limit: 1);
          
      if (results.isNotEmpty) {
        return Patient.fromMap(results.first);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      final db = await _dbProvider.database;
      await db.insert(
        DatabaseTables.patients,
        patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }
}
