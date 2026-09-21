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
}
