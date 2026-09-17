import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/family_member.dart';
import '../../../widgets/app_avatar.dart';
import '../../../widgets/app_button.dart';

class FaceResultDialog extends StatelessWidget {
  final FamilyMember? matchedMember;
  final String message;
  final bool isSuccess;

  const FaceResultDialog({
    super.key,
    this.matchedMember,
    required this.message,
    required this.isSuccess,
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
            if (matchedMember != null) ...[
              AppAvatar(
                imagePath: matchedMember!.photoPath,
                size: 88,
                borderColor: AppColors.coral,
                borderWidth: 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                matchedMember!.name,
                style: AppTypography.headingLarge(color: AppColors.coral),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your ${matchedMember!.relationship.toLowerCase()}',
                style: AppTypography.bodyLarge(weight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? AppColors.softGreenBadge
                      : AppColors.warmPaleCoral,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess
                      ? Icons.person_search
                      : Icons.face_retouching_natural,
                  size: 36,
                  color: isSuccess ? AppColors.sageGreen : AppColors.coral,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                style: AppTypography.headingSmall(),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppButton(label: 'Done', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
