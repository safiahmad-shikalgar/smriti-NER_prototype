import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../widgets/mati_speak_button.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/exercise_timeline.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final GameRepository _gameRepository = GameRepository();
  int _completedGames = 3;
  double _accuracy = 80.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final count = await _gameRepository.getCompletedGamesCount();
    final avgAcc = await _gameRepository.getAverageAccuracy();
    if (mounted) {
      setState(() {
        _completedGames = count > 0 ? count : 3;
        _accuracy = avgAcc > 0 ? avgAcc : 80.0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Progress', style: AppTypography.headingMedium()),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: MatiSpeakButton(
              textToSpeak:
                  'Wonderful work, Aai! Look at your achievements today.',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.coral),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encouraging Hero Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: ShapeDecoration(
                        color: AppColors.warmPaleCoral,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: AppColors.coral,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: AppColors.coral,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wonderful Work, Aai!',
                                  style: AppTypography.headingSmall(
                                    color: AppColors.coral,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'You are keeping your memory active and joyful today.',
                                  style: AppTypography.bodySmall(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Badges row
                    Row(
                      children: [
                        AchievementBadge(
                          title: 'Games Completed',
                          value: '$_completedGames Games',
                          icon: Icons.sports_esports,
                          color: AppColors.coral,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AchievementBadge(
                          title: "Today's Accuracy",
                          value: '${_accuracy.toStringAsFixed(0)}%',
                          icon: Icons.star,
                          color: AppColors.deepTeal,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Exercise Timeline
                    const ExerciseTimeline(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
      ),
    );
  }
}
