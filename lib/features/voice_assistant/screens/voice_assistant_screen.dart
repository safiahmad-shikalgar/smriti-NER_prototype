import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/voice_intent.dart';
import '../services/voice_assistant_service.dart';
import '../../memories/screens/memories_screen.dart';
import '../../haat_bazaar/screens/haat_bazaar_screen.dart';

import '../../mcp/services/mcp_setup.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late final VoiceAssistantService _voiceService;
  late final AnimationController _pulseController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Navigation intents delivered via callback — BuildContext is safe here
    _voiceService = VoiceAssistantService(
      actionHandler: McpSetup.createHandler(),
      onNavigate: _handleNavigationIntent,
    );

    _voiceService.addListener(_onServiceUpdate);
    _initService();
  }

  Future<void> _initService() async {
    await _voiceService.initialize();
    if (mounted) setState(() => _isInit = true);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _handleNavigationIntent(IntentType intent) {
    if (!mounted) return;
    switch (intent) {
      case IntentType.showMemories:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoriesScreen()));
        break;
      case IntentType.startHaatBazaar:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HaatBazaarScreen()));
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _voiceService.removeListener(_onServiceUpdate);
    _pulseController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  Color get _micColor {
    if (_voiceService.isListening) return AppColors.coral;
    if (_voiceService.isProcessing || _voiceService.isSpeaking) return Colors.orange;
    return AppColors.sageGreen;
  }

  IconData get _micIcon {
    if (_voiceService.isListening) return Icons.mic;
    if (_voiceService.isProcessing) return Icons.hourglass_bottom;
    if (_voiceService.isSpeaking) return Icons.volume_up;
    return Icons.mic_none;
  }

  String get _statusLabel {
    if (_voiceService.isListening) return 'Listening…';
    if (_voiceService.isProcessing) return 'Understanding…';
    if (_voiceService.isSpeaking) return 'Speaking…';
    if (!_voiceService.isAvailable) return 'Microphone unavailable';
    return 'Tap to speak';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Voice Assistant', style: AppTypography.headingMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: !_isInit
          ? const Center(child: CircularProgressIndicator(color: AppColors.sageGreen))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Assistant response ───────────────────────────────
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.self_improvement,
                                size: 48, color: AppColors.sageGreen.withValues(alpha: 0.5)),
                            const SizedBox(height: AppSpacing.xl),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _voiceService.assistantResponse.isNotEmpty
                                    ? _voiceService.assistantResponse
                                    : 'Hello! I am here to help.\nTap the button and speak.',
                                key: ValueKey(_voiceService.assistantResponse),
                                style: AppTypography.headingSmall(color: AppColors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (_voiceService.lastWords.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                '"${_voiceService.lastWords}"',
                                style: AppTypography.bodyMedium(
                                    color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ── Status label ─────────────────────────────────────
                    Text(
                      _statusLabel,
                      style: AppTypography.bodySmall(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Microphone button ────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (_voiceService.isListening) {
                            _voiceService.stopListening();
                          } else if (_voiceService.isSpeaking) {
                            _voiceService.stopSpeaking();
                          } else {
                            _voiceService.startListening();
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            final scale = _voiceService.isListening
                                ? 1.0 + _pulseController.value * 0.12
                                : 1.0;
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: _micColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _micColor.withValues(alpha: 0.4),
                                      blurRadius: _voiceService.isListening ? 24 : 8,
                                      spreadRadius: _voiceService.isListening ? 4 : 0,
                                    ),
                                  ],
                                ),
                                child: Icon(_micIcon, color: Colors.white, size: 44),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Hint chips ───────────────────────────────────────
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      alignment: WrapAlignment.center,
                      children: [
                        _HintChip('"What medicines do I have?"'),
                        _HintChip('"Show my memories"'),
                        _HintChip('"How much water did I drink?"'),
                        _HintChip('"Start Haat Bazaar"'),
                        _HintChip('"Mark my medicine as done"'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final String label;
  const _HintChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.sageGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.sageGreen.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: AppTypography.bodySmall(color: AppColors.sageGreen),
          textAlign: TextAlign.center),
    );
  }
}
