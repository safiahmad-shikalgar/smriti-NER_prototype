import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/game/haat_bazaar_game_service.dart';
import '../../../widgets/mati_speak_button.dart';

class MemoryPhaseView extends StatelessWidget {
  final List<MarketItem> targetItems;
  final int remainingSeconds;
  final int totalSeconds;

  const MemoryPhaseView({
    super.key,
    required this.targetItems,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remember these items.',
                    style: AppTypography.headingMedium(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Watch carefully before they hide.',
                    style: AppTypography.bodyMedium(),
                  ),
                ],
              ),
            ),
            const MatiSpeakButton(
              textToSpeak:
                  'Remember these items. Watch carefully before they hide.',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Exposure progress timer bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(
            value: totalSeconds > 0 ? (remainingSeconds / totalSeconds) : 0,
            backgroundColor: AppColors.warmPaleCoral,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.coral),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Grid of target items
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: 0.85,
            ),
            itemCount: targetItems.length,
            itemBuilder: (context, index) {
              final item = targetItems[index];
              return Container(
                decoration: ShapeDecoration(
                  color: AppColors.surfaceWhite,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.coral, width: 2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        item.assetPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          Text(
                            item.name,
                            style: AppTypography.headingSmall(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.assameseName,
                            style: AppTypography.bodySmall(
                              color: AppColors.sageGreen,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
