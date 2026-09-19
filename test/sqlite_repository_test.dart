import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mvp_new/data/database/database_tables.dart';
import 'package:smriti_mvp_new/data/local/seed_data.dart';
import 'package:smriti_mvp_new/models/family_member.dart';
import 'package:smriti_mvp_new/models/sync_queue_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // In-memory test SQLite database
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    for (final query in DatabaseTables.createTableQueries) {
      await db.execute(query);
    }
  });

  tearDown(() async {
    await db.close();
  });

  group('SQLite Database & Seeding Tests', () {
    test('Creates all 12 tables successfully', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      final tableNames = tables.map((e) => e['name'] as String).toSet();

      expect(tableNames.contains(DatabaseTables.patients), isTrue);
      expect(tableNames.contains(DatabaseTables.familyMembers), isTrue);
      expect(tableNames.contains(DatabaseTables.memories), isTrue);
      expect(tableNames.contains(DatabaseTables.gameSessions), isTrue);
      expect(tableNames.contains(DatabaseTables.gameRounds), isTrue);
      expect(tableNames.contains(DatabaseTables.interactionEvents), isTrue);
      expect(tableNames.contains(DatabaseTables.difficultyEvents), isTrue);
      expect(tableNames.contains(DatabaseTables.reminders), isTrue);
      expect(tableNames.contains(DatabaseTables.reminderLogs), isTrue);
      expect(tableNames.contains(DatabaseTables.syncQueue), isTrue);
      expect(tableNames.contains(DatabaseTables.caregiverPairings), isTrue);
      expect(tableNames.contains(DatabaseTables.modelMetadata), isTrue);
    });

    test('SeedData populates initial Aai profile, family, and reminders', () async {
      await SeedData.seedIfEmpty(db);

      // Verify Patient Aai
      final patients = await db.query(DatabaseTables.patients);
      expect(patients.length, equals(1));
      expect(patients.first['name'], equals('Aai'));

      // Verify Family Members (Riya, Dejit, Mona)
      final family = await db.query(DatabaseTables.familyMembers);
      expect(family.length, equals(3));
      final names = family.map((e) => e['name']).toSet();
      expect(names, containsAll(['Riya', 'Dejit', 'Mona']));

      // Verify Reminders
      final reminders = await db.query(DatabaseTables.reminders);
      expect(reminders.length, equals(3));

      // Verify Idempotency - second seed should not duplicate
      await SeedData.seedIfEmpty(db);
      final patientsAfter = await db.query(DatabaseTables.patients);
      expect(patientsAfter.length, equals(1));
    });

    test('Inserts and retrieves family members correctly', () async {
      final newMember = FamilyMember(
        id: 'member_test_01',
        patientId: 'patient_aai_01',
        name: 'Bhupen',
        relationship: 'Son',
        photoPath: 'assets/images/family/dejit.png',
        faceEmbedding: [0.1, 0.2, 0.3],
        createdAt: DateTime.now(),
      );

      await db.insert(
        DatabaseTables.familyMembers,
        newMember.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final results = await db.query(
        DatabaseTables.familyMembers,
        where: 'id = ?',
        whereArgs: ['member_test_01'],
      );

      expect(results.length, equals(1));
      final retrieved = FamilyMember.fromMap(results.first);
      expect(retrieved.name, equals('Bhupen'));
      expect(retrieved.relationship, equals('Son'));
      expect(retrieved.faceEmbedding, equals([0.1, 0.2, 0.3]));
    });

    test('Sync queue handles pending operations and status updates', () async {
      final now = DateTime.now();
      final syncItem = SyncQueueItem(
        id: 'sync_01',
        tableName: 'game_sessions',
        recordId: 'session_01',
        operation: 'INSERT',
        payloadJson: '{"score": 100}',
        status: 'pending',
        retryCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      await db.insert(DatabaseTables.syncQueue, syncItem.toMap());

      final pending = await db.query(
        DatabaseTables.syncQueue,
        where: 'status = ?',
        whereArgs: ['pending'],
      );

      expect(pending.length, equals(1));
      final retrieved = SyncQueueItem.fromMap(pending.first);
      expect(retrieved.tableName, equals('game_sessions'));
      expect(retrieved.status, equals('pending'));

      // Update to synced
      await db.update(
        DatabaseTables.syncQueue,
        {'status': 'synced'},
        where: 'id = ?',
        whereArgs: ['sync_01'],
      );

      final synced = await db.query(
        DatabaseTables.syncQueue,
        where: 'status = ?',
        whereArgs: ['synced'],
      );
      expect(synced.length, equals(1));
    });
  });
}
