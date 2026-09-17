import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/game/haat_bazaar_game_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/mati_speak_button.dart';

class RecallPhaseView extends StatelessWidget {
  final List<MarketItem> choices;
  final Set<String> selectedItemIds;
  final Function(String) onItemTapped;
  final VoidCallback onSubmit;

  const RecallPhaseView({
    super.key,
    required this.choices,
    required this.selectedItemIds,
    required this.onItemTapped,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Which ones did you see?',
                    style: AppTypography.headingMedium(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tap each item you remember.',
                    style: AppTypography.bodyMedium(),
                  ),
                ],
              ),
            ),
            const MatiSpeakButton(
              textToSpeak:
                  'Which ones did you see? Tap each item you remember.',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        // Interactive choice grid
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: 0.85,
            ),
            itemCount: choices.length,
            itemBuilder: (context, index) {
              final item = choices[index];
              final isSelected = selectedItemIds.contains(item.id);

              return GestureDetector(
                onTap: () => onItemTapped(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: ShapeDecoration(
                    color: isSelected
                        ? AppColors.warmPaleCoral
                        : AppColors.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.coral
                            : AppColors.borderSoft,
                        width: isSelected ? 3 : 1.5,
                      ),
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
                  child: Stack(
                    children: [
                      Column(
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
                      if (isSelected)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.coral,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: AppButton(
            label: "I've Selected Them",
            icon: Icons.check_circle_outline,
            onPressed: selectedItemIds.isNotEmpty ? onSubmit : null,
          ),
        ),
      ],
    );
  }
}
