import '../../../data/repositories/reminder_repository.dart';
import 'voice_action_interface.dart';

/// Local implementation of [VoiceActionInterface].
/// Uses existing [ReminderRepository] — does NOT duplicate business logic.
///
/// To integrate MCP later: implement [VoiceActionInterface] in a
/// McpVoiceActionHandler and inject it into [VoiceActionExecutor].
class LocalVoiceActionHandler implements VoiceActionInterface {
  final ReminderRepository _reminderRepository;

  LocalVoiceActionHandler({ReminderRepository? reminderRepository})
      : _reminderRepository = reminderRepository ?? ReminderRepository();

  @override
  Future<String> queryMedicines() async {
    final reminders = await _reminderRepository.getAllReminders();
    final medicines = reminders.where((r) => r.type == 'medicine' && r.isActive).toList();

    if (medicines.isEmpty) {
      return 'You have no medicines scheduled for today. Great!';
    }

    final pending = medicines.where((r) => !r.isCompleted).toList();
    if (pending.isEmpty) {
      return 'All ${medicines.length} medicine${medicines.length == 1 ? "" : "s"} for today are done. Well done!';
    }

    final names = pending.map((r) => r.title).join(', ');
    return 'You have ${pending.length} medicine${pending.length == 1 ? "" : "s"} left: $names.';
  }

  @override
  Future<String> markMedicineDone() async {
    final reminders = await _reminderRepository.getAllReminders();
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
    await _reminderRepository.updateReminder(updated);
    await _reminderRepository.logReminderAction(toMark.id, 'voice_marked_done');

    return 'I have marked ${toMark.title} as done.';
  }

  @override
  Future<String> queryWater() async {
    final reminders = await _reminderRepository.getAllReminders();
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
  }

  @override
  Future<String> remindMedicine() async {
    return 'I will remind you later.';
  }

  @override
  Future<String> getMemories() async {
    return 'Fetching your memories...';
  }

  @override
  Future<String> addMemory(String title, String description) async {
    return 'Adding memory...';
  }

  @override
  Future<String> startGame() async {
    return 'Starting game...';
  }

  @override
  Future<String> caregiverSync() async {
    return 'Syncing with caregiver...';
  }
}
