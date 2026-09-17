import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_button.dart';

class ReminderConfirmationDialog extends StatelessWidget {
  final String medicineName;
  final VoidCallback onConfirm;
  final VoidCallback onRemindLater;

  const ReminderConfirmationDialog({
    super.key,
    required this.medicineName,
    required this.onConfirm,
    required this.onRemindLater,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.borderSoft, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.warmPaleCoral,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_liquid,
                color: AppColors.coral,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Did you take your Blood Pressure Medicine?',
              style: AppTypography.headingSmall(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              medicineName,
              style: AppTypography.bodySmall(color: AppColors.sageGreen),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Yes, I did',
              icon: Icons.check,
              onPressed: onConfirm,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Remind Me Later',
              icon: Icons.access_time,
              variant: ButtonVariant.secondary,
              onPressed: onRemindLater,
            ),
          ],
        ),
      ),
    );
  }
}
