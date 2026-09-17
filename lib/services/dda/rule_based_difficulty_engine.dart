import '../../models/game_round.dart';
import '../../models/interaction_event.dart';
import 'difficulty_engine.dart';

class RuleBasedDifficultyEngine implements DifficultyEngine {
  // Thresholds calibrated for elderly interactions
  static const int highLatencyThresholdMs =
      12000; // >12 seconds indicates hesitation/difficulty
  static const int rapidTapThreshold =
      7; // Excessive erratic taps on choice buttons
  static const double interventionSignalThreshold =
      0.65; // Trigger intervention dialog

  @override
  DifficultySignalResult evaluateDifficulty({
    required String currentDifficulty,
    required List<GameRound> recentRounds,
    required List<InteractionEvent> recentInteractions,
    required int currentLatencyMs,
    required int currentTapCount,
    required bool isCurrentRoundCorrect,
  }) {
    double difficultyScore = 0.0;
    String triggerReason = 'smooth_progress';

    // 1. Error factor
    if (!isCurrentRoundCorrect) {
      difficultyScore += 0.40;
      triggerReason = 'incorrect_choice';
    }

    // Check consecutive errors in recent rounds
    final recentIncorrectCount = recentRounds.where((r) => !r.isCorrect).length;
    if (recentIncorrectCount >= 1 && !isCurrentRoundCorrect) {
      difficultyScore += 0.30;
      triggerReason = 'error_burst';
    }

    // 2. Latency / Hesitation factor
    if (currentLatencyMs > highLatencyThresholdMs) {
      final latencyExcess =
          ((currentLatencyMs - highLatencyThresholdMs) / 10000).clamp(
            0.0,
            0.35,
          );
      difficultyScore += latencyExcess;
      if (difficultyScore >= interventionSignalThreshold) {
        triggerReason = 'latency_spike';
      }
    }

    // 3. Repeated rapid tapping (frustration/confusion heuristic)
    if (currentTapCount >= rapidTapThreshold) {
      difficultyScore += 0.30;
      if (difficultyScore >= interventionSignalThreshold) {
        triggerReason = 'rapid_tapping';
      }
    }

    // Clamp score
    difficultyScore = difficultyScore.clamp(0.0, 1.0);

    // Determine difficulty transition
    String recommendedDifficulty = currentDifficulty;
    bool shouldIntervene = false;

    if (difficultyScore >= interventionSignalThreshold) {
      shouldIntervene = true;
      if (currentDifficulty == 'hard') {
        recommendedDifficulty = 'normal';
      } else if (currentDifficulty == 'normal') {
        recommendedDifficulty = 'easy';
      } else {
        recommendedDifficulty = 'easy';
      }
    } else if (difficultyScore < 0.20 &&
        isCurrentRoundCorrect &&
        recentIncorrectCount == 0) {
      // Gentle progression if doing very well without intervention
      if (currentDifficulty == 'easy') {
        recommendedDifficulty = 'normal';
      } else if (currentDifficulty == 'normal' && recentRounds.length >= 2) {
        recommendedDifficulty = 'hard';
      }
    }

    return DifficultySignalResult(
      signalScore: difficultyScore,
      shouldIntervene: shouldIntervene,
      recommendedDifficulty: recommendedDifficulty,
      triggerReason: triggerReason,
    );
  }
}
