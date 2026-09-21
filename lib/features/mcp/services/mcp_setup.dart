import '../../../data/repositories/reminder_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/repositories/sync_repository.dart';
import '../client/mcp_client.dart';
import '../server/smriti_mcp_server.dart';
import '../server/tools_registry.dart';
import 'mcp_voice_action_handler.dart';

class McpSetup {
  static McpVoiceActionHandler createHandler() {
    final server = SmritiMcpServer();
    
    final reminderRepo = ReminderRepository();
    final memoryRepo = MemoryRepository();
    final syncRepo = SyncRepository();

    server.registerTool(SmritiMcpTools.getToday(reminderRepo));
    server.registerTool(SmritiMcpTools.getMedicine(reminderRepo));
    server.registerTool(SmritiMcpTools.markMedicineDone(reminderRepo));
    server.registerTool(SmritiMcpTools.remindMedicine(reminderRepo));
    server.registerTool(SmritiMcpTools.getMemories(memoryRepo));
    server.registerTool(SmritiMcpTools.addMemory(memoryRepo));
    server.registerTool(SmritiMcpTools.startGame());
    server.registerTool(SmritiMcpTools.caregiverSync(syncRepo));

    final client = McpClient(server);
    return McpVoiceActionHandler(client);
  }
}
