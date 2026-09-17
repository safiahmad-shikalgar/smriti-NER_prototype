import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/family_member.dart';
import '../../../widgets/app_avatar.dart';
import '../../../services/tts/tts_service.dart';

class FamilyMemberTile extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback? onTap;

  const FamilyMemberTile({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        TtsService.instance.speak(
          '${member.name}, your ${member.relationship.toLowerCase()}',
        );
        onTap?.call();
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          children: [
            AppAvatar(
              imagePath: member.photoPath,
              size: 72,
              borderColor: AppColors.sageGreen,
              borderWidth: 2,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              member.name,
              style: AppTypography.bodyMedium(weight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              member.relationship,
              style: AppTypography.bodySmall(color: AppColors.sageGreen),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
