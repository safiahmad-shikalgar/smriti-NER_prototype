import '../models/voice_intent.dart';
import 'voice_action_interface.dart';
import 'local_voice_action_handler.dart';

class ExecutionResult {
  final String responseMessage;
  final bool success;

  /// Optional navigation action — caller is responsible for executing this
  /// with a valid BuildContext so we never cross async gaps here.
  final void Function()? navigationAction;

  const ExecutionResult({
    required this.responseMessage,
    this.success = true,
    this.navigationAction,
  });
}

/// Executes a [VoiceIntent] by delegating to [VoiceActionInterface].
///
/// Navigation intents return a [navigationAction] callback; the caller
/// (the UI layer) executes it with a valid BuildContext.
/// This keeps the service layer free of BuildContext entirely.
///
/// To switch to MCP: inject an [McpVoiceActionHandler] instead of
/// [LocalVoiceActionHandler] at construction time.
class VoiceActionExecutor {
  final VoiceActionInterface _actionHandler;

  VoiceActionExecutor({VoiceActionInterface? actionHandler})
      : _actionHandler = actionHandler ?? LocalVoiceActionHandler();

  Future<ExecutionResult> execute(VoiceIntent intent) async {
    switch (intent.type) {
      case IntentType.queryMedicines:
        final message = await _actionHandler.queryMedicines();
        return ExecutionResult(responseMessage: message);

      case IntentType.markMedicineDone:
        final message = await _actionHandler.markMedicineDone();
        return ExecutionResult(responseMessage: message);

      case IntentType.queryWater:
        final message = await _actionHandler.queryWater();
        return ExecutionResult(responseMessage: message);

      case IntentType.showMemories:
        return const ExecutionResult(
          responseMessage: 'Opening your memories.',
          navigationAction: null, // UI fills this in via onNavigate callback
        );

      case IntentType.startHaatBazaar:
        return const ExecutionResult(
          responseMessage: 'Starting Haat Bazaar.',
          navigationAction: null, // UI fills this in via onNavigate callback
        );

      case IntentType.unknown:
        return const ExecutionResult(
          responseMessage:
              'I did not understand that. Try asking about medicines, water, memories, or games.',
          success: false,
        );
    }
  }
}
