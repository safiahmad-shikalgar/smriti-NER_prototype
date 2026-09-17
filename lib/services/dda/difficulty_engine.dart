import '../../models/game_round.dart';
import '../../models/interaction_event.dart';

class DifficultySignalResult {
  final double signalScore; // 0.0 to 1.0
  final bool shouldIntervene;
  final String recommendedDifficulty; // 'easy', 'normal', 'hard'
  final String triggerReason; // 'error_burst', 'latency_spike', 'rapid_tapping', 'smooth_progress'

  const DifficultySignalResult({
    required this.signalScore,
    required this.shouldIntervene,
    required this.recommendedDifficulty,
    required this.triggerReason,
  });
}

abstract class DifficultyEngine {
  DifficultySignalResult evaluateDifficulty({
    required String currentDifficulty,
    required List<GameRound> recentRounds,
    required List<InteractionEvent> recentInteractions,
    required int currentLatencyMs,
    required int currentTapCount,
    required bool isCurrentRoundCorrect,
  });
}
