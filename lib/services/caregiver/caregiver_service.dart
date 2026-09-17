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
    notifyListeners();
  }

  Future<void> triggerManualSync() async {
    await _syncService.processSyncQueue();
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
