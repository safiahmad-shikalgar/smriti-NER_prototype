import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/reminder.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_pill.dart';
import 'reminder_confirmation_dialog.dart';

class MedicineCard extends StatelessWidget {
  final Reminder reminder;
  final Function(bool isDone) onAction;

  const MedicineCard({
    super.key,
    required this.reminder,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: reminder.isCompleted
          ? AppColors.softGreenBadge
          : AppColors.warmPaleCoral,
      borderColor: reminder.isCompleted ? AppColors.sageGreen : AppColors.coral,
      borderWidth: 1.5,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEDICINE TIME',
                style: AppTypography.bodySmall(
                  color: reminder.isCompleted
                      ? AppColors.deepTeal
                      : AppColors.coral,
                  weight: FontWeight.w700,
                ),
              ),
              StatusPill(
                text: reminder.scheduledTime,
                icon: Icons.access_time,
                backgroundColor: Colors.white,
                textColor: reminder.isCompleted
                    ? AppColors.deepTeal
                    : AppColors.coral,
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
                  color: AppColors.activeBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppColors.activeBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.title, style: AppTypography.headingSmall()),
                    const SizedBox(height: 2),
                    Text(reminder.subtitle, style: AppTypography.bodyMedium()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (reminder.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.successGreen,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Taken Today',
                    style: AppTypography.bodyLarge(
                      color: AppColors.successGreen,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onAction(false), // Remind later
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(
                        color: AppColors.coral,
                        width: 1.5,
                      ),
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      'Remind Later',
                      style: AppTypography.button(color: AppColors.coral),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ReminderConfirmationDialog(
                          medicineName:
                              '${reminder.title} ${reminder.subtitle}',
                          onConfirm: () {
                            Navigator.pop(context);
                            onAction(true); // Done
                          },
                          onRemindLater: () {
                            Navigator.pop(context);
                            onAction(false);
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    child: Text('Done', style: AppTypography.button()),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
