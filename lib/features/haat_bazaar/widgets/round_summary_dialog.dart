import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_button.dart';
import '../../../services/tts/tts_service.dart';

class RoundSummaryDialog extends StatelessWidget {
  final bool isCorrect;
  final bool isLastRound;
  final double? finalAccuracy;
  final VoidCallback onNext;

  const RoundSummaryDialog({
    super.key,
    required this.isCorrect,
    required this.isLastRound,
    this.finalAccuracy,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final title = isLastRound
        ? 'Wonderful Work, Aai!'
        : (isCorrect ? 'Wonderful!' : "That's okay.");
    final message = isLastRound
        ? 'You have finished today\'s Haat Bazaar Recall!'
        : (isCorrect
              ? 'You remembered them all.'
              : "Let's try the next one together.");

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(
          color: isCorrect ? AppColors.sageGreen : AppColors.coral,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppColors.softGreenBadge
                    : AppColors.warmPaleCoral,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLastRound
                    ? Icons.emoji_events
                    : (isCorrect ? Icons.sentiment_very_satisfied : Icons.spa),
                color: isCorrect ? AppColors.deepTeal : AppColors.coral,
                size: 44,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headingMedium(
                color: isCorrect ? AppColors.deepTeal : AppColors.coral,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTypography.bodyMedium(),
              textAlign: TextAlign.center,
            ),
            if (isLastRound && finalAccuracy != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warmBeige,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  'Today\'s Accuracy: ${finalAccuracy!.toStringAsFixed(0)}%',
                  style: AppTypography.headingSmall(color: AppColors.deepTeal),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: isLastRound ? 'SEE PROGRESS' : 'NEXT ROUND',
              icon: isLastRound ? Icons.celebration : Icons.arrow_forward,
              onPressed: () {
                TtsService.instance.stop();
                onNext();
              },
            ),
          ],
        ),
      ),
    );
  }
}
