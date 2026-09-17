class ModelMetadata {
  final String id;
  final String modelName;
  final String version;
  final String compatibleFeatureVersion;
  final String status; // 'active', 'downloaded', 'available', 'rolled_back'
  final String? localFilePath;
  final DateTime createdAt;

  ModelMetadata({
    required this.id,
    required this.modelName,
    required this.version,
    required this.compatibleFeatureVersion,
    required this.status,
    this.localFilePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model_name': modelName,
      'version': version,
      'compatible_feature_version': compatibleFeatureVersion,
      'status': status,
      'local_file_path': localFilePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ModelMetadata.fromMap(Map<String, dynamic> map) {
    return ModelMetadata(
      id: map['id'] as String,
      modelName: map['model_name'] as String,
      version: map['version'] as String,
      compatibleFeatureVersion:
          map['compatible_feature_version'] as String? ?? '1.0.0',
      status: map['status'] as String? ?? 'active',
      localFilePath: map['local_file_path'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
