import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_button.dart';

class SupportInterventionDialog extends StatefulWidget {
  final VoidCallback onKeepGoing;
  final VoidCallback onTakeBreak;

  const SupportInterventionDialog({
    super.key,
    required this.onKeepGoing,
    required this.onTakeBreak,
  });

  @override
  State<SupportInterventionDialog> createState() =>
      _SupportInterventionDialogState();
}

class _SupportInterventionDialogState extends State<SupportInterventionDialog> {
  bool _isTakingBreakState = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.coral, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.warmPaleCoral,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline,
                color: AppColors.coral,
                size: 38,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!_isTakingBreakState) ...[
              Text(
                "Let's try an easier one.",
                style: AppTypography.headingMedium(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "We can take our time together, Aai.",
                style: AppTypography.bodyMedium(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'KEEP GOING',
                icon: Icons.play_arrow,
                onPressed: widget.onKeepGoing,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'TAKE A BREAK',
                icon: Icons.pause_circle_outline,
                variant: ButtonVariant.secondary,
                onPressed: () {
                  setState(() => _isTakingBreakState = true);
                },
              ),
            ] else ...[
              Text(
                "Let's take a little break.",
                style: AppTypography.headingMedium(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Relax and breathe. We can continue whenever you feel ready.",
                style: AppTypography.bodyMedium(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'CONTINUE',
                icon: Icons.play_arrow,
                onPressed: widget.onKeepGoing,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'CLOSE GAME',
                icon: Icons.home,
                variant: ButtonVariant.secondary,
                onPressed: widget.onTakeBreak,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
