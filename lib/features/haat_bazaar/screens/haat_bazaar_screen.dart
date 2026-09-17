import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/game/haat_bazaar_game_service.dart';
import '../../../services/tts/tts_service.dart';
import '../widgets/memory_phase_view.dart';
import '../widgets/recall_phase_view.dart';
import '../widgets/support_intervention_dialog.dart';
import '../widgets/round_summary_dialog.dart';

enum GamePhase { memory, recall }

class HaatBazaarScreen extends StatefulWidget {
  const HaatBazaarScreen({super.key});

  @override
  State<HaatBazaarScreen> createState() => _HaatBazaarScreenState();
}

class _HaatBazaarScreenState extends State<HaatBazaarScreen> {
  final HaatBazaarGameService _gameService = HaatBazaarGameService();
  GamePhase _currentPhase = GamePhase.memory;
  Timer? _countdownTimer;
  int _remainingSeconds = 3;
  int _totalExposureSeconds = 3;
  bool _isEvaluating = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  void _startSession() {
    _gameService.startNewSession();
    _startMemoryPhase();
  }

  void _startMemoryPhase() {
    setState(() {
      _currentPhase = GamePhase.memory;
      _totalExposureSeconds = _gameService.exposureDurationSeconds;
      _remainingSeconds = _totalExposureSeconds;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _currentPhase = GamePhase.recall;
        });
      }
    });
  }

  void _onItemTapped(String itemId) {
    setState(() {
      _gameService.recordTap(itemId);
    });
  }

  void _onSubmitRecall() async {
    if (_isEvaluating) return;
    setState(() => _isEvaluating = true);

    final result = await _gameService.evaluateAnswer();
    setState(() => _isEvaluating = false);

    if (!mounted) return;

    // Speak gentle feedback
    TtsService.instance.speak(result.feedbackMessage);

    // If DDA detected high difficulty signal -> display supportive intervention
    if (result.shouldIntervene) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SupportInterventionDialog(
          onKeepGoing: () {
            Navigator.pop(context);
            _gameService.applyInterventionChoice(
              takeBreak: false,
              reduceDifficulty: true,
            );
            _handleRoundTransition(result);
          },
          onTakeBreak: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Exit game safely
          },
        ),
      );
    } else {
      _handleRoundTransition(result);
    }
  }

  void _handleRoundTransition(EvaluationResult result) async {
    double? finalAcc;
    if (result.isLastRound) {
      final session = await _gameService.finalizeSession();
      finalAcc = session.accuracyPercentage;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RoundSummaryDialog(
        isCorrect: result.isCorrect,
        isLastRound: result.isLastRound,
        finalAccuracy: finalAcc,
        onNext: () {
          Navigator.pop(context);
          if (result.isLastRound) {
            Navigator.pop(context); // Return back to screen
          } else {
            _gameService.advanceToNextRound();
            _startMemoryPhase();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roundNumber = _gameService.currentRoundNumber;
    final totalRounds = _gameService.currentSession.totalRounds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Haat Bazaar Recall', style: AppTypography.headingMedium()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xxl),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warmPaleCoral,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: AppColors.coral, width: 1),
                ),
                child: Text(
                  'Round $roundNumber of $totalRounds',
                  style: AppTypography.bodySmall(
                    color: AppColors.coral,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          child: _currentPhase == GamePhase.memory
              ? MemoryPhaseView(
                  targetItems: _gameService.currentTargetItems,
                  remainingSeconds: _remainingSeconds,
                  totalSeconds: _totalExposureSeconds,
                )
              : RecallPhaseView(
                  choices: _gameService.currentPresentedChoices,
                  selectedItemIds: _gameService.selectedItemIds,
                  onItemTapped: _onItemTapped,
                  onSubmit: _onSubmitRecall,
                ),
        ),
      ),
    );
  }
}
