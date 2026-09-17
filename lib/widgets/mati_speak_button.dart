import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/tts/tts_service.dart';

class MatiSpeakButton extends StatefulWidget {
  final String textToSpeak;
  final String label;

  const MatiSpeakButton({
    super.key,
    required this.textToSpeak,
    this.label = 'Mati / Speak',
  });

  @override
  State<MatiSpeakButton> createState() => _MatiSpeakButtonState();
}

class _MatiSpeakButtonState extends State<MatiSpeakButton> {
  bool _isPlaying = false;

  void _toggleSpeak() async {
    if (_isPlaying) {
      await TtsService.instance.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await TtsService.instance.speak(widget.textToSpeak);
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleSpeak,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: ShapeDecoration(
            color: _isPlaying
                ? AppColors.warmPaleCoral
                : AppColors.surfaceWhite,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.coral, width: 1.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPlaying ? Icons.volume_up : Icons.mic_none,
                size: 20,
                color: AppColors.coral,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.label,
                style: AppTypography.bodySmall(
                  color: AppColors.coral,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
