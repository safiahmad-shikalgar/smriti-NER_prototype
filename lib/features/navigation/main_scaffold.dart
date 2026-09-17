import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../home/screens/home_screen.dart';
import '../play/screens/play_screen.dart';
import '../memories/screens/memories_screen.dart';
import '../today/screens/today_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const PlayScreen(),
      const MemoriesScreen(),
      const TodayScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border(
            top: BorderSide(color: AppColors.borderSoft, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: 'Home',
                      icon: Icons.home,
                      isSelected: _currentIndex == 0,
                    ),
                    _buildNavItem(
                      index: 1,
                      label: 'Play',
                      icon: Icons.extension,
                      isSelected: _currentIndex == 1,
                    ),
                    _buildNavItem(
                      index: 2,
                      label: 'Memories',
                      icon: Icons.photo_library,
                      isSelected: _currentIndex == 2,
                    ),
                    _buildNavItem(
                      index: 3,
                      label: 'Today',
                      icon: Icons.calendar_today,
                      isSelected: _currentIndex == 3,
                    ),
                  ],
                ),
              ),
              // Bottom Home Indicator Pill (134x5, #2C2523, radius 100)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final color = isSelected ? AppColors.coral : AppColors.textMuted;
    final fontWeight = isSelected ? FontWeight.w700 : FontWeight.w500;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.navLabel(color: color, weight: fontWeight),
            ),
          ],
        ),
      ),
    );
  }
}
