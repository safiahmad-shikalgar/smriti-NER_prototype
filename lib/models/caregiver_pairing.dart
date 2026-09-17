class CaregiverPairing {
  final String id;
  final String patientId;
  final String pairingCode; // 'SMRITI-4821'
  final String status; // 'waiting', 'connected', 'synced'
  final String? caregiverName;
  final String? caregiverContact;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;

  CaregiverPairing({
    required this.id,
    required this.patientId,
    required this.pairingCode,
    required this.status,
    this.caregiverName,
    this.caregiverContact,
    this.lastSyncedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'pairing_code': pairingCode,
      'status': status,
      'caregiver_name': caregiverName,
      'caregiver_contact': caregiverContact,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CaregiverPairing.fromMap(Map<String, dynamic> map) {
    return CaregiverPairing(
      id: map['id'] as String,
      patientId: map['patient_id'] as String? ?? 'default_patient',
      pairingCode: map['pairing_code'] as String? ?? 'SMRITI-4821',
      status: map['status'] as String? ?? 'waiting',
      caregiverName: map['caregiver_name'] as String?,
      caregiverContact: map['caregiver_contact'] as String?,
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.tryParse(map['last_synced_at'] as String)
          : null,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
