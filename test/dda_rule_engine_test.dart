import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mvp_new/models/game_round.dart';
import 'package:smriti_mvp_new/services/dda/rule_based_difficulty_engine.dart';

void main() {
  group('RuleBasedDifficultyEngine Tests', () {
    late RuleBasedDifficultyEngine engine;

    setUp(() {
      engine = RuleBasedDifficultyEngine();
    });

    test('Evaluates smooth progress without difficulty intervention', () {
      final result = engine.evaluateDifficulty(
        currentDifficulty: 'normal',
        recentRounds: [],
        recentInteractions: [],
        currentLatencyMs: 3500,
        currentTapCount: 3,
        isCurrentRoundCorrect: true,
      );

      expect(result.shouldIntervene, isFalse);
      expect(result.signalScore, lessThan(0.65));
      expect(result.triggerReason, equals('smooth_progress'));
    });

    test('Triggers supportive intervention on high latency spike and incorrect choice', () {
      final result = engine.evaluateDifficulty(
        currentDifficulty: 'normal',
        recentRounds: [],
        recentInteractions: [],
        currentLatencyMs: 18000, // 18 seconds (high latency)
        currentTapCount: 2,
        isCurrentRoundCorrect: false, // incorrect choice
      );

      expect(result.shouldIntervene, isTrue);
      expect(result.recommendedDifficulty, equals('easy'));
      expect(result.signalScore, greaterThanOrEqualTo(0.65));
    });

    test('Triggers supportive intervention on rapid erratic tapping', () {
      final result = engine.evaluateDifficulty(
        currentDifficulty: 'hard',
        recentRounds: [],
        recentInteractions: [],
        currentLatencyMs: 5000,
        currentTapCount: 8, // rapid tapping >= 7
        isCurrentRoundCorrect: false,
      );

      expect(result.shouldIntervene, isTrue);
      expect(result.recommendedDifficulty, equals('normal'));
    });

    test('Triggers supportive intervention on consecutive errors', () {
      final prevRound = GameRound(
        id: 'r1',
        sessionId: 's1',
        roundIndex: 1,
        difficulty: 'normal',
        targetObjectCount: 3,
        targetObjectsJson: '[]',
        presentedOptionsJson: '[]',
        selectedOptionsJson: '[]',
        isCorrect: false,
        responseLatencyMs: 5000,
        hesitationMs: 2000,
        tapCount: 2,
        retryCount: 0,
        createdAt: DateTime.now(),
      );

      final result = engine.evaluateDifficulty(
        currentDifficulty: 'normal',
        recentRounds: [prevRound],
        recentInteractions: [],
        currentLatencyMs: 4000,
        currentTapCount: 2,
        isCurrentRoundCorrect: false,
      );

      expect(result.shouldIntervene, isTrue);
      expect(result.triggerReason, equals('error_burst'));
      expect(result.recommendedDifficulty, equals('easy'));
    });
  });
}
