import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MLKitFaceDetectorService {
  late final FaceDetector _detector;
  bool _isInitialized = false;

  MLKitFaceDetectorService() {
    _init();
  }

  void _init() {
    final options = FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: true,
      enableClassification: false,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.15,
    );
    _detector = FaceDetector(options: options);
    _isInitialized = true;
  }

  Future<List<Face>> detectFacesInFile(File imageFile) async {
    if (!_isInitialized) {
      _init();
    }
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _detector.processImage(inputImage);
      return faces;
    } catch (e) {
      // In case native ML Kit fails on some emulator or desktop runtime
      return [];
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _detector.close();
      _isInitialized = false;
    }
  }
}
