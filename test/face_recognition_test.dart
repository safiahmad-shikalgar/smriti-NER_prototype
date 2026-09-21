import 'dart:io';
import 'dart:ui' show Rect;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smriti_mvp_new/models/family_member.dart';
import 'package:smriti_mvp_new/services/face/face_recognition_engine.dart';
import 'package:smriti_mvp_new/services/face/mlkit_face_detector.dart';
import 'package:smriti_mvp_new/services/face/mobilefacenet_engine.dart';

// Test implementation of MLKitFaceDetectorService that avoids native platform channels in unit tests
class MockMLKitFaceDetectorService extends MLKitFaceDetectorService {
  final List<Face> facesToReturn;

  MockMLKitFaceDetectorService({this.facesToReturn = const []});

  @override
  Future<List<Face>> detectFacesInFile(File imageFile) async {
    return facesToReturn;
  }
}

/// Creates a minimal [Face] object with the correct typed maps for use in tests.
Face _makeFace({Rect box = const Rect.fromLTWH(10, 10, 100, 100)}) {
  return Face(
    boundingBox: box,
    landmarks: <FaceLandmarkType, FaceLandmark?>{},
    contours: <FaceContourType, FaceContour?>{},
  );
}

void main() {
  group('Face Recognition Pipeline Tests', () {
    late FamilyMember sampleRiya;
    late FamilyMember sampleDejit;

    setUp(() {
      sampleRiya = FamilyMember(
        id: 'fam_riya_01',
        patientId: 'patient_aai_01',
        name: 'Riya',
        relationship: 'Granddaughter',
        photoPath: 'assets/images/family/riya.png',
        faceEmbedding: [0.5, 0.5, 0.5],
        createdAt: DateTime.now(),
      );

      sampleDejit = FamilyMember(
        id: 'fam_dejit_01',
        patientId: 'patient_aai_01',
        name: 'Dejit',
        relationship: 'Son',
        photoPath: 'assets/images/family/dejit.png',
        faceEmbedding: [0.1, 0.9, 0.2],
        createdAt: DateTime.now(),
      );
    });

    test('Stage 0: Returns invalidImage status if file does not exist', () async {
      final engine = MobileFaceNetEngine(
        detector: MockMLKitFaceDetectorService(facesToReturn: []),
      );

      final nonExistentFile = File('C:/non_existent_image_test_path.jpg');
      final result = await engine.recognizeFaceFromImage(
        imageFile: nonExistentFile,
        enrolledFamilyMembers: [sampleRiya],
      );

      expect(result.status, equals(RecognitionStatus.invalidImage));
      expect(result.userMessage, contains('could not be found'));
    });

    test('Stage 1: Returns noFaceDetected when detector finds 0 faces', () async {
      // Create a temporary dummy file so file exists check passes
      final tempDir = Directory.systemTemp.createTempSync('face_test_');
      final dummyFile = File('${tempDir.path}/test_img.jpg')..writeAsBytesSync([0]);

      final engine = MobileFaceNetEngine(
        detector: MockMLKitFaceDetectorService(facesToReturn: []),
      );

      final result = await engine.recognizeFaceFromImage(
        imageFile: dummyFile,
        enrolledFamilyMembers: [sampleRiya],
      );

      expect(result.status, equals(RecognitionStatus.noFaceDetected));
      expect(result.userMessage, contains("couldn't find a clear face"));

      tempDir.deleteSync(recursive: true);
    });

    test('Stage 2 & 3: Returns unknownPerson if enrolled family members list is empty', () async {
      final tempDir = Directory.systemTemp.createTempSync('face_test_2_');
      final dummyFile = File('${tempDir.path}/test_img2.jpg')..writeAsBytesSync([0]);

      // Mock returning 1 detected face
      final engine = MobileFaceNetEngine(
        detector: MockMLKitFaceDetectorService(
          facesToReturn: [_makeFace()],
        ),
      );

      final result = await engine.recognizeFaceFromImage(
        imageFile: dummyFile,
        enrolledFamilyMembers: [], // Empty list
      );

      expect(result.status, equals(RecognitionStatus.unknownPerson));
      expect(result.userMessage, contains("don't recognize this person yet"));

      tempDir.deleteSync(recursive: true);
    });

    test('Stage 3: Matches enrolled family member in DEBUG DEMO MODE with proper tag', () async {
      final tempDir = Directory.systemTemp.createTempSync('face_test_3_');
      final dummyFile = File('${tempDir.path}/test_img3.jpg')..writeAsBytesSync([0]);

      final engine = MobileFaceNetEngine(
        detector: MockMLKitFaceDetectorService(
          facesToReturn: [_makeFace()],
        ),
      );

      final result = await engine.recognizeFaceFromImage(
        imageFile: dummyFile,
        enrolledFamilyMembers: [sampleRiya, sampleDejit],
      );

      expect(result.status, equals(RecognitionStatus.matchFound));
      expect(result.matchedFamilyMember?.name, equals('Riya'));
      expect(result.userMessage, contains('Riya'));
      expect(result.debugInfo, contains('[DEBUG DEMO MODE]'));

      tempDir.deleteSync(recursive: true);
    });

    test('Cosine similarity mathematical helper computes accurately', () {
      final engine = MobileFaceNetEngine();

      // Orthogonal vectors
      expect(engine.cosineSimilarity([1.0, 0.0], [0.0, 1.0]), equals(0.0));

      // Identical vectors
      expect(engine.cosineSimilarity([1.0, 2.0, 3.0], [1.0, 2.0, 3.0]), closeTo(1.0, 0.0001));

      // Empty vectors
      expect(engine.cosineSimilarity([], []), equals(0.0));
    });
  });
}
