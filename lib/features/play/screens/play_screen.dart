import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../widgets/mati_speak_button.dart';
import '../../haat_bazaar/screens/haat_bazaar_screen.dart';
import '../widgets/game_card.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Let's Play", style: AppTypography.headingLarge()),
                  const MatiSpeakButton(
                    textToSpeak:
                        "Let's Play. Play games to keep your mind sharp.",
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Play games to keep your mind sharp.',
                style: AppTypography.bodyMedium(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 1. Primary Fully Working Game: HAAT BAZAAR RECALL
              GameCard(
                title: 'HAAT BAZAAR RECALL',
                subtitle: 'Remember familiar market objects.',
                imagePath: AssetPaths.assamTea,
                isAvailable: true,
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HaatBazaarScreen()),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // 2. Coming Soon Game: Loom Pattern Weaver
              const GameCard(
                title: 'LOOM PATTERN WEAVER',
                subtitle:
                    'Match traditional Assamese weaving colors and motifs.',
                imagePath: AssetPaths.gamusaPattern,
                isAvailable: false,
              ),
              const SizedBox(height: AppSpacing.xl),

              // 3. Coming Soon Game: Sur-Taal Echo
              const GameCard(
                title: 'SUR-TAAL ECHO',
                subtitle: 'Follow the gentle rhythm of folk borgeet beats.',
                imagePath: AssetPaths.jaapi,
                isAvailable: false,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
