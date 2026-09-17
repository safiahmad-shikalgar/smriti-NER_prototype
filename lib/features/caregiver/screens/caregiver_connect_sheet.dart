import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/status_pill.dart';
import '../../../services/caregiver/caregiver_service.dart';

class CaregiverConnectSheet extends StatefulWidget {
  const CaregiverConnectSheet({super.key});

  @override
  State<CaregiverConnectSheet> createState() => _CaregiverConnectSheetState();
}

class _CaregiverConnectSheetState extends State<CaregiverConnectSheet> {
  final CaregiverService _caregiverService = CaregiverService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _caregiverService.loadPairing();
  }

  void _triggerSync() async {
    setState(() => _isLoading = true);
    await _caregiverService.triggerManualSync();
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed. Data safely updated.'),
          backgroundColor: AppColors.deepTeal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Connect Caregiver', style: AppTypography.headingMedium()),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Share this pairing code with your family or caregiver',
              style: AppTypography.bodyMedium(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.warmPaleCoral,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.coral, width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    'Pairing Code',
                    style: AppTypography.bodySmall(
                      color: AppColors.coral,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SelectableText(
                    AppConstants.caregiverPairingCode,
                    style: AppTypography.displayLarge(color: AppColors.coral),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const StatusPill(
                    text: 'Connected to Aparna',
                    icon: Icons.check_circle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Cloud Sync',
                  style: AppTypography.bodyMedium(weight: FontWeight.w600),
                ),
                Text(
                  _caregiverService.syncService.lastSyncStatus,
                  style: AppTypography.bodySmall(color: AppColors.sageGreen),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: _isLoading ? 'Syncing...' : 'Sync Now',
              icon: Icons.sync,
              onPressed: _isLoading ? null : _triggerSync,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
