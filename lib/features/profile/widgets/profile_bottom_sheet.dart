import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/app_avatar.dart';
import '../../caregiver/screens/caregiver_connect_sheet.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../models/patient.dart';
import '../../../services/auth/auth_service.dart';
import '../screens/profile_edit_screen.dart';

class ProfileBottomSheet extends StatefulWidget {
  const ProfileBottomSheet({super.key});

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  final PatientRepository _patientRepo = PatientRepository();
  Patient? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final user = AuthService.instance.currentUser;
    final patient = await _patientRepo.getPatient(user?.id);
    if (mounted) {
      setState(() {
        _patient = patient;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.coral)),
      );
    }

    final name = _patient?.fullName ?? AppConstants.defaultPatientFullName;
    final age = _patient?.age ?? AppConstants.defaultPatientAge;
    final lang = _patient?.preferredLanguage ?? AppConstants.defaultLanguage;
    final caregiver = _patient?.caregiverInfo ?? 'Aparna Baruah';

    return Material(
      color: AppColors.background,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xl,
        ),
        child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const AppAvatar(imagePath: AssetPaths.aaiAvatar, size: 64),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.headingSmall(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Age: $age • $lang',
                        style: AppTypography.bodySmall(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Caregiver: $caregiver',
                        style: AppTypography.bodySmall(
                          color: AppColors.sageGreen,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(color: AppColors.borderSoft),
            const SizedBox(height: AppSpacing.md),
            _buildProfileItem(
              context,
              icon: Icons.edit,
              title: 'Edit Profile',
              subtitle: 'Update your medical information and details',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
              },
            ),
            _buildProfileItem(
              context,
              icon: Icons.link,
              title: 'Caregiver Connection',
              subtitle: 'Pairing Code: ${AppConstants.caregiverPairingCode}',
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const CaregiverConnectSheet(),
                );
              },
            ),
            _buildProfileItem(
              context,
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Securely sign out of your account',
              onTap: () async {
                final navigator = Navigator.of(context);
                await AuthService.instance.signOut();
                if (navigator.mounted) navigator.pop();
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.warmPaleCoral,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(icon, color: AppColors.coral, size: 22),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge(weight: FontWeight.w700),
      ),
      subtitle: Text(subtitle, style: AppTypography.bodySmall()),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
