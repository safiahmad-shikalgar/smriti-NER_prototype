import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../models/memory.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/memory_highlight_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MemoryRepository _memoryRepository = MemoryRepository();
  Memory? _highlightMemory;

  @override
  void initState() {
    super.initState();
    _loadHighlightMemory();
  }

  Future<void> _loadHighlightMemory() async {
    final memory = await _memoryRepository.getHighlightMemory();
    if (mounted) {
      setState(() {
        _highlightMemory = memory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  children: [
                    // Action 1: Let's Play (Pale coral card, coral border)
                    QuickActionCard(
                      title: "Let's Play",
                      subtitle: "Fun memory games made for you",
                      icon: Icons.extension,
                      backgroundColor: AppColors.warmPaleCoral,
                      borderColor: AppColors.coral,
                      iconColor: AppColors.coral,
                      onTap: () =>
                          widget.onNavigateTab(1), // Navigate to Play tab
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Action 2: My Memories (Soft neutral card, sage green border)
                    QuickActionCard(
                      title: "My Memories",
                      subtitle: "Look at familiar family photos",
                      icon: Icons.photo_library,
                      backgroundColor: AppColors.softNeutral,
                      borderColor: AppColors.sageGreen,
                      iconColor: AppColors.sageGreen,
                      onTap: () =>
                          widget.onNavigateTab(2), // Navigate to Memories tab
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Action 3: Today's Guide (Warm beige card, gray-brown border)
                    QuickActionCard(
                      title: "Today's Guide",
                      subtitle: "Your medicine & water helper",
                      icon: Icons.calendar_today,
                      backgroundColor: AppColors.warmBeige,
                      borderColor: AppColors.textMuted,
                      iconColor: AppColors.textPrimary,
                      onTap: () =>
                          widget.onNavigateTab(3), // Navigate to Today tab
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              MemoryHighlightCard(memory: _highlightMemory),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
