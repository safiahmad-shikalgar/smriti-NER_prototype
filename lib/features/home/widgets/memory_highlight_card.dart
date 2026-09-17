import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../models/memory.dart';
import '../../../services/tts/tts_service.dart';

class MemoryHighlightCard extends StatelessWidget {
  final Memory? memory;
  final VoidCallback? onTap;

  const MemoryHighlightCard({super.key, this.memory, this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = memory?.title ?? "Riya's 20th Birthday";
    final description =
        memory?.description ?? 'Celebrated in Guwahati with whole family';
    final photoPath = memory?.photoPath ?? AssetPaths.riyaBirthdayMemory;

    ImageProvider provider;
    if (photoPath.startsWith('assets/')) {
      provider = AssetImage(photoPath);
    } else if (File(photoPath).existsSync()) {
      provider = FileImage(File(photoPath));
    } else {
      provider = const AssetImage(AssetPaths.riyaBirthdayMemory);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text("Today's Highlight", style: AppTypography.headingSmall()),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: AppColors.surfaceWhite,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: AppColors.borderSoft),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight Photo (180dp height)
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Image(image: provider, fit: BoxFit.cover),
                ),
                // Bottom content bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  color: AppColors.surfaceWhite,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTypography.headingSmall()),
                            const SizedBox(height: AppSpacing.xs),
                            Text(description, style: AppTypography.bodySmall()),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Action button (40x40 circle with pale coral background)
                      GestureDetector(
                        onTap: () {
                          TtsService.instance.speak('$title. $description');
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                            color: AppColors.warmPaleCoral,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: AppColors.coral,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
