import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary, subtle }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final double height;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.height = AppSpacing.buttonHeight,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppColors.coral;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppColors.surfaceWhite;
        foregroundColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.sageGreen, width: 2);
        break;
      case ButtonVariant.subtle:
        backgroundColor = AppColors.warmPaleCoral;
        foregroundColor = AppColors.coral;
        borderSide = const BorderSide(color: AppColors.coral, width: 1);
        break;
    }

    final buttonWidget = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        minimumSize: Size(isFullWidth ? double.infinity : 120, height),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: borderSide,
        ),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 24, color: foregroundColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label, style: AppTypography.button(color: foregroundColor)),
        ],
      ),
    );

    return Semantics(button: true, label: label, child: buttonWidget);
  }
}
