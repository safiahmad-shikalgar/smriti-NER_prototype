import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/status_pill.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isAvailable;
  final VoidCallback? onPlay;

  const GameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.isAvailable = true,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.borderSoft, width: 1.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Image
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(imagePath, fit: BoxFit.cover),
                if (!isAvailable)
                  Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: const StatusPill(
                      text: 'COMING SOON',
                      backgroundColor: Colors.white,
                      textColor: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: AppTypography.headingMedium()),
                    ),
                    if (isAvailable)
                      const StatusPill(
                        text: 'Working Memory',
                        backgroundColor: AppColors.softGreenBadge,
                        textColor: AppColors.deepTeal,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTypography.bodyMedium()),
                if (isAvailable) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'PLAY NOW',
                    icon: Icons.play_arrow,
                    onPressed: onPlay,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
