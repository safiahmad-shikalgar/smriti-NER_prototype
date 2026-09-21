enum IntentType {
  unknown,
  queryMedicines,
  markMedicineDone,
  queryWater,
  showMemories,
  startHaatBazaar,
}

class VoiceIntent {
  final IntentType type;
  final String originalText;
  final Map<String, dynamic> parameters;

  const VoiceIntent({
    required this.type,
    required this.originalText,
    this.parameters = const {},
  });
}
