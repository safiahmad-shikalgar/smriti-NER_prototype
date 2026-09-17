class InteractionEvent {
  final String id;
  final String sessionId;
  final String roundId;
  final String
  eventType; // 'tap', 'hesitation', 'choice_toggle', 'retry', 'error'
  final int timestampMs;
  final String? payloadJson;
  final DateTime createdAt;

  InteractionEvent({
    required this.id,
    required this.sessionId,
    required this.roundId,
    required this.eventType,
    required this.timestampMs,
    this.payloadJson,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'round_id': roundId,
      'event_type': eventType,
      'timestamp_ms': timestampMs,
      'payload_json': payloadJson,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InteractionEvent.fromMap(Map<String, dynamic> map) {
    return InteractionEvent(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      roundId: map['round_id'] as String,
      eventType: map['event_type'] as String,
      timestampMs: map['timestamp_ms'] as int? ?? 0,
      payloadJson: map['payload_json'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
