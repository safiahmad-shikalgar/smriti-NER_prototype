import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mvp_new/features/mcp/server/smriti_mcp_server.dart';
import 'package:smriti_mvp_new/features/mcp/client/mcp_client.dart';
import 'package:smriti_mvp_new/features/mcp/server/tools_registry.dart';
import 'package:smriti_mvp_new/data/repositories/reminder_repository.dart';
import 'package:smriti_mvp_new/models/reminder.dart';

// Stub repository for testing
class StubReminderRepository implements ReminderRepository {
  @override
  Future<List<Reminder>> getAllReminders() async {
    return [
      Reminder(
        id: '1',
        patientId: 'local_user',
        title: 'Water',
        subtitle: 'Drink water',
        type: 'water',
        scheduledTime: 'All Day',
        createdAt: DateTime.now(),
        isActive: true,
        targetCount: 2000,
        completedCount: 500,
      )
    ];
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('MCP Tool: getToday', () {
    test('Client requests getToday and gets correct water response', () async {
      final server = SmritiMcpServer();
      final stubRepo = StubReminderRepository();
      
      server.registerTool(SmritiMcpTools.getToday(stubRepo));
      
      final client = McpClient(server);
      
      final result = await client.callTool('getToday');
      expect(result, contains('drunk 500 millilitres'));
      expect(result, contains('1500 millilitres left'));
    });
  });
}
