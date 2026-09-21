import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/reminder.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../data/repositories/settings_repository.dart';

class WaterTrackerBottomSheet extends StatefulWidget {
  final Reminder waterReminder;
  final VoidCallback onUpdated;

  const WaterTrackerBottomSheet({
    super.key,
    required this.waterReminder,
    required this.onUpdated,
  });

  @override
  State<WaterTrackerBottomSheet> createState() => _WaterTrackerBottomSheetState();
}

class _WaterTrackerBottomSheetState extends State<WaterTrackerBottomSheet> {
  final _reminderRepo = ReminderRepository();
  final _settingsRepo = SettingsRepository();
  
  late Reminder _currentReminder;
  int _targetMl = 2000;
  int _glassMl = 250;
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _currentReminder = widget.waterReminder;
    _loadData();
  }

  Future<void> _loadData() async {
    final targetStr = await _settingsRepo.getSetting('water_target_ml');
    final glassStr = await _settingsRepo.getSetting('water_glass_ml');
    final logs = await _reminderRepo.getReminderLogs(_currentReminder.id);
    
    // Daily Reset Logic
    final now = DateTime.now();
    final lastAt = _currentReminder.lastCompletedAt;
    if (lastAt != null && (lastAt.year != now.year || lastAt.month != now.month || lastAt.day != now.day)) {
      _currentReminder = _currentReminder.copyWith(
        completedCount: 0,
        lastCompletedAt: now,
      );
      await _reminderRepo.updateReminder(_currentReminder);
    }

    if (mounted) {
      setState(() {
        _targetMl = int.tryParse(targetStr ?? '') ?? 2000;
        _glassMl = int.tryParse(glassStr ?? '') ?? 250;
        // Only show logs from today
        _logs = logs.where((log) {
          final logDate = DateTime.tryParse(log['logged_at'] as String? ?? '');
          if (logDate == null) return false;
          return logDate.year == now.year && logDate.month == now.month && logDate.day == now.day;
        }).toList();
      });
    }
  }

  Future<void> _addWater(int amount) async {
    final newCount = _currentReminder.completedCount + amount;
    _currentReminder = _currentReminder.copyWith(
      completedCount: newCount,
      targetCount: _targetMl,
      lastCompletedAt: DateTime.now(),
    );
    await _reminderRepo.updateReminder(_currentReminder);
    await _reminderRepo.logReminderAction(_currentReminder.id, 'add_$amount');
    widget.onUpdated();
    _loadData();
  }

  Future<void> _undoLatest() async {
    if (_logs.isEmpty) return;
    final latestLog = _logs.first;
    final action = latestLog['action_taken'] as String;
    if (action.startsWith('add_')) {
      final amount = int.tryParse(action.substring(4)) ?? 0;
      final newCount = (_currentReminder.completedCount - amount).clamp(0, 99999);
      _currentReminder = _currentReminder.copyWith(
        completedCount: newCount,
        lastCompletedAt: DateTime.now(),
      );
      await _reminderRepo.updateReminder(_currentReminder);
      await _reminderRepo.deleteReminderLog(latestLog['id'] as String);
      widget.onUpdated();
      _loadData();
    }
  }

  Future<void> _showSettingsDialog() async {
    final targetController = TextEditingController(text: _targetMl.toString());
    final glassController = TextEditingController(text: _glassMl.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Water Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Daily Target (ml)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: glassController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Glass Size (ml)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTarget = int.tryParse(targetController.text) ?? 2000;
              final newGlass = int.tryParse(glassController.text) ?? 250;
              await _settingsRepo.setSetting('water_target_ml', newTarget.toString());
              await _settingsRepo.setSetting('water_glass_ml', newGlass.toString());
              
              _currentReminder = _currentReminder.copyWith(targetCount: newTarget);
              await _reminderRepo.updateReminder(_currentReminder);
              
              if (context.mounted) {
                Navigator.pop(context);
              }
              if (mounted) {
                _loadData();
                widget.onUpdated();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomAddDialog() async {
    final customController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Amount'),
        content: TextField(
          controller: customController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (ml)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(customController.text);
              if (val != null && val > 0) {
                Navigator.pop(context);
                _addWater(val);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = _currentReminder.completedCount;
    final remaining = (_targetMl - completed).clamp(0, 99999);
    final progress = _targetMl > 0 ? (completed / _targetMl).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hydration Tracker', style: AppTypography.headingLarge()),
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.textMuted),
                onPressed: _showSettingsDialog,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${completed}ml / ${_targetMl}ml',
                style: AppTypography.headingMedium(color: AppColors.activeBlue),
              ),
              if (remaining > 0)
                Text(
                  '${remaining}ml remaining',
                  style: AppTypography.bodyMedium(color: AppColors.textMuted),
                )
              else
                Text(
                  'Goal Reached! 🎉',
                  style: AppTypography.bodyMedium(color: Colors.green),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.activeBlue.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.activeBlue),
              minHeight: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _addWater(_glassMl),
                icon: const Icon(Icons.local_drink),
                label: Text('+ $_glassMl ml'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showCustomAddDialog,
                icon: const Icon(Icons.add),
                label: const Text('Custom'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.activeBlue,
                  side: const BorderSide(color: AppColors.activeBlue),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          if (_logs.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Today\'s Log', style: AppTypography.headingSmall()),
                TextButton.icon(
                  onPressed: _undoLatest,
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Undo Last'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.coral),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  final action = log['action_taken'] as String;
                  final amount = action.startsWith('add_') ? action.substring(4) : '?';
                  final date = DateTime.tryParse(log['logged_at'] as String? ?? '');
                  final timeStr = date != null ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}' : '';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.water_drop, color: AppColors.activeBlue),
                    title: Text('Added $amount ml'),
                    trailing: Text(timeStr, style: AppTypography.bodySmall(color: AppColors.textMuted)),
                  );
                },
              ),
            ),
          ] else ...[
            const Spacer(),
          ]
        ],
      ),
    );
  }
}
