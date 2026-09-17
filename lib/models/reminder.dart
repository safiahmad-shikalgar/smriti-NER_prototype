enum ReminderType { medicine, water, routine, cognitive }

class Reminder {
  final String id;
  final String patientId;
  final String title;
  final String subtitle;
  final String scheduledTime; // e.g. "10:00 AM"
  final String type; // 'medicine', 'water', 'routine', 'cognitive'
  final int targetCount; // e.g. 6 glasses
  final int completedCount; // e.g. 3 completed
  final bool isCompleted;
  final DateTime? lastCompletedAt;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.patientId,
    required this.title,
    required this.subtitle,
    required this.scheduledTime,
    required this.type,
    this.targetCount = 1,
    this.completedCount = 0,
    this.isCompleted = false,
    this.lastCompletedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'title': title,
      'subtitle': subtitle,
      'scheduled_time': scheduledTime,
      'type': type,
      'target_count': targetCount,
      'completed_count': completedCount,
      'is_completed': isCompleted ? 1 : 0,
      'last_completed_at': lastCompletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      patientId: map['patient_id'] as String? ?? 'default_patient',
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      scheduledTime: map['scheduled_time'] as String? ?? '',
      type: map['type'] as String? ?? 'routine',
      targetCount: map['target_count'] as int? ?? 1,
      completedCount: map['completed_count'] as int? ?? 0,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      lastCompletedAt: map['last_completed_at'] != null
          ? DateTime.tryParse(map['last_completed_at'] as String)
          : null,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Reminder copyWith({
    String? title,
    String? subtitle,
    String? scheduledTime,
    String? type,
    int? targetCount,
    int? completedCount,
    bool? isCompleted,
    DateTime? lastCompletedAt,
  }) {
    return Reminder(
      id: id,
      patientId: patientId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      type: type ?? this.type,
      targetCount: targetCount ?? this.targetCount,
      completedCount: completedCount ?? this.completedCount,
      isCompleted: isCompleted ?? this.isCompleted,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      createdAt: createdAt,
    );
  }
}
