class FamilyMember {
  final String id;
  final String patientId;
  final String name;
  final String relationship; // Son, Daughter, Grandson, Granddaughter, Brother, Sister, Friend
  final String photoPath;
  final String? voiceNotePath;
  final List<double>? faceEmbedding;
  final DateTime createdAt;

  FamilyMember({
    required this.id,
    required this.patientId,
    required this.name,
    required this.relationship,
    required this.photoPath,
    this.voiceNotePath,
    this.faceEmbedding,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'name': name,
      'relationship': relationship,
      'photo_path': photoPath,
      'voice_note_path': voiceNotePath,
      'face_embedding': faceEmbedding?.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    List<double>? embedding;
    if (map['face_embedding'] != null &&
        (map['face_embedding'] as String).isNotEmpty) {
      embedding = (map['face_embedding'] as String)
          .split(',')
          .map((e) => double.tryParse(e) ?? 0.0)
          .toList();
    }
    return FamilyMember(
      id: map['id'] as String,
      patientId: map['patient_id'] as String? ?? 'default_patient',
      name: map['name'] as String,
      relationship: map['relationship'] as String,
      photoPath: map['photo_path'] as String,
      voiceNotePath: map['voice_note_path'] as String?,
      faceEmbedding: embedding,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
