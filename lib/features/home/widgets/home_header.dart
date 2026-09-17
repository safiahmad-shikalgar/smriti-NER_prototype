import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../widgets/app_avatar.dart';
import '../../../widgets/mati_speak_button.dart';
import '../../face_recognition/screens/face_scan_screen.dart';
import '../../profile/widgets/profile_bottom_sheet.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final String avatarPath;

  const HomeHeader({
    super.key,
    this.greeting = 'Namaskar, Aai',
    this.subtitle = 'Shall we spend a little time together?',
    this.avatarPath = AssetPaths.aaiAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top action bar: Voice button, Face recognition camera button, Profile Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MatiSpeakButton(textToSpeak: '$greeting. $subtitle'),
              Row(
                children: [
                  // Dedicated Face-Recognition Camera Button (Separate from profile icon)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FaceScanScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(right: AppSpacing.md),
                      decoration: ShapeDecoration(
                        color: AppColors.warmPaleCoral,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1.5,
                            color: AppColors.coral,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural,
                        color: AppColors.coral,
                        size: 24,
                      ),
                    ),
                  ),
                  // User Profile Avatar (Opens Profile Bottom Sheet)
                  AppAvatar(
                    imagePath: avatarPath,
                    size: 48,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const ProfileBottomSheet(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Greeting & Supportive Prompt
          Text(greeting, style: AppTypography.headingLarge()),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTypography.bodyMedium()),
        ],
      ),
    );
  }
}
