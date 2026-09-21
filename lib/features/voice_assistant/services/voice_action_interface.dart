/// Abstract interface for voice command actions.
/// This interface is the seam point for future MCP integration.
/// MCP can provide an implementation that calls remote tools instead of local repos.
abstract class VoiceActionInterface {
  /// Returns a human-readable description of today's medicine reminders.
  Future<String> queryMedicines();

  /// Marks the next pending medicine as done.
  /// Returns a human-readable confirmation or error message.
  Future<String> markMedicineDone();

  /// Returns a human-readable description of today's water intake progress.
  Future<String> queryWater();

  /// Logs that the user wants to be reminded later.
  Future<String> remindMedicine();

  /// Returns a list of saved memories.
  Future<String> getMemories();

  /// Adds a new memory.
  Future<String> addMemory(String title, String description);

  /// Starts the game.
  Future<String> startGame();

  /// Triggers a caregiver sync.
  Future<String> caregiverSync();
}
