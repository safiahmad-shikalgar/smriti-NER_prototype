import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/reminder.dart';
import '../../../widgets/app_card.dart';

class WaterTrackerCard extends StatelessWidget {
  final Reminder waterReminder;
  final Function(int newCount) onCountChanged;

  const WaterTrackerCard({
    super.key,
    required this.waterReminder,
    required this.onCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final completed = waterReminder.completedCount;
    final total = waterReminder.targetCount;

    return AppCard(
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
                '$completed / $total glasses',
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
            'Tap each glass when you finish drinking.',
            style: AppTypography.bodySmall(),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Six large visual cells
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(total, (index) {
              final isFilled = index < completed;
              return GestureDetector(
                onTap: () {
                  // If tapped on already filled glass -> unfill to that index, else fill up to this index
                  final newCount = (index + 1 == completed) ? index : index + 1;
                  onCountChanged(newCount);
                },
                child: Container(
                  width: 46,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? AppColors.activeBlue.withOpacity(0.15)
                        : AppColors.softNeutral,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: isFilled
                          ? AppColors.activeBlue
                          : AppColors.borderSoft,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFilled
                            ? Icons.local_drink
                            : Icons.local_drink_outlined,
                        color: isFilled
                            ? AppColors.activeBlue
                            : AppColors.textMuted,
                        size: 26,
                      ),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isFilled
                              ? AppColors.activeBlue
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
