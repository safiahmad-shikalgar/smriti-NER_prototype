import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../core/constants/asset_paths.dart';
import '../../models/game_round.dart';
import '../../models/game_session.dart';
import '../../models/interaction_event.dart';
import '../../models/difficulty_event.dart';
import '../../data/repositories/game_repository.dart';
import '../dda/difficulty_engine.dart';
import '../dda/rule_based_difficulty_engine.dart';

class MarketItem {
  final String id;
  final String name;
  final String assetPath;
  final String assameseName;

  const MarketItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.assameseName,
  });
}

class HaatBazaarGameService {
  static const List<MarketItem> availableItems = [
    MarketItem(
      id: 'assam_tea',
      name: 'Assam Tea',
      assetPath: AssetPaths.assamTea,
      assameseName: 'অসম চাহ (Assam Sah)',
    ),
    MarketItem(
      id: 'bhut_jolokia',
      name: 'Bhut Jolokia',
      assetPath: AssetPaths.bhutJolokia,
      assameseName: 'ভোট জলকীয়া (Bhut Jolokia)',
    ),
    MarketItem(
      id: 'bamboo_shoots',
      name: 'Bamboo Shoots',
      assetPath: AssetPaths.bambooShoots,
      assameseName: 'বাঁহ গাজ (Khorisa / Bah Gaaj)',
    ),
    MarketItem(
      id: 'raw_turmeric',
      name: 'Raw Turmeric',
      assetPath: AssetPaths.rawTurmeric,
      assameseName: 'কেঁচা হালধি (Kesa Halodhi)',
    ),
  ];

  final GameRepository _gameRepository;
  final DifficultyEngine _difficultyEngine;
  final _uuid = const Uuid();

  // Active Session State
  late GameSession _currentSession;
  late String _currentDifficulty;
  int _currentRoundNumber = 1;
  final List<GameRound> _completedRounds = [];
  final List<InteractionEvent> _currentRoundInteractions = [];

  // Active Round State
  late String _currentRoundId;
  List<MarketItem> _currentTargetItems = [];
  List<MarketItem> _currentPresentedChoices = [];
  final Set<String> _selectedItemIds = {};
  late DateTime _roundStartTime;
  int _roundTapCount = 0;
  int _roundRetryCount = 0;

  HaatBazaarGameService({
    GameRepository? gameRepository,
    DifficultyEngine? difficultyEngine,
  }) : _gameRepository = gameRepository ?? GameRepository(),
       _difficultyEngine = difficultyEngine ?? RuleBasedDifficultyEngine();

  GameSession get currentSession => _currentSession;
  String get currentDifficulty => _currentDifficulty;
  int get currentRoundNumber => _currentRoundNumber;
  List<MarketItem> get currentTargetItems => _currentTargetItems;
  List<MarketItem> get currentPresentedChoices => _currentPresentedChoices;
  Set<String> get selectedItemIds => _selectedItemIds;
  List<GameRound> get completedRounds => _completedRounds;

  int get exposureDurationSeconds {
    switch (_currentDifficulty) {
      case 'easy':
        return 5;
      case 'hard':
        return 2;
      case 'normal':
      default:
        return 3;
    }
  }

  void startNewSession({String startingDifficulty = 'normal'}) {
    final sessionId = _uuid.v4();
    _currentDifficulty = startingDifficulty;
    _currentRoundNumber = 1;
    _completedRounds.clear();
    _currentRoundInteractions.clear();

    _currentSession = GameSession(
      id: sessionId,
      patientId: 'patient_aai_01',
      gameType: 'haat_bazaar_recall',
      totalRounds: 3,
      completedRounds: 0,
      correctRounds: 0,
      accuracyPercentage: 0.0,
      totalDurationMs: 0,
      startingDifficulty: startingDifficulty,
      finalDifficulty: startingDifficulty,
      completed: false,
      startedAt: DateTime.now(),
    );

    _prepareRound(_currentRoundNumber, _currentDifficulty);
  }

  void _prepareRound(int roundNumber, String difficulty) {
    _currentRoundId = _uuid.v4();
    _selectedItemIds.clear();
    _currentRoundInteractions.clear();
    _roundTapCount = 0;
    _roundRetryCount = 0;
    _roundStartTime = DateTime.now();

    final random = Random();
    final shuffled = List<MarketItem>.from(availableItems)..shuffle(random);

    int targetCount = 3;
    int choiceCount = 4;

    if (difficulty == 'easy') {
      targetCount = 2;
      choiceCount = 3;
    } else if (difficulty == 'hard') {
      targetCount = 4;
      choiceCount = 4;
    }

    _currentTargetItems = shuffled.take(targetCount).toList();

    // Ensure choices contain all target items plus distractors
    final targetIds = _currentTargetItems.map((e) => e.id).toSet();
    final remainingItems =
        availableItems.where((i) => !targetIds.contains(i.id)).toList()
          ..shuffle(random);

    final choices = List<MarketItem>.from(_currentTargetItems);
    for (final item in remainingItems) {
      if (choices.length < choiceCount) {
        choices.add(item);
      }
    }
    choices.shuffle(random);
    _currentPresentedChoices = choices;
  }

  void recordTap(String itemId) {
    _roundTapCount++;
    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
    } else {
      _selectedItemIds.add(itemId);
    }

    final event = InteractionEvent(
      id: _uuid.v4(),
      sessionId: _currentSession.id,
      roundId: _currentRoundId,
      eventType: 'tap',
      timestampMs: DateTime.now().difference(_roundStartTime).inMilliseconds,
      payloadJson: jsonEncode({
        'item_id': itemId,
        'selected': _selectedItemIds.contains(itemId),
      }),
      createdAt: DateTime.now(),
    );

    _currentRoundInteractions.add(event);
    _gameRepository.saveInteractionEvent(event);
  }

  Future<EvaluationResult> evaluateAnswer() async {
    final now = DateTime.now();
    final latencyMs = now.difference(_roundStartTime).inMilliseconds;

    final targetIds = _currentTargetItems.map((e) => e.id).toSet();
    final isCorrect =
        targetIds.length == _selectedItemIds.length &&
        _selectedItemIds.every((id) => targetIds.contains(id));

    final round = GameRound(
      id: _currentRoundId,
      sessionId: _currentSession.id,
      roundIndex: _currentRoundNumber,
      difficulty: _currentDifficulty,
      targetObjectCount: _currentTargetItems.length,
      targetObjectsJson: jsonEncode(
        _currentTargetItems.map((e) => e.name).toList(),
      ),
      presentedOptionsJson: jsonEncode(
        _currentPresentedChoices.map((e) => e.name).toList(),
      ),
      selectedOptionsJson: jsonEncode(_selectedItemIds.toList()),
      isCorrect: isCorrect,
      responseLatencyMs: latencyMs,
      hesitationMs: max(0, latencyMs - 3000),
      tapCount: _roundTapCount,
      retryCount: _roundRetryCount,
      createdAt: now,
    );

    _completedRounds.add(round);
    await _gameRepository.saveGameRound(round);

    // Run DDA Engine evaluation
    final ddaResult = _difficultyEngine.evaluateDifficulty(
      currentDifficulty: _currentDifficulty,
      recentRounds: _completedRounds,
      recentInteractions: _currentRoundInteractions,
      currentLatencyMs: latencyMs,
      currentTapCount: _roundTapCount,
      isCurrentRoundCorrect: isCorrect,
    );

    // If difficulty changes or intervention triggered, persist difficulty event
    if (ddaResult.shouldIntervene ||
        ddaResult.recommendedDifficulty != _currentDifficulty) {
      final diffEvent = DifficultyEvent(
        id: _uuid.v4(),
        sessionId: _currentSession.id,
        previousDifficulty: _currentDifficulty,
        newDifficulty: ddaResult.recommendedDifficulty,
        triggerReason: ddaResult.triggerReason,
        difficultySignal: ddaResult.signalScore,
        supportiveInterventionShown: ddaResult.shouldIntervene,
        patientAction: ddaResult.shouldIntervene
            ? 'intervention_shown'
            : 'auto_adjusted',
        createdAt: now,
      );
      await _gameRepository.saveDifficultyEvent(diffEvent);
    }

    final oldDifficulty = _currentDifficulty;
    _currentDifficulty = ddaResult.recommendedDifficulty;

    return EvaluationResult(
      isCorrect: isCorrect,
      feedbackMessage: isCorrect
          ? 'Wonderful! You remembered it.'
          : "That's okay. Let's try again.",
      shouldIntervene: ddaResult.shouldIntervene,
      previousDifficulty: oldDifficulty,
      newDifficulty: ddaResult.recommendedDifficulty,
      isLastRound: _currentRoundNumber >= _currentSession.totalRounds,
    );
  }

  void applyInterventionChoice({
    required bool takeBreak,
    required bool reduceDifficulty,
  }) {
    if (reduceDifficulty) {
      _currentDifficulty = 'easy';
    }
  }

  void advanceToNextRound() {
    if (_currentRoundNumber < _currentSession.totalRounds) {
      _currentRoundNumber++;
      _prepareRound(_currentRoundNumber, _currentDifficulty);
    }
  }

  Future<GameSession> finalizeSession() async {
    final now = DateTime.now();
    final correctCount = _completedRounds.where((r) => r.isCorrect).length;
    final totalRounds = _completedRounds.length;
    final accuracy = totalRounds > 0
        ? (correctCount / totalRounds) * 100.0
        : 0.0;
    final totalDuration = now
        .difference(_currentSession.startedAt)
        .inMilliseconds;

    final updatedSession = GameSession(
      id: _currentSession.id,
      patientId: _currentSession.patientId,
      gameType: _currentSession.gameType,
      totalRounds: _currentSession.totalRounds,
      completedRounds: totalRounds,
      correctRounds: correctCount,
      accuracyPercentage: accuracy,
      totalDurationMs: totalDuration,
      startingDifficulty: _currentSession.startingDifficulty,
      finalDifficulty: _currentDifficulty,
      completed: true,
      startedAt: _currentSession.startedAt,
      completedAt: now,
    );

    _currentSession = updatedSession;
    await _gameRepository.saveGameSession(updatedSession);
    return updatedSession;
  }
}

class EvaluationResult {
  final bool isCorrect;
  final String feedbackMessage;
  final bool shouldIntervene;
  final String previousDifficulty;
  final String newDifficulty;
  final bool isLastRound;

  const EvaluationResult({
    required this.isCorrect,
    required this.feedbackMessage,
    required this.shouldIntervene,
    required this.previousDifficulty,
    required this.newDifficulty,
    required this.isLastRound,
  });
}
