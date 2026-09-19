import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/app_avatar.dart';
import '../../caregiver/screens/caregiver_connect_sheet.dart';

class ProfileBottomSheet extends StatelessWidget {
  const ProfileBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
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
                        AppConstants.defaultPatientFullName,
                        style: AppTypography.headingSmall(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Age: ${AppConstants.defaultPatientAge} • ${AppConstants.defaultLanguage}',
                        style: AppTypography.bodySmall(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Caregiver: Aparna Baruah',
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
              icon: Icons.cloud_sync,
              title: 'Sync Status',
              subtitle: 'Saved offline in SQLite • Auto-syncs when online',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'All records safely stored offline on your device.',
                    ),
                    backgroundColor: AppColors.deepTeal,
                  ),
                );
              },
            ),
            _buildProfileItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Voice Guide',
              subtitle: 'Tap Mati / Speak anytime to hear instructions',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
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
