import 'package:flutter/foundation.dart';

import '../../models/caregiver_pairing.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../sync/sync_service.dart';

class CaregiverService extends ChangeNotifier {
  final CaregiverRepository _repository;
  final SyncService _syncService;
  CaregiverPairing? _currentPairing;

  CaregiverService({CaregiverRepository? repository, SyncService? syncService})
    : _repository = repository ?? CaregiverRepository(),
      _syncService = syncService ?? SyncService();

  CaregiverPairing? get currentPairing => _currentPairing;
  SyncService get syncService => _syncService;

  Future<void> loadPairing() async {
    _currentPairing = await _repository.getPairing();
    if (_currentPairing == null) {
      await _generateNewPairing();
    } else {
      await _checkCloudStatus();
    }
    notifyListeners();
  }

  Future<void> _generateNewPairing() async {
    final code = 'SMRITI-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final pairing = CaregiverPairing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: 'local_user',
      pairingCode: code,
      status: 'waiting',
      createdAt: DateTime.now(),
    );
    await _repository.updatePairing(pairing);
    _currentPairing = pairing;
  }

  Future<void> _checkCloudStatus() async {
    if (_currentPairing == null) return;
    try {
      final client = _syncService.supabaseClient;
      if (client != null) {
        final response = await client
            .from('caregiver_pairings')
            .select()
            .eq('pairing_code', _currentPairing!.pairingCode)
            .maybeSingle();

        if (response != null) {
          final cloudPairing = CaregiverPairing.fromMap(response);
          if (cloudPairing.status == 'connected' && _currentPairing!.status == 'waiting') {
            _currentPairing = cloudPairing;
            await _repository.updatePairing(cloudPairing);
            notifyListeners();
          }
        }
      }
    } catch (_) {
      // Offline or error
    }
  }

  Future<void> disconnect() async {
    if (_currentPairing != null) {
      await _repository.deletePairing();
      _currentPairing = null;
      await _generateNewPairing();
      notifyListeners();
    }
  }

  Future<void> triggerManualSync() async {
    await _syncService.processSyncQueue();
    await _checkCloudStatus();
    if (_currentPairing != null) {
      final updated = CaregiverPairing(
        id: _currentPairing!.id,
        patientId: _currentPairing!.patientId,
        pairingCode: _currentPairing!.pairingCode,
        status: _currentPairing!.status,
        caregiverName: _currentPairing!.caregiverName,
        caregiverContact: _currentPairing!.caregiverContact,
        lastSyncedAt: DateTime.now(),
        createdAt: _currentPairing!.createdAt,
      );
      _currentPairing = updated;
      await _repository.updatePairing(updated);
      notifyListeners();
    }
  }
}
