import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../services/face/face_recognition_engine.dart';
import '../../../services/face/mobilefacenet_engine.dart';
import '../../../widgets/app_button.dart';
import '../widgets/face_result_dialog.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _cameraController;
  final FaceRecognitionEngine _engine = MobileFaceNetEngine();
  final FamilyRepository _familyRepository = FamilyRepository();
  final ImagePicker _picker = ImagePicker();

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _statusMessage = 'Point camera at your loved one';

  @override
  void initState() {
    super.initState();
    _initEngineAndCamera();
  }

  Future<void> _initEngineAndCamera() async {
    await _engine.initialize();
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Prefer front camera for selfie or first available camera
        final frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (_) {
      // Gracefully handle if camera hardware unavailable (emulator/desktop)
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _statusMessage = 'Select a photo to recognize family member';
        });
      }
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Recognizing face...';
    });

    try {
      File? imageFile;
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final xFile = await _cameraController!.takePicture();
        imageFile = File(xFile.path);
      } else {
        final picked = await _picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          imageFile = File(picked.path);
        }
      }

      if (imageFile == null) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'No image selected.';
        });
        return;
      }

      final enrolled = await _familyRepository.getAllFamilyMembers();
      final result = await _engine.recognizeFaceFromImage(
        imageFile: imageFile,
        enrolledFamilyMembers: enrolled,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Point camera at your loved one';
        });

        await showDialog(
          context: context,
          builder: (_) => FaceResultDialog(
            matchedMember: result.matchedFamilyMember,
            message: result.userMessage,
            isSuccess: result.status == RecognitionStatus.matchFound,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Could not process photo. Please try again.';
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final enrolled = await _familyRepository.getAllFamilyMembers();
        final result = await _engine.recognizeFaceFromImage(
          imageFile: File(picked.path),
          enrolledFamilyMembers: enrolled,
        );

        if (mounted) {
          setState(() => _isProcessing = false);
          await showDialog(
            context: context,
            builder: (_) => FaceResultDialog(
              matchedMember: result.matchedFamilyMember,
              message: result.userMessage,
              isSuccess: result.status == RecognitionStatus.matchFound,
            ),
          );
        }
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (_) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          'Who is this?',
          style: AppTypography.headingMedium(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.coral, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isCameraInitialized && _cameraController != null)
                        CameraPreview(_cameraController!)
                      else
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.face_retouching_natural,
                                size: 80,
                                color: AppColors.warmPaleCoral,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                _statusMessage,
                                style: AppTypography.bodyMedium(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      // Target face frame guide
                      Container(
                        width: 240,
                        height: 280,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.coral,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  AppButton(
                    label: _isProcessing ? 'Recognizing...' : 'Recognize Face',
                    icon: Icons.camera_alt,
                    onPressed: _isProcessing ? null : _captureAndRecognize,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Choose from Gallery',
                    icon: Icons.photo_library,
                    variant: ButtonVariant.secondary,
                    onPressed: _isProcessing ? null : _pickFromGallery,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
