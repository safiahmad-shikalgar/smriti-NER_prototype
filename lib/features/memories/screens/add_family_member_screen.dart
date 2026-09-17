import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../models/family_member.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../widgets/app_button.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final FamilyRepository _repository = FamilyRepository();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  static const List<String> relationships = [
    'Son',
    'Daughter',
    'Grandson',
    'Granddaughter',
    'Brother',
    'Sister',
    'Friend',
  ];

  String _selectedRelationship = 'Granddaughter';
  File? _imageFile;
  bool _isSaving = false;

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

    setState(() => _isSaving = true);

    final photoPath = _imageFile?.path ?? AssetPaths.riyaAvatar;
    final newMember = FamilyMember(
      id: const Uuid().v4(),
      patientId: 'patient_aai_01',
      name: name,
      relationship: _selectedRelationship,
      photoPath: photoPath,
      faceEmbedding: [0.1, 0.2, 0.3, 0.4, 0.5], // seeded embedding
      createdAt: DateTime.now(),
    );

    await _repository.insertFamilyMember(newMember);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Family Member', style: AppTypography.headingMedium()),
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
                    child:
                        _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
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
                'Relationship to Aai',
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
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: _isSaving ? 'Saving...' : 'Save Family Member',
                icon: Icons.check,
                onPressed: _isSaving ? null : _saveMember,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
