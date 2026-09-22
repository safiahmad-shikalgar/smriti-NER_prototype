import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../models/memory.dart';
import '../../../widgets/app_button.dart';

class AddMemoryScreen extends StatefulWidget {
  final Memory? memory;

  const AddMemoryScreen({super.key, this.memory});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final MemoryRepository _repository = MemoryRepository();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  File? _imageFile;
  String? _existingPhotoPath;
  bool _isSaving = false;

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    if (widget.memory != null) {
      _titleController.text = widget.memory!.title;
      _descController.text = widget.memory!.description;
      _dateController.text = widget.memory!.dateDescription;
      _existingPhotoPath = widget.memory!.photoPath;
    } else {
      _dateController.text = 'Today';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (_) {}
  }

  Future<void> _saveMemory() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title.')));
      return;
    }

    if (_imageFile == null && _existingPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a photo.')));
      return;
    }

    final patient = await PatientRepository().getPatient();
    final patientId = patient?.id;
    if (patientId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile not found.')));
      }
      return;
    }

    setState(() => _isSaving = true);

    String photoPath = AssetPaths.riyaBirthdayMemory;
    if (_imageFile != null) {
      photoPath = _imageFile!.path;
    } else if (_existingPhotoPath != null) {
      photoPath = _existingPhotoPath!;
    }

    final newMemory = Memory(
      id: widget.memory?.id ?? const Uuid().v4(),
      patientId: patientId,
      title: title,
      description: _descController.text.trim(),
      photoPath: photoPath,
      dateDescription: _dateController.text.trim(),
      isHighlight: widget.memory?.isHighlight ?? false,
      createdAt: widget.memory?.createdAt ?? DateTime.now(),
    );

    await _repository.insertMemory(newMemory);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteMemory() async {
    if (widget.memory == null) return;
    
    setState(() => _isDeleting = true);
    await _repository.deleteMemory(widget.memory!.id);
    
    if (mounted) {
      setState(() => _isDeleting = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.memory != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Memory' : 'Add Memory', style: AppTypography.headingMedium()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt, color: AppColors.coral),
                            title: const Text('Take Photo'),
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library, color: AppColors.coral),
                            title: const Text('Choose from Gallery'),
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.warmPaleCoral,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.coral, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : _existingPhotoPath != null && _existingPhotoPath!.startsWith('assets/')
                          ? Image.asset(_existingPhotoPath!, fit: BoxFit.cover)
                          : _existingPhotoPath != null
                              ? Image.file(File(_existingPhotoPath!), fit: BoxFit.cover)
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: AppColors.coral, size: 48),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        color: AppColors.coral,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Memory Title', style: AppTypography.bodyLarge(weight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _titleController,
                style: AppTypography.bodyLarge(),
                decoration: InputDecoration(
                  hintText: 'e.g. Wedding Anniversary',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.borderSoft),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Description / Comment', style: AppTypography.bodyLarge(weight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _descController,
                style: AppTypography.bodyLarge(),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a comment about this photo...',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.borderSoft),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('When / Where', style: AppTypography.bodyLarge(weight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _dateController,
                style: AppTypography.bodyLarge(),
                decoration: InputDecoration(
                  hintText: 'e.g. Last Winter, Guwahati',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.borderSoft),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: _isSaving ? 'Saving...' : (isEditing ? 'Update Memory' : 'Save Memory'),
                icon: Icons.check,
                onPressed: _isSaving ? null : _saveMemory,
              ),
              if (isEditing) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: _isDeleting ? 'Deleting...' : 'Delete Memory',
                  icon: Icons.delete,
                  variant: ButtonVariant.secondary,
                  onPressed: _isDeleting ? null : _deleteMemory,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
