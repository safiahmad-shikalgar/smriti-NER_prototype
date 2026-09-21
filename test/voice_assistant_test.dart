import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mvp_new/features/voice_assistant/models/voice_intent.dart';
import 'package:smriti_mvp_new/features/voice_assistant/services/intent_recognizer.dart';
import 'package:smriti_mvp_new/features/voice_assistant/services/voice_action_executor.dart';
import 'package:smriti_mvp_new/features/voice_assistant/services/voice_action_interface.dart';

// Stub implementation of VoiceActionInterface for unit testing.
// This also demonstrates how MCP will replace the local handler.
class StubVoiceActionHandler implements VoiceActionInterface {
  final String medicineResponse;
  final String markDoneResponse;
  final String waterResponse;

  const StubVoiceActionHandler({
    this.medicineResponse = 'You have 2 medicines left today.',
    this.markDoneResponse = 'Medicine marked as done.',
    this.waterResponse = 'You have drunk 500 ml today.',
  });

  @override
  Future<String> queryMedicines() async => medicineResponse;

  @override
  Future<String> markMedicineDone() async => markDoneResponse;

  @override
  Future<String> queryWater() async => waterResponse;
}

void main() {
  group('IntentRecognizer', () {
    final recognizer = IntentRecognizer();

    test('recognizes query medicines intent', () {
      final intent = recognizer.recognize('What medicines do I have?');
      expect(intent.type, IntentType.queryMedicines);
      expect(intent.originalText, 'What medicines do I have?');
    });

    test('recognizes mark medicine done intent', () {
      expect(recognizer.recognize('mark my medicine as done').type, IntentType.markMedicineDone);
      expect(recognizer.recognize('I took my pill').type, IntentType.markMedicineDone);
    });

    test('recognizes show memories intent', () {
      expect(recognizer.recognize('Show my memories').type, IntentType.showMemories);
      expect(recognizer.recognize('Open family photos').type, IntentType.showMemories);
    });

    test('recognizes start Haat Bazaar intent', () {
      expect(recognizer.recognize('Start Haat Bazaar').type, IntentType.startHaatBazaar);
      expect(recognizer.recognize('I want to play a game').type, IntentType.startHaatBazaar);
    });

    test('recognizes query water intent', () {
      expect(recognizer.recognize('How much water did I drink?').type, IntentType.queryWater);
      expect(recognizer.recognize('Show my water glass count').type, IntentType.queryWater);
    });

    test('returns unknown for unrecognized text', () {
      expect(recognizer.recognize('what is the weather today').type, IntentType.unknown);
      expect(recognizer.recognize('').type, IntentType.unknown);
    });
  });

  group('VoiceActionExecutor with StubHandler', () {
    final executor = VoiceActionExecutor(actionHandler: const StubVoiceActionHandler());

    test('queryMedicines returns stub response', () async {
      final result = await executor.execute(
        const VoiceIntent(type: IntentType.queryMedicines, originalText: 'medicines'),
      );
      expect(result.success, isTrue);
      expect(result.responseMessage, 'You have 2 medicines left today.');
    });

    test('markMedicineDone returns stub response', () async {
      final result = await executor.execute(
        const VoiceIntent(type: IntentType.markMedicineDone, originalText: 'mark done'),
      );
      expect(result.success, isTrue);
      expect(result.responseMessage, 'Medicine marked as done.');
    });

    test('queryWater returns stub response', () async {
      final result = await executor.execute(
        const VoiceIntent(type: IntentType.queryWater, originalText: 'water'),
      );
      expect(result.success, isTrue);
      expect(result.responseMessage, 'You have drunk 500 ml today.');
    });

    test('showMemories returns navigation result', () async {
      final result = await executor.execute(
        const VoiceIntent(type: IntentType.showMemories, originalText: 'memories'),
      );
      expect(result.success, isTrue);
      expect(result.responseMessage, 'Opening your memories.');
    });

    test('startHaatBazaar returns navigation result', () async {
      final result = await executor.execute(
        const VoiceIntent(type: IntentType.startHaatBazaar, originalText: 'play'),
      );
      expect(result.success, isTrue);
      expect(result.responseMessage, 'Starting Haat Bazaar.');
    });

    test('unknown intent returns helpful message', () async {
      final result = await executor.execute(
        const VoiceIntent(type: IntentType.unknown, originalText: 'gibberish'),
      );
      expect(result.success, isFalse);
      expect(result.responseMessage, contains('did not understand'));
    });
  });

  group('Full pipeline: recognize → execute', () {
    final recognizer = IntentRecognizer();
    final executor = VoiceActionExecutor(actionHandler: const StubVoiceActionHandler());

    test('"What medicines do I have?" → correct response', () async {
      final intent = recognizer.recognize('What medicines do I have?');
      final result = await executor.execute(intent);
      expect(result.responseMessage, 'You have 2 medicines left today.');
    });

    test('"Mark my medicine as done" → correct response', () async {
      final intent = recognizer.recognize('Mark my medicine as done');
      final result = await executor.execute(intent);
      expect(result.responseMessage, 'Medicine marked as done.');
    });

    test('"How much water did I drink?" → correct response', () async {
      final intent = recognizer.recognize('How much water did I drink?');
      final result = await executor.execute(intent);
      expect(result.responseMessage, 'You have drunk 500 ml today.');
    });

    test('"Show my memories" → navigation result', () async {
      final intent = recognizer.recognize('Show my memories');
      final result = await executor.execute(intent);
      expect(result.responseMessage, 'Opening your memories.');
    });

    test('"Start Haat Bazaar" → navigation result', () async {
      final intent = recognizer.recognize('Start Haat Bazaar');
      final result = await executor.execute(intent);
      expect(result.responseMessage, 'Starting Haat Bazaar.');
    });
  });
}
