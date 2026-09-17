class GameRound {
  final String id;
  final String sessionId;
  final int roundIndex;
  final String difficulty;
  final int targetObjectCount;
  final String targetObjectsJson;
  final String presentedOptionsJson;
  final String selectedOptionsJson;
  final bool isCorrect;
  final int responseLatencyMs;
  final int hesitationMs;
  final int tapCount;
  final int retryCount;
  final DateTime createdAt;

  GameRound({
    required this.id,
    required this.sessionId,
    required this.roundIndex,
    required this.difficulty,
    required this.targetObjectCount,
    required this.targetObjectsJson,
    required this.presentedOptionsJson,
    required this.selectedOptionsJson,
    required this.isCorrect,
    required this.responseLatencyMs,
    required this.hesitationMs,
    required this.tapCount,
    required this.retryCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'round_index': roundIndex,
      'difficulty': difficulty,
      'target_object_count': targetObjectCount,
      'target_objects_json': targetObjectsJson,
      'presented_options_json': presentedOptionsJson,
      'selected_options_json': selectedOptionsJson,
      'is_correct': isCorrect ? 1 : 0,
      'response_latency_ms': responseLatencyMs,
      'hesitation_ms': hesitationMs,
      'tap_count': tapCount,
      'retry_count': retryCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GameRound.fromMap(Map<String, dynamic> map) {
    return GameRound(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      roundIndex: map['round_index'] as int? ?? 1,
      difficulty: map['difficulty'] as String? ?? 'normal',
      targetObjectCount: map['target_object_count'] as int? ?? 3,
      targetObjectsJson: map['target_objects_json'] as String? ?? '[]',
      presentedOptionsJson: map['presented_options_json'] as String? ?? '[]',
      selectedOptionsJson: map['selected_options_json'] as String? ?? '[]',
      isCorrect: (map['is_correct'] as int? ?? 0) == 1,
      responseLatencyMs: map['response_latency_ms'] as int? ?? 0,
      hesitationMs: map['hesitation_ms'] as int? ?? 0,
      tapCount: map['tap_count'] as int? ?? 0,
      retryCount: map['retry_count'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
