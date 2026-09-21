import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mvp_new/services/game/haat_bazaar_game_service.dart';
import 'package:smriti_mvp_new/data/repositories/game_repository.dart';
import 'package:smriti_mvp_new/services/dda/rule_based_difficulty_engine.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('HaatBazaarGameService Tests', () {
    late HaatBazaarGameService gameService;

    setUp(() {
      gameService = HaatBazaarGameService(
        gameRepository: GameRepository(),
        difficultyEngine: RuleBasedDifficultyEngine(),
      );
    });

    test('Initializes session with 3 rounds and default difficulty', () {
      gameService.startNewSession(startingDifficulty: 'normal');

      expect(gameService.currentSession.totalRounds, equals(3));
      expect(gameService.currentDifficulty, equals('normal'));
      expect(gameService.currentRoundNumber, equals(1));
      expect(gameService.completedRounds, isEmpty);
      expect(gameService.currentTargetItems.length, equals(3));
      expect(gameService.currentPresentedChoices.length, equals(6));
    });

    test('Adapts exposure duration based on difficulty level', () {
      gameService.startNewSession(startingDifficulty: 'easy');
      expect(gameService.exposureDurationSeconds, equals(5));

      gameService.startNewSession(startingDifficulty: 'normal');
      expect(gameService.exposureDurationSeconds, equals(3));

      gameService.startNewSession(startingDifficulty: 'hard');
      expect(gameService.exposureDurationSeconds, equals(2));
    });

    test('Tapping items toggles selection and updates selected list', () {
      gameService.startNewSession();
      final firstItem = gameService.currentPresentedChoices.first;

      expect(gameService.selectedItemIds.contains(firstItem.id), isFalse);

      gameService.recordTap(firstItem.id);
      expect(gameService.selectedItemIds.contains(firstItem.id), isTrue);

      gameService.recordTap(firstItem.id);
      expect(gameService.selectedItemIds.contains(firstItem.id), isFalse);
    });

    test('Evaluates correct answer when all target items are selected', () async {
      gameService.startNewSession(startingDifficulty: 'easy');
      
      // Select all target items
      for (final target in gameService.currentTargetItems) {
        gameService.recordTap(target.id);
      }

      final result = await gameService.evaluateAnswer();
      expect(result.isCorrect, isTrue);
      expect(result.feedbackMessage, contains('Wonderful'));
      expect(gameService.completedRounds.length, equals(1));
      expect(gameService.completedRounds.first.isCorrect, isTrue);
    });

    test('Evaluates incorrect answer and triggers DDA engine check', () async {
      gameService.startNewSession(startingDifficulty: 'normal');

      // Intentionally select nothing (wrong answer)
      final result = await gameService.evaluateAnswer();
      expect(result.isCorrect, isFalse);
      expect(result.feedbackMessage, contains('try again'));
      expect(gameService.completedRounds.length, equals(1));
      expect(gameService.completedRounds.first.isCorrect, isFalse);
    });

    test('Advances rounds up to totalRounds and finalizes session', () async {
      gameService.startNewSession(startingDifficulty: 'easy');

      // Round 1
      for (final target in gameService.currentTargetItems) {
        gameService.recordTap(target.id);
      }
      var eval = await gameService.evaluateAnswer();
      expect(eval.isLastRound, isFalse);
      gameService.advanceToNextRound();
      expect(gameService.currentRoundNumber, equals(2));

      // Round 2
      for (final target in gameService.currentTargetItems) {
        gameService.recordTap(target.id);
      }
      eval = await gameService.evaluateAnswer();
      expect(eval.isLastRound, isFalse);
      gameService.advanceToNextRound();
      expect(gameService.currentRoundNumber, equals(3));

      // Round 3
      for (final target in gameService.currentTargetItems) {
        gameService.recordTap(target.id);
      }
      eval = await gameService.evaluateAnswer();
      expect(eval.isLastRound, isTrue); // All 3 rounds done

      final finalSession = await gameService.finalizeSession();
      expect(finalSession.completed, isTrue);
      expect(finalSession.completedRounds, equals(3));
      expect(finalSession.correctRounds, equals(3));
      expect(finalSession.accuracyPercentage, equals(100.0));
    });
  });
}
