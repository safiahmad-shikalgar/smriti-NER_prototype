import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_button.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Help & Support', style: AppTypography.headingMedium()),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.help_outline, size: 48, color: AppColors.coral),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'How can we help you?',
              style: AppTypography.headingLarge(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'If you need assistance using the app, please ask your caregiver or family member.',
              style: AppTypography.bodyLarge(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone, color: AppColors.coral, size: 32),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Call Emergency Contact',
                          style: AppTypography.headingMedium(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Call Now',
                    icon: Icons.call,
                    onPressed: () {
                      // Placeholder for calling logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling caregiver...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AppButton(
              label: 'Go Back',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
