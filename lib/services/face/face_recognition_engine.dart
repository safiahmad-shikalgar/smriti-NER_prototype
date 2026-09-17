import 'dart:io';

import '../../models/family_member.dart';

enum RecognitionStatus {
  matchFound,
  unknownPerson,
  noFaceDetected,
  permissionDenied,
  error,
}

class FaceRecognitionResult {
  final RecognitionStatus status;
  final FamilyMember? matchedFamilyMember;
  final String userMessage;
  final String? debugInfo;

  const FaceRecognitionResult({
    required this.status,
    this.matchedFamilyMember,
    required this.userMessage,
    this.debugInfo,
  });
}

abstract class FaceRecognitionEngine {
  Future<void> initialize();
  Future<FaceRecognitionResult> recognizeFaceFromImage({
    required File imageFile,
    required List<FamilyMember> enrolledFamilyMembers,
  });
  bool get isRealModelLoaded;
}
