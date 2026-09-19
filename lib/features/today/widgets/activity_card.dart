import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/reminder.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/status_pill.dart';

class ActivityCard extends StatelessWidget {
  final Reminder activityReminder;
  final VoidCallback onPlay;

  const ActivityCard({
    super.key,
    required this.activityReminder,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.warmBeige,
      borderColor: AppColors.sageGreen,
      borderWidth: 1.5,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVITY TIME',
                style: AppTypography.bodySmall(
                  color: AppColors.sageGreen,
                  weight: FontWeight.w700,
                ),
              ),
              StatusPill(
                text: activityReminder.scheduledTime,
                icon: Icons.access_time,
                backgroundColor: Colors.white,
                textColor: AppColors.sageGreen,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.sageGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront,
                  color: AppColors.sageGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityReminder.title,
                      style: AppTypography.headingSmall(),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activityReminder.subtitle,
                      style: AppTypography.bodyMedium(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'START ACTIVITY',
            icon: Icons.play_arrow,
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}
