import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/app_constants.dart';
import '../database/database_tables.dart';

class SeedData {
  static Future<void> seedIfEmpty(Database db) async {
    final patientsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseTables.patients}'),
    );

    if (patientsCount != null && patientsCount > 0) {
      return; // Already seeded
    }

    final now = DateTime.now().toIso8601String();
    const uuid = Uuid();
    final patientId = 'patient_aai_01';

    // 1. Seed Patient
    await db.insert(DatabaseTables.patients, {
      'id': patientId,
      'name': AppConstants.defaultPatientName,
      'full_name': AppConstants.defaultPatientFullName,
      'age': AppConstants.defaultPatientAge,
      'preferred_language': AppConstants.defaultLanguage,
      'profile_photo_path': AssetPaths.aaiAvatar,
      'caregiver_info': 'Dr. Bhupen / Aparna (Daughter-in-law)',
      'medical_info': 'Blood Pressure (mild), High Cholesterol',
      'created_at': now,
    });

    // 2. Seed Family Members
    final riyaId = uuid.v4();
    await db.insert(DatabaseTables.familyMembers, {
      'id': riyaId,
      'patient_id': patientId,
      'name': 'Riya',
      'relationship': 'Granddaughter',
      'photo_path': AssetPaths.riyaAvatar,
      'voice_note_path': null,
      'face_embedding': '0.12,0.45,-0.33,0.88,0.02,-0.15,0.72',
      'created_at': now,
    });

    final dejitId = uuid.v4();
    await db.insert(DatabaseTables.familyMembers, {
      'id': dejitId,
      'patient_id': patientId,
      'name': 'Dejit',
      'relationship': 'Son',
      'photo_path': AssetPaths.dejitAvatar,
      'voice_note_path': null,
      'face_embedding': '0.34,-0.12,0.67,0.11,-0.45,0.29,0.51',
      'created_at': now,
    });

    final monaId = uuid.v4();
    await db.insert(DatabaseTables.familyMembers, {
      'id': monaId,
      'patient_id': patientId,
      'name': 'Mona',
      'relationship': 'Daughter',
      'photo_path': AssetPaths.monaAvatar,
      'voice_note_path': null,
      'face_embedding': '-0.21,0.55,0.18,0.74,0.31,-0.19,0.42',
      'created_at': now,
    });

    // 3. Seed Memories
    await db.insert(DatabaseTables.memories, {
      'id': uuid.v4(),
      'patient_id': patientId,
      'title': "Riya's 20th Birthday",
      'description': 'Celebrated in Guwahati with whole family',
      'photo_path': AssetPaths.riyaBirthdayMemory,
      'audio_path': null,
      'date_description': 'Last Winter, Guwahati',
      'is_highlight': 1,
      'created_at': now,
    });

    await db.insert(DatabaseTables.memories, {
      'id': uuid.v4(),
      'patient_id': patientId,
      'title': 'Rongali Bihu Festival',
      'description': 'Dancing and making pitha with granddaughter Riya',
      'photo_path': AssetPaths.bihuCelebrationMemory,
      'audio_path': null,
      'date_description': 'April Bohag Bihu',
      'is_highlight': 0,
      'created_at': now,
    });

    await db.insert(DatabaseTables.memories, {
      'id': uuid.v4(),
      'patient_id': patientId,
      'title': 'Trip to Kaziranga National Park',
      'description': 'Seeing the rhino with son Dejit and grandchildren',
      'photo_path': AssetPaths.kazirangaTripMemory,
      'audio_path': null,
      'date_description': 'November 2024',
      'is_highlight': 0,
      'created_at': now,
    });

    // 4. Seed Reminders (Medicine, Water, Activity)
    await db.insert(DatabaseTables.reminders, {
      'id': 'rem_med_01',
      'patient_id': patientId,
      'title': 'Blue tablet',
      'subtitle': '(Aparna) Blood Pressure Medicine',
      'scheduled_time': '10:00 AM',
      'type': 'medicine',
      'target_count': 1,
      'completed_count': 0,
      'is_completed': 0,
      'last_completed_at': null,
      'created_at': now,
    });

    await db.insert(DatabaseTables.reminders, {
      'id': 'rem_water_01',
      'patient_id': patientId,
      'title': 'Drink Warm Water',
      'subtitle': 'Stay hydrated throughout the day',
      'scheduled_time': 'All Day',
      'type': 'water',
      'target_count': 6,
      'completed_count': 3,
      'is_completed': 0,
      'last_completed_at': now,
      'created_at': now,
    });

    await db.insert(DatabaseTables.reminders, {
      'id': 'rem_act_01',
      'patient_id': patientId,
      'title': 'Play Haat Bazaar',
      'subtitle': 'Memory practice with familiar market goods',
      'scheduled_time': '11:30 AM',
      'type': 'cognitive',
      'target_count': 1,
      'completed_count': 1,
      'is_completed': 1,
      'last_completed_at': now,
      'created_at': now,
    });

    // 5. Seed Demo Past Game Session for 80% accuracy / 3 games
    final demoSessionId = uuid.v4();
    await db.insert(DatabaseTables.gameSessions, {
      'id': demoSessionId,
      'patient_id': patientId,
      'game_type': 'haat_bazaar_recall',
      'total_rounds': 3,
      'completed_rounds': 3,
      'correct_rounds': 2,
      'accuracy_percentage': 80.0,
      'total_duration_ms': 45000,
      'starting_difficulty': 'normal',
      'final_difficulty': 'normal',
      'completed': 1,
      'started_at': now,
      'completed_at': now,
    });

    // 6. Seed Caregiver Pairing
    await db.insert(DatabaseTables.caregiverPairings, {
      'id': uuid.v4(),
      'patient_id': patientId,
      'pairing_code': AppConstants.caregiverPairingCode,
      'status': 'connected',
      'caregiver_name': 'Aparna Baruah',
      'caregiver_contact': '+91 98640 12345',
      'last_synced_at': now,
      'created_at': now,
    });

    // 7. Seed Model Metadata
    await db.insert(DatabaseTables.modelMetadata, {
      'id': uuid.v4(),
      'model_name': 'mobilefacenet',
      'version': '1.0.0',
      'compatible_feature_version': '1.0.0',
      'status': 'active',
      'local_file_path': AssetPaths.mobileFaceNetModel,
      'created_at': now,
    });
  }
}
