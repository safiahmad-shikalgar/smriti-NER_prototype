import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/status_pill.dart';

class ExerciseTimeline extends StatelessWidget {
  const ExerciseTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderSoft, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Exercise Journey', style: AppTypography.headingSmall()),
          const SizedBox(height: AppSpacing.lg),
          _buildTimelineItem(
            title: 'Morning Memory Walk',
            subtitle: 'Warm up with familiar words',
            time: '9:00 AM',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'Market Object Recall',
            subtitle: 'Haat Bazaar working memory practice',
            time: '11:30 AM',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'Evening Family Photo Quiz',
            subtitle: 'Recognizing grandchildren and relatives',
            time: '5:30 PM',
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.softGreenBadge
                    : AppColors.softNeutral,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.sageGreen
                      : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: isCompleted ? 18 : 8,
                color: isCompleted ? AppColors.deepTeal : AppColors.textMuted,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isCompleted
                    ? AppColors.sageGreen.withValues(alpha: 0.5)
                    : AppColors.borderSoft,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.bodyLarge(weight: FontWeight.w700),
                      ),
                    ),
                    StatusPill(
                      text: isCompleted ? 'Completed' : 'Upcoming',
                      backgroundColor: isCompleted
                          ? AppColors.softGreenBadge
                          : AppColors.warmPaleCoral,
                      textColor: isCompleted
                          ? AppColors.deepTeal
                          : AppColors.coral,
                      icon: isCompleted ? Icons.check_circle : Icons.schedule,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
