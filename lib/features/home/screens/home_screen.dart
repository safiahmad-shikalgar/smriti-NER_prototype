import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../profile/widgets/profile_bottom_sheet.dart';
import '../../help/screens/help_screen.dart';
import '../widgets/quick_action_card.dart';
import '../../face_recognition/screens/face_scan_screen.dart';
import '../../wellbeing/screens/wellbeing_screen.dart';
import '../../voice_assistant/screens/voice_assistant_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab; // Kept for API compatibility if needed by MainScaffold

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('SMRITI', style: AppTypography.headingLarge(color: AppColors.coral)),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 1,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: AppTypography.headingLarge(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'What would you like to do?',
                  style: AppTypography.bodyLarge(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                
                // 1. Face Recognition
                QuickActionCard(
                  title: 'Face Recognition',
                  subtitle: 'Identify a family member',
                  icon: Icons.face_retouching_natural,
                  backgroundColor: AppColors.warmPaleCoral,
                  borderColor: AppColors.coral,
                  iconColor: AppColors.coral,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const FaceScanScreen(),
                    ));
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Voice Assistant
                QuickActionCard(
                  title: 'Voice Assistant',
                  subtitle: 'Talk to your smart helper',
                  icon: Icons.mic,
                  backgroundColor: AppColors.softNeutral,
                  borderColor: AppColors.sageGreen,
                  iconColor: AppColors.sageGreen,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const VoiceAssistantScreen(),
                    ));
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Profile
                QuickActionCard(
                  title: 'My Profile',
                  subtitle: 'View or edit your details',
                  icon: Icons.person,
                  backgroundColor: AppColors.warmBeige,
                  borderColor: AppColors.textMuted,
                  iconColor: AppColors.textPrimary,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const ProfileBottomSheet(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                // 4. Wellbeing
                QuickActionCard(
                  title: 'My Wellbeing',
                  subtitle: 'Check how you are feeling',
                  icon: Icons.self_improvement,
                  backgroundColor: AppColors.surfaceWhite,
                  borderColor: AppColors.coral,
                  iconColor: AppColors.coral,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const WellbeingScreen(),
                    ));
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // 5. Help
                QuickActionCard(
                  title: 'Help & Support',
                  subtitle: 'Get assistance with the app',
                  icon: Icons.help_outline,
                  backgroundColor: AppColors.surfaceWhite,
                  borderColor: AppColors.sageGreen,
                  iconColor: AppColors.sageGreen,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const HelpScreen(),
                    ));
                  },
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
