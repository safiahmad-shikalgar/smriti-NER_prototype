import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_card.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        backgroundColor: AppColors.surfaceWhite,
        borderColor: AppColors.borderSoft,
        borderWidth: 1.5,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(value, style: AppTypography.headingMedium(color: color)),
            const SizedBox(height: 2),
            Text(
              title,
              style: AppTypography.bodySmall(weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
