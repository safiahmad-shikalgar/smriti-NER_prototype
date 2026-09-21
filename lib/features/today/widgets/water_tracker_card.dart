import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/reminder.dart';
import '../../../widgets/app_card.dart';
import 'water_tracker_bottom_sheet.dart';

class WaterTrackerCard extends StatelessWidget {
  final Reminder waterReminder;
  final VoidCallback onUpdated;

  const WaterTrackerCard({
    super.key,
    required this.waterReminder,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final completed = waterReminder.completedCount;
    // targetCount now stores total ML (e.g. 2000), not glasses
    final total = waterReminder.targetCount > 0 ? waterReminder.targetCount : 2000;
    final progress = (completed / total).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => FractionallySizedBox(
            heightFactor: 0.85,
            child: WaterTrackerBottomSheet(
              waterReminder: waterReminder,
              onUpdated: onUpdated,
            ),
          ),
        );
      },
      child: AppCard(
        backgroundColor: AppColors.surfaceWhite,
        borderColor: AppColors.borderSoft,
        borderWidth: 1.5,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STAY HYDRATED',
                  style: AppTypography.bodySmall(
                    color: AppColors.activeBlue,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$completed / $total ml',
                  style: AppTypography.bodySmall(
                    color: AppColors.textPrimary,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Drink Warm Water', style: AppTypography.headingSmall()),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap to add water, view history, or change target.',
              style: AppTypography.bodySmall(),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.activeBlue.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.activeBlue),
                minHeight: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
