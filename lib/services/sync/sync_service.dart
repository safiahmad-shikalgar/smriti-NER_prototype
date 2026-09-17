import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../data/repositories/sync_repository.dart';
import '../../data/remote/supabase_service.dart';

class SyncService extends ChangeNotifier {
  final SyncRepository _syncRepository;
  final SupabaseService _supabaseService;
  bool _isSyncing = false;
  String _lastSyncStatus = 'Offline (Local Safe)';
  DateTime? _lastSyncTime;

  SyncService({
    SyncRepository? syncRepository,
    SupabaseService? supabaseService,
  }) : _syncRepository = syncRepository ?? SyncRepository(),
       _supabaseService = supabaseService ?? SupabaseService.instance;

  bool get isSyncing => _isSyncing;
  String get lastSyncStatus => _lastSyncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> processSyncQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    try {
      final pendingItems = await _syncRepository.getPendingItems();
      final client = _supabaseService.client;

      if (client == null) {
        _lastSyncStatus = 'Offline (Data Saved Locally)';
        _isSyncing = false;
        notifyListeners();
        return;
      }

      for (final item in pendingItems) {
        await _syncRepository.updateItemStatus(item.id, 'syncing');
        try {
          final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
          await client.from(item.tableName).upsert(payload);
          await _syncRepository.updateItemStatus(item.id, 'synced');
        } catch (e) {
          await _syncRepository.updateItemStatus(
            item.id,
            'failed',
            error: e.toString(),
          );
        }
      }

      _lastSyncStatus = 'Synced with Cloud';
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _lastSyncStatus = 'Sync Pending (Safe in SQLite)';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
