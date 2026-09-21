import '../models/voice_intent.dart';

class IntentRecognizer {
  /// Basic regex-based intent recognition (placeholder for MCP/LLM integration later)
  VoiceIntent recognize(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('medicine') || lowerText.contains('pill') || lowerText.contains('medication')) {
      if (lowerText.contains('mark') || lowerText.contains('done') || lowerText.contains('took')) {
        return VoiceIntent(type: IntentType.markMedicineDone, originalText: text);
      }
      return VoiceIntent(type: IntentType.queryMedicines, originalText: text);
    }

    if (lowerText.contains('memory') || lowerText.contains('memories') || lowerText.contains('photo') || lowerText.contains('family')) {
      return VoiceIntent(type: IntentType.showMemories, originalText: text);
    }

    if (lowerText.contains('game') || lowerText.contains('haat') || lowerText.contains('bazaar') || lowerText.contains('play')) {
      return VoiceIntent(type: IntentType.startHaatBazaar, originalText: text);
    }

    if (lowerText.contains('water') || lowerText.contains('drink') || lowerText.contains('glass')) {
      return VoiceIntent(type: IntentType.queryWater, originalText: text);
    }

    return VoiceIntent(type: IntentType.unknown, originalText: text);
  }
}
