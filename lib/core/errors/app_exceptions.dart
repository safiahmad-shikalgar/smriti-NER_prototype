class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code, super.details});
}

class SyncException extends AppException {
  SyncException(super.message, {super.code, super.details});
}

class FaceRecognitionException extends AppException {
  FaceRecognitionException(super.message, {super.code, super.details});
}
