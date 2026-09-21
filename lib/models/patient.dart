class Patient {
  final String id;
  final String name;
  final String fullName;
  final int age;
  final String preferredLanguage;
  final String? profilePhotoPath;
  final String caregiverInfo;
  final String medicalInfo;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.fullName,
    required this.age,
    required this.preferredLanguage,
    this.profilePhotoPath,
    required this.caregiverInfo,
    this.medicalInfo = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'age': age,
      'preferred_language': preferredLanguage,
      'profile_photo_path': profilePhotoPath,
      'caregiver_info': caregiverInfo,
      'medical_info': medicalInfo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      name: map['name'] as String,
      fullName: map['full_name'] as String? ?? map['name'] as String,
      age: map['age'] as int? ?? 74,
      preferredLanguage:
          map['preferred_language'] as String? ?? 'Assamese / English',
      profilePhotoPath: map['profile_photo_path'] as String?,
      caregiverInfo: map['caregiver_info'] as String? ?? '',
      medicalInfo: map['medical_info'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
