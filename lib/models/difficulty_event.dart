class DifficultyEvent {
  final String id;
  final String sessionId;
  final String previousDifficulty;
  final String newDifficulty;
  final String triggerReason; // 'error_burst', 'latency_spike', 'rapid_tapping', 'smooth_progress'
  final double difficultySignal;
  final bool supportiveInterventionShown;
  final String? patientAction; // 'break_taken', 'continued', 'auto_adjusted'
  final DateTime createdAt;

  DifficultyEvent({
    required this.id,
    required this.sessionId,
    required this.previousDifficulty,
    required this.newDifficulty,
    required this.triggerReason,
    required this.difficultySignal,
    required this.supportiveInterventionShown,
    this.patientAction,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'previous_difficulty': previousDifficulty,
      'new_difficulty': newDifficulty,
      'trigger_reason': triggerReason,
      'difficulty_signal': difficultySignal,
      'supportive_intervention_shown': supportiveInterventionShown ? 1 : 0,
      'patient_action': patientAction,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DifficultyEvent.fromMap(Map<String, dynamic> map) {
    return DifficultyEvent(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      previousDifficulty: map['previous_difficulty'] as String? ?? 'normal',
      newDifficulty: map['new_difficulty'] as String? ?? 'easy',
      triggerReason: map['trigger_reason'] as String? ?? 'adaptive',
      difficultySignal: (map['difficulty_signal'] as num?)?.toDouble() ?? 0.0,
      supportiveInterventionShown:
          (map['supportive_intervention_shown'] as int? ?? 0) == 1,
      patientAction: map['patient_action'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
