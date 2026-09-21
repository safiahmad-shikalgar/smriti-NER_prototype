import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/voice_intent.dart';
import 'intent_recognizer.dart';
import 'voice_action_executor.dart';
import 'voice_action_interface.dart';

/// Central service for the Voice Assistant pipeline:
///   Microphone → STT → Intent → Action → TTS
///
/// [onNavigate] is a callback the UI registers to handle navigation intents.
/// This keeps BuildContext entirely in the UI layer.
class VoiceAssistantService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final IntentRecognizer _recognizer = IntentRecognizer();
  late final VoiceActionExecutor _executor;

  /// Called when a navigation intent is recognized.
  /// e.g. showMemories, startHaatBazaar
  final void Function(IntentType intent)? onNavigate;

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  String _lastWords = '';
  String _assistantResponse = '';
  bool _isAvailable = false;
  VoiceIntent? _pendingIntent;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isProcessing => _isProcessing;
  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;
  String get assistantResponse => _assistantResponse;

  VoiceAssistantService({
    VoiceActionInterface? actionHandler,
    this.onNavigate,
  }) {
    _executor = VoiceActionExecutor(actionHandler: actionHandler);
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _flutterTts.setErrorHandler((_) {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  /// Initializes speech recognition. Returns true if available.
  Future<bool> initialize() async {
    _isAvailable = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          if (_isListening) {
            _isListening = false;
            notifyListeners();
          }
        }
      },
      onError: (error) {
        _isListening = false;
        _assistantResponse = 'Sorry, I could not hear that. Please try again.';
        notifyListeners();
      },
    );
    notifyListeners();
    return _isAvailable;
  }

  Future<void> startListening() async {
    if (!_isAvailable) {
      _assistantResponse = 'Microphone not available. Please check permissions.';
      notifyListeners();
      return;
    }
    if (_speechToText.isListening) return;

    await _flutterTts.stop();
    _lastWords = '';
    _assistantResponse = 'Listening…';
    _isListening = true;
    _isProcessing = false;
    notifyListeners();

    await _speechToText.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        notifyListeners();

        if (result.finalResult && _lastWords.isNotEmpty) {
          _handleFinalResult(_lastWords);
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        cancelOnError: true,
      ),
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _isListening = false;
    notifyListeners();
  }

  Future<void> _handleFinalResult(String text) async {
    _isListening = false;
    _isProcessing = true;
    _assistantResponse = 'Understanding…';
    notifyListeners();

    final intent = _recognizer.recognize(text);

    if (_pendingIntent != null) {
      if (intent.type == IntentType.confirm) {
        final executeIntent = _pendingIntent!;
        _pendingIntent = null;
        await _executeAndSpeak(executeIntent);
      } else if (intent.type == IntentType.cancel) {
        _pendingIntent = null;
        _assistantResponse = 'Okay, cancelled.';
        _isProcessing = false;
        notifyListeners();
        await _speak(_assistantResponse);
      } else {
        _assistantResponse = 'Please say yes to confirm or no to cancel.';
        _isProcessing = false;
        notifyListeners();
        await _speak(_assistantResponse);
      }
      return;
    }

    if (intent.type == IntentType.markMedicineDone || intent.type == IntentType.addMemory) {
      _pendingIntent = intent;
      _assistantResponse = intent.type == IntentType.markMedicineDone 
          ? 'Are you sure you want to mark your medicine as done?' 
          : 'Are you sure you want to save this memory?';
      _isProcessing = false;
      notifyListeners();
      await _speak(_assistantResponse);
      return;
    }

    await _executeAndSpeak(intent);
  }

  Future<void> _executeAndSpeak(VoiceIntent intent) async {
    // Navigation intents are routed to the UI via callback — no BuildContext here
    if (intent.type == IntentType.showMemories ||
        intent.type == IntentType.startHaatBazaar) {
      final result = await _executor.execute(intent);
      _assistantResponse = result.responseMessage;
      _isProcessing = false;
      notifyListeners();
      await _speak(result.responseMessage);
      // Small delay so TTS can start before navigation happens
      await Future.delayed(const Duration(milliseconds: 600));
      onNavigate?.call(intent.type);
      return;
    }

    final result = await _executor.execute(intent);
    _assistantResponse = result.responseMessage;
    _isProcessing = false;
    notifyListeners();
    await _speak(result.responseMessage);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
