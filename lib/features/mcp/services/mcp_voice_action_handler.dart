import '../../voice_assistant/services/voice_action_interface.dart';
import '../client/mcp_client.dart';

class McpVoiceActionHandler implements VoiceActionInterface {
  final McpClient _mcpClient;

  McpVoiceActionHandler(this._mcpClient);

  @override
  Future<String> queryMedicines() async {
    return await _mcpClient.callTool('getMedicine');
  }

  @override
  Future<String> markMedicineDone() async {
    return await _mcpClient.callTool('markMedicineDone');
  }

  @override
  Future<String> queryWater() async {
    return await _mcpClient.callTool('getToday');
  }

  @override
  Future<String> remindMedicine() async {
    return await _mcpClient.callTool('remindMedicine');
  }

  @override
  Future<String> getMemories() async {
    return await _mcpClient.callTool('getMemories');
  }

  @override
  Future<String> addMemory(String title, String description) async {
    return await _mcpClient.callTool('addMemory', {
      'title': title,
      'description': description,
    });
  }

  @override
  Future<String> startGame() async {
    return await _mcpClient.callTool('startGame');
  }

  @override
  Future<String> caregiverSync() async {
    return await _mcpClient.callTool('caregiverSync');
  }
}
