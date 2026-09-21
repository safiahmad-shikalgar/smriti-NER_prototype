import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../models/patient.dart';
import '../../../widgets/app_button.dart';
import '../../../services/auth/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final VoidCallback? onProfileSaved;
  
  const ProfileEditScreen({super.key, this.onProfileSaved});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientRepo = PatientRepository();
  
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _medicalInfoController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  Patient? _existingPatient;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = AuthService.instance.currentUser;
    final patient = await _patientRepo.getPatient(user?.id);
    if (patient != null) {
      _existingPatient = patient;
      _nameController.text = patient.fullName;
      _ageController.text = patient.age.toString();
      _medicalInfoController.text = patient.medicalInfo;
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _medicalInfoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authUserId = AuthService.instance.currentUser?.id ?? const Uuid().v4();
      final now = DateTime.now();

      final patientToSave = Patient(
        id: _existingPatient?.id ?? 'patient_$authUserId',
        name: _nameController.text.trim().split(' ').firstWhere((e) => e.isNotEmpty, orElse: () => 'User'),
        fullName: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        preferredLanguage: _existingPatient?.preferredLanguage ?? 'Assamese / English',
        caregiverInfo: _existingPatient?.caregiverInfo ?? '',
        medicalInfo: _medicalInfoController.text.trim(),
        createdAt: _existingPatient?.createdAt ?? now,
      );

      await _patientRepo.updatePatient(patientToSave);

      if (widget.onProfileSaved != null) {
        widget.onProfileSaved!();
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.coral)),
      );
    }

    final isNewProfile = _existingPatient == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isNewProfile ? null : AppBar(
        title: Text('Edit Profile', style: AppTypography.headingMedium()),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNewProfile) ...[
                  Text(
                    'Setup Profile',
                    style: AppTypography.headingLarge(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Let\'s get to know you better.',
                    style: AppTypography.bodyLarge(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],

                // Full Name
                Text(
                  'Full Name',
                  style: AppTypography.headingSmall(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: AppTypography.bodyLarge(),
                  decoration: _buildInputDecoration('e.g. Pratibha Devi'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your name.' : null,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Age
                Text(
                  'Age',
                  style: AppTypography.headingSmall(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyLarge(),
                  decoration: _buildInputDecoration('e.g. 74'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter your age.';
                    if (int.tryParse(value) == null) return 'Please enter a valid number.';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Medical Information
                Text(
                  'Medical Information',
                  style: AppTypography.headingSmall(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _medicalInfoController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTypography.bodyLarge(),
                  decoration: _buildInputDecoration('e.g. Blood Pressure, Diabetes...'),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Save Button
                _isSaving
                    ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
                    : AppButton(
                        label: isNewProfile ? 'Continue to Home' : 'Save Profile',
                        onPressed: _handleSave,
                        icon: isNewProfile ? Icons.arrow_forward : Icons.save,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyLarge(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.coral, width: 2),
      ),
      contentPadding: const EdgeInsets.all(AppSpacing.lg),
    );
  }
}
