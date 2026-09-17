import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/memory.dart';
import '../../../services/tts/tts_service.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;

  const MemoryCard({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    ImageProvider provider;
    if (memory.photoPath.startsWith('assets/')) {
      provider = AssetImage(memory.photoPath);
    } else if (File(memory.photoPath).existsSync()) {
      provider = FileImage(File(memory.photoPath));
    } else {
      provider = const AssetImage('assets/images/memories/riya_birthday.png');
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: ShapeDecoration(
        color: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.borderSoft, width: 1.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image(image: provider, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(memory.title, style: AppTypography.headingSmall()),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        memory.description,
                        style: AppTypography.bodyMedium(),
                      ),
                      if (memory.dateDescription.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          memory.dateDescription,
                          style: AppTypography.bodySmall(
                            color: AppColors.sageGreen,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: () {
                    TtsService.instance.speak(
                      '${memory.title}. ${memory.description}',
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: ShapeDecoration(
                      color: AppColors.warmPaleCoral,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: AppColors.coral,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
