class Memory {
  final String id;
  final String patientId;
  final String title;
  final String description;
  final String photoPath;
  final String? audioPath;
  final String dateDescription;
  final bool isHighlight;
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.patientId,
    required this.title,
    required this.description,
    required this.photoPath,
    this.audioPath,
    required this.dateDescription,
    this.isHighlight = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'title': title,
      'description': description,
      'photo_path': photoPath,
      'audio_path': audioPath,
      'date_description': dateDescription,
      'is_highlight': isHighlight ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'] as String,
      patientId: map['patient_id'] as String? ?? 'default_patient',
      title: map['title'] as String,
      description: map['description'] as String,
      photoPath: map['photo_path'] as String,
      audioPath: map['audio_path'] as String?,
      dateDescription: map['date_description'] as String? ?? '',
      isHighlight: (map['is_highlight'] as int? ?? 0) == 1,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
