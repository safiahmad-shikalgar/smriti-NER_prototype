enum GameType { haatBazaarRecall, loomPatternWeaver, surTaalEcho }

enum GameDifficulty { easy, normal, hard }

class GameSession {
  final String id;
  final String patientId;
  final String gameType; // 'haat_bazaar_recall'
  final int totalRounds;
  final int completedRounds;
  final int correctRounds;
  final double accuracyPercentage;
  final int totalDurationMs;
  final String startingDifficulty;
  final String finalDifficulty;
  final bool completed;
  final DateTime startedAt;
  final DateTime? completedAt;

  GameSession({
    required this.id,
    required this.patientId,
    required this.gameType,
    required this.totalRounds,
    required this.completedRounds,
    required this.correctRounds,
    required this.accuracyPercentage,
    required this.totalDurationMs,
    required this.startingDifficulty,
    required this.finalDifficulty,
    required this.completed,
    required this.startedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'game_type': gameType,
      'total_rounds': totalRounds,
      'completed_rounds': completedRounds,
      'correct_rounds': correctRounds,
      'accuracy_percentage': accuracyPercentage,
      'total_duration_ms': totalDurationMs,
      'starting_difficulty': startingDifficulty,
      'final_difficulty': finalDifficulty,
      'completed': completed ? 1 : 0,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] as String,
      patientId: map['patient_id'] as String? ?? 'default_patient',
      gameType: map['game_type'] as String? ?? 'haat_bazaar_recall',
      totalRounds: map['total_rounds'] as int? ?? 3,
      completedRounds: map['completed_rounds'] as int? ?? 0,
      correctRounds: map['correct_rounds'] as int? ?? 0,
      accuracyPercentage:
          (map['accuracy_percentage'] as num?)?.toDouble() ?? 0.0,
      totalDurationMs: map['total_duration_ms'] as int? ?? 0,
      startingDifficulty: map['starting_difficulty'] as String? ?? 'normal',
      finalDifficulty: map['final_difficulty'] as String? ?? 'normal',
      completed: (map['completed'] as int? ?? 0) == 1,
      startedAt:
          DateTime.tryParse(map['started_at'] as String? ?? '') ??
          DateTime.now(),
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
    );
  }
}
