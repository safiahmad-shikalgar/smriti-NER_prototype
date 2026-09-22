import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../models/family_member.dart';
import '../../../widgets/app_button.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  final FamilyMember? member;

  const AddFamilyMemberScreen({super.key, this.member});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final FamilyRepository _repository = FamilyRepository();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();

  static const List<String> relationships = [
    'Son',
    'Daughter',
    'Grandson',
    'Granddaughter',
    'Brother',
    'Sister',
    'Friend',
    'Other',
  ];

  String _selectedRelationship = 'Other';
  File? _imageFile;
  String? _existingPhotoPath;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _storyController.text = widget.member!.story ?? '';
      if (relationships.contains(widget.member!.relationship)) {
        _selectedRelationship = widget.member!.relationship;
      } else {
        _selectedRelationship = 'Other';
      }
      _existingPhotoPath = widget.member!.photoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storyController.dispose();
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

  Future<void> _saveMember() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name.')));
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

    String photoPath = AssetPaths.aaiAvatar;
    if (_imageFile != null) {
      photoPath = _imageFile!.path;
    } else if (_existingPhotoPath != null) {
      photoPath = _existingPhotoPath!;
    }

    final newMember = FamilyMember(
      id: widget.member?.id ?? const Uuid().v4(),
      patientId: patientId,
      name: name,
      relationship: _selectedRelationship,
      photoPath: photoPath,
      story: _storyController.text.trim().isNotEmpty ? _storyController.text.trim() : null,
      faceEmbedding: widget.member?.faceEmbedding ?? [0.1, 0.2, 0.3],
      createdAt: widget.member?.createdAt ?? DateTime.now(),
    );

    await _repository.insertFamilyMember(newMember);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteMember() async {
    if (widget.member == null) return;
    
    setState(() => _isDeleting = true);
    await _repository.deleteFamilyMember(widget.member!.id);
    
    if (mounted) {
      setState(() => _isDeleting = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.member != null;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Family Member' : 'Add Family Member', style: AppTypography.headingMedium()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder:
                          (ctx) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.coral,
                                  ),
                                  title: const Text('Take Photo'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.photo_library,
                                    color: AppColors.coral,
                                  ),
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
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.warmPaleCoral,
                      shape: BoxShape.circle,
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
                                      Icon(
                                        Icons.add_a_photo,
                                        color: AppColors.coral,
                                        size: 36,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          color: AppColors.coral,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Full Name',
                style: AppTypography.bodyLarge(weight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _nameController,
                style: AppTypography.bodyLarge(),
                decoration: InputDecoration(
                  hintText: 'e.g. Riya, Dejit',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.borderSoft),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: AppColors.coral,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Relationship to You',
                style: AppTypography.bodyLarge(weight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                initialValue: _selectedRelationship,
                items:
                    relationships.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r, style: AppTypography.bodyLarge()),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRelationship = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.borderSoft),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Story / About Person',
                style: AppTypography.bodyLarge(weight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _storyController,
                style: AppTypography.bodyLarge(),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add a special story or context to remember this person by...',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.borderSoft),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: AppColors.coral,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: _isSaving ? 'Saving...' : (isEditing ? 'Update Member' : 'Save Family Member'),
                icon: Icons.check,
                onPressed: _isSaving ? null : _saveMember,
              ),
              if (isEditing) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: _isDeleting ? 'Deleting...' : 'Delete Member',
                  icon: Icons.delete,
                  variant: ButtonVariant.secondary,
                  onPressed: _isDeleting ? null : _deleteMember,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
