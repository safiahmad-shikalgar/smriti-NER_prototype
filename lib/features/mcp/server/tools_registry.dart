import '../../../data/repositories/reminder_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/repositories/sync_repository.dart';
import '../../../models/memory.dart';
import '../models/mcp_tool.dart';

class SmritiMcpTools {
  static McpTool getToday(ReminderRepository reminderRepository) {
    return McpTool(
      name: 'getToday',
      description: "Get today's water intake and general status.",
      inputSchema: {
        'type': 'object',
        'properties': {},
      },
      handler: (arguments) async {
        final reminders = await reminderRepository.getAllReminders();
        final waterReminder = reminders.where((r) => r.type == 'water').toList();

        if (waterReminder.isEmpty) {
          return 'No water tracker is set up. You can set one up in the Today screen.';
        }

        final water = waterReminder.first;
        final consumed = water.completedCount;
        final target = water.targetCount > 0 ? water.targetCount : 2000;
        final remaining = (target - consumed).clamp(0, target);

        if (remaining == 0) {
          return 'You have reached your water goal of $target millilitres today!';
        }
        return 'You have drunk $consumed millilitres. $remaining millilitres left to reach your goal of $target.';
      },
    );
  }

  static McpTool getMedicine(ReminderRepository reminderRepository) {
    return McpTool(
      name: 'getMedicine',
      description: "Get today's medicine schedule and status.",
      inputSchema: {
        'type': 'object',
        'properties': {},
      },
      handler: (arguments) async {
        final reminders = await reminderRepository.getAllReminders();
        final medicines = reminders.where((r) => r.type == 'medicine' && r.isActive).toList();

        if (medicines.isEmpty) {
          return 'You have no medicines scheduled for today.';
        }

        final pending = medicines.where((r) => !r.isCompleted).toList();
        if (pending.isEmpty) {
          return 'All ${medicines.length} medicine(s) for today are done.';
        }

        final names = pending.map((r) => r.title).join(', ');
        return 'You have ${pending.length} medicine(s) left: $names.';
      },
    );
  }

  static McpTool markMedicineDone(ReminderRepository reminderRepository) {
    return McpTool(
      name: 'markMedicineDone',
      description: 'Mark the next pending medicine as done.',
      inputSchema: {
        'type': 'object',
        'properties': {},
      },
      handler: (arguments) async {
        final reminders = await reminderRepository.getAllReminders();
        final pending = reminders
            .where((r) => r.type == 'medicine' && r.isActive && !r.isCompleted)
            .toList();

        if (pending.isEmpty) {
          return 'All your medicines are already marked as done. Well done!';
        }

        final toMark = pending.first;
        final updated = toMark.copyWith(
          isCompleted: true,
          completedCount: toMark.completedCount + 1,
          lastCompletedAt: DateTime.now(),
        );
        await reminderRepository.updateReminder(updated);
        await reminderRepository.logReminderAction(toMark.id, 'voice_marked_done');

        return 'I have marked ${toMark.title} as done.';
      },
    );
  }

  static McpTool remindMedicine(ReminderRepository reminderRepository) {
    return McpTool(
      name: 'remindMedicine',
      description: 'Log that the user wants to be reminded later for their medicine.',
      inputSchema: {
        'type': 'object',
        'properties': {},
      },
      handler: (arguments) async {
        final reminders = await reminderRepository.getAllReminders();
        final pending = reminders
            .where((r) => r.type == 'medicine' && r.isActive && !r.isCompleted)
            .toList();

        if (pending.isEmpty) {
          return 'You have no pending medicines to be reminded of.';
        }

        final toMark = pending.first;
        await reminderRepository.logReminderAction(toMark.id, 'reminded_later');

        return 'Okay, I will remind you about ${toMark.title} later.';
      },
    );
  }

  static McpTool getMemories(MemoryRepository memoryRepository) {
    return McpTool(
      name: 'getMemories',
      description: 'Get a list of saved memories and stories.',
      inputSchema: {
        'type': 'object',
        'properties': {},
      },
      handler: (arguments) async {
        final memories = await memoryRepository.getAllMemories();

        if (memories.isEmpty) {
          return 'You have no memories saved yet. You can add one from the Memories screen.';
        }

        final titles = memories.map((m) => m.title).join(', ');
        return 'You have ${memories.length} memor${memories.length == 1 ? "y" : "ies"}: $titles.';
      },
    );
  }

  static McpTool addMemory(MemoryRepository memoryRepository) {
    return McpTool(
      name: 'addMemory',
      description: 'Add a new memory.',
      inputSchema: {
        'type': 'object',
        'properties': {
          'title': {'type': 'string', 'description': 'Title of the memory'},
          'description': {'type': 'string', 'description': 'Description or story'},
        },
        'required': ['title'],
      },
      handler: (arguments) async {
        final title = arguments['title'] as String?;
        if (title == null || title.isEmpty) {
          throw Exception('Title is required to add a memory.');
        }
        
        final description = arguments['description'] as String? ?? '';
        
        final memory = Memory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          patientId: 'local_user', // Assuming default local patient
          title: title,
          description: description,
          photoPath: '', // Assuming no photo from voice for now
          dateDescription: 'Just now',
          createdAt: DateTime.now(),
        );
        
        await memoryRepository.insertMemory(memory);
        return 'I have saved the memory: $title.';
      },
    );
  }

  static McpTool startGame() {
    return McpTool(
      name: 'startGame',
      description: 'Start a cognitive recall game.',
      inputSchema: {
        'type': 'object',
        'properties': {},
      },
      handler: (arguments) async {
        return 'Starting Haat Bazaar...';
      },
    );
  }

  static McpTool caregiverSync(SyncRepository syncRepository) {
    return McpTool(
      name: 'caregiverSync',
      description: 'Force synchronization of data with caregiver via Supabase.',
      inputSchema: {
        'type': 'object',
        'properties': {},
      },
      handler: (arguments) async {
        final pending = await syncRepository.getPendingItems();
        if (pending.isEmpty) {
          return 'Your data is already synchronized with your caregiver.';
        }
        return 'I will synchronize ${pending.length} new items with your caregiver.';
      },
    );
  }
}
