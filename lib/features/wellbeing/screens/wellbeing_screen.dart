import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/game_repository.dart';
import '../../home/screens/placeholder_screen.dart';
import '../../voice_assistant/screens/voice_assistant_screen.dart';
import '../../../widgets/app_button.dart';

class WellbeingScreen extends StatefulWidget {
  const WellbeingScreen({super.key});

  @override
  State<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends State<WellbeingScreen> {
  final GameRepository _gameRepo = GameRepository();
  bool _isLoading = true;
  String _wellbeingState = 'CALM';

  @override
  void initState() {
    super.initState();
    _evaluateWellbeing();
  }

  Future<void> _evaluateWellbeing() async {
    final events = await _gameRepo.getRecentDifficultyEvents(limit: 5);
    
    if (events.isEmpty) {
      if (mounted) {
        setState(() {
          _wellbeingState = 'CALM';
          _isLoading = false;
        });
      }
      return;
    }

    // Determine state based on recent interactions (highest signal from last 5 events)
    double maxSignal = 0.0;
    for (var event in events) {
      if (event.difficultySignal > maxSignal) {
        maxSignal = event.difficultySignal;
      }
    }

    if (mounted) {
      setState(() {
        if (maxSignal >= 0.65) {
          _wellbeingState = 'NEEDS SUPPORT';
        } else if (maxSignal >= 0.35) {
          _wellbeingState = 'NEEDS A BREAK';
        } else {
          _wellbeingState = 'CALM';
        }
        _isLoading = false;
      });
    }
  }

  Widget _buildStateIndicator() {
    IconData icon;
    Color color;
    String description;

    switch (_wellbeingState) {
      case 'NEEDS SUPPORT':
        icon = Icons.support_agent;
        color = AppColors.coral;
        description = 'It seems you might be feeling overwhelmed or stuck.';
        break;
      case 'NEEDS A BREAK':
        icon = Icons.self_improvement;
        color = Colors.orange;
        description = 'You have been working hard. A short break might help.';
        break;
      case 'CALM':
      default:
        icon = Icons.mood;
        color = AppColors.sageGreen;
        description = 'You are doing great and pacing well.';
        break;
    }

    return Column(
      children: [
        Icon(icon, size: 80, color: color),
        const SizedBox(height: AppSpacing.md),
        Text(
          _wellbeingState,
          style: AppTypography.headingMedium(color: color),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          description,
          style: AppTypography.bodyLarge(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Wellbeing', style: AppTypography.headingMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.sageGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  _buildStateIndicator(),
                  const SizedBox(height: AppSpacing.xxxl),
                  if (_wellbeingState != 'CALM') ...[
                    AppButton(
                      label: 'Take a Break',
                      icon: Icons.pause,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Voice Assistant',
                      icon: Icons.mic,
                      variant: ButtonVariant.secondary,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const VoiceAssistantScreen(),
                        ));
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Contact Caregiver',
                      icon: Icons.favorite,
                      variant: ButtonVariant.secondary,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const PlaceholderScreen(title: 'Caregiver Connection'),
                        ));
                      },
                    ),
                  ] else ...[
                    AppButton(
                      label: 'Return Home',
                      icon: Icons.home,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
