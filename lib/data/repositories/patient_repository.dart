import 'package:sqflite/sqflite.dart';
import '../../models/patient.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

class PatientRepository {
  final AppDatabase _dbProvider;

  PatientRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<Patient?> getPatient() async {
    try {
      final db = await _dbProvider.database;
      final results = await db.query(DatabaseTables.patients, limit: 1);
      if (results.isNotEmpty) {
        return Patient.fromMap(results.first);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      final db = await _dbProvider.database;
      await db.update(
        DatabaseTables.patients,
        patient.toMap(),
        where: 'id = ?',
        whereArgs: [patient.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }
}
