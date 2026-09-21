import '../models/voice_intent.dart';

class IntentRecognizer {
  /// Basic regex-based intent recognition (placeholder for MCP/LLM integration later)
  VoiceIntent recognize(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('medicine') || lowerText.contains('pill') || lowerText.contains('medication')) {
      if (lowerText.contains('mark') || lowerText.contains('done') || lowerText.contains('took')) {
        return VoiceIntent(type: IntentType.markMedicineDone, originalText: text);
      }
      if (lowerText.contains('remind') || lowerText.contains('later')) {
        return VoiceIntent(type: IntentType.remindMedicine, originalText: text);
      }
      return VoiceIntent(type: IntentType.queryMedicines, originalText: text);
    }

    if (lowerText.contains('memory') || lowerText.contains('memories') || lowerText.contains('photo') || lowerText.contains('family')) {
      if (lowerText.contains('add') || lowerText.contains('new') || lowerText.contains('save')) {
        return VoiceIntent(
          type: IntentType.addMemory, 
          originalText: text, 
          parameters: {'title': text.replaceAll(RegExp(r'add|new|save|memory|memories|my', caseSensitive: false), '').trim()}
        );
      }
      return VoiceIntent(type: IntentType.showMemories, originalText: text);
    }

    if (lowerText.contains('game') || lowerText.contains('haat') || lowerText.contains('bazaar') || lowerText.contains('play')) {
      return VoiceIntent(type: IntentType.startHaatBazaar, originalText: text);
    }

    if (lowerText.contains('water') || lowerText.contains('drink') || lowerText.contains('glass') || lowerText.contains('today')) {
      return VoiceIntent(type: IntentType.queryWater, originalText: text);
    }

    if (lowerText.contains('sync') || lowerText.contains('caregiver')) {
      return VoiceIntent(type: IntentType.caregiverSync, originalText: text);
    }

    final cleanText = lowerText.replaceAll(RegExp(r'[^a-z]'), '');
    if (cleanText == 'yes' || cleanText == 'yep' || cleanText == 'yeah' || cleanText == 'sure' || cleanText == 'ok' || cleanText == 'okay') {
      return VoiceIntent(type: IntentType.confirm, originalText: text);
    }

    if (cleanText == 'no' || cleanText == 'nope' || cleanText == 'cancel' || cleanText == 'stop') {
      return VoiceIntent(type: IntentType.cancel, originalText: text);
    }

    return VoiceIntent(type: IntentType.unknown, originalText: text);
  }
}
