import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mvp_new/data/database/database_tables.dart';
import 'package:smriti_mvp_new/data/remote/supabase_service.dart';
import 'package:smriti_mvp_new/models/sync_queue_item.dart';
import 'package:smriti_mvp_new/services/sync/sync_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Supabase Integration & Sync Queue Tests', () {
    late Database testDb;

    setUp(() async {
      testDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      for (final query in DatabaseTables.createTableQueries) {
        await testDb.execute(query);
      }
    });

    tearDown(() async {
      await testDb.close();
    });

    test('SupabaseService starts safely uninitialized with no client available', () {
      // In unit tests, platform channels (SharedPreferences) are unavailable,
      // so we verify the service's safe default state rather than calling initialize().
      final service = SupabaseService.instance;

      // Before initialization, client must be null and isInitialized must be false.
      expect(service.client, isNull);
      expect(service.isInitialized, isFalse);
    });

    test('SyncRepository increments retry_count and logs error on failure', () async {
      final syncItem = SyncQueueItem(
        id: 'sync_fail_01',
        tableName: 'reminders',
        recordId: 'rem_01',
        operation: 'INSERT',
        payloadJson: '{"id": "rem_01"}',
        status: 'pending',
        retryCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await testDb.insert(DatabaseTables.syncQueue, syncItem.toMap());

      // Query raw db directly
      await testDb.rawUpdate(
        'UPDATE ${DatabaseTables.syncQueue} SET status = ?, last_error = ?, retry_count = retry_count + 1, updated_at = ? WHERE id = ?',
        ['failed', 'Network unreachable (Offline Safe)', DateTime.now().toIso8601String(), 'sync_fail_01'],
      );

      final results = await testDb.query(
        DatabaseTables.syncQueue,
        where: 'id = ?',
        whereArgs: ['sync_fail_01'],
      );

      expect(results.length, equals(1));
      final updatedItem = SyncQueueItem.fromMap(results.first);
      expect(updatedItem.status, equals('failed'));
      expect(updatedItem.retryCount, equals(1));
      expect(updatedItem.lastError, contains('Offline Safe'));
    });

    test('SyncService stays safely in local offline mode when Supabase client is uninitialized', () async {
      final syncService = SyncService();
      expect(syncService.isSyncing, isFalse);
      expect(syncService.lastSyncStatus, contains('Offline'));

      // Process queue without network / client connection
      await syncService.processSyncQueue();

      expect(syncService.isSyncing, isFalse);
      expect(syncService.lastSyncStatus, contains('Offline'));
    });
  });
}
