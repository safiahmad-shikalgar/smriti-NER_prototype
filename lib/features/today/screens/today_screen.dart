import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/reminder.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../widgets/mati_speak_button.dart';
import '../../haat_bazaar/screens/haat_bazaar_screen.dart';
import '../widgets/medicine_card.dart';
import '../widgets/water_tracker_card.dart';
import '../widgets/activity_card.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final ReminderRepository _reminderRepository = ReminderRepository();
  List<Reminder> _reminders = [
    Reminder(
      id: 'rem_med_01',
      patientId: 'patient_aai_01',
      title: 'Blue tablet',
      subtitle: '(Aparna) Blood Pressure Medicine',
      scheduledTime: '10:00 AM',
      type: 'medicine',
      targetCount: 1,
      completedCount: 0,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Reminder(
      id: 'rem_water_01',
      patientId: 'patient_aai_01',
      title: 'Drink Warm Water',
      subtitle: 'Stay hydrated throughout the day',
      scheduledTime: 'All Day',
      type: 'water',
      targetCount: 6,
      completedCount: 3,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Reminder(
      id: 'rem_act_01',
      patientId: 'patient_aai_01',
      title: 'Play Haat Bazaar',
      subtitle: 'Memory practice with familiar market goods',
      scheduledTime: '11:30 AM',
      type: 'cognitive',
      targetCount: 1,
      completedCount: 1,
      isCompleted: true,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final list = await _reminderRepository.getAllReminders();
      if (mounted && list.isNotEmpty) {
        setState(() {
          _reminders = list;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleMedicineAction(Reminder reminder, bool isDone) async {
    final updated = reminder.copyWith(
      isCompleted: isDone,
      lastCompletedAt: isDone ? DateTime.now() : null,
    );
    try {
      await _reminderRepository.updateReminder(updated);
      await _reminderRepository.logReminderAction(
        reminder.id,
        isDone ? 'medicine_taken' : 'reminded_later',
      );
    } catch (_) {}
    _loadReminders();
  }

  Future<void> _handleWaterCountChanged(
    Reminder waterReminder,
    int newCount,
  ) async {
    final updated = waterReminder.copyWith(
      completedCount: newCount,
      isCompleted: newCount >= waterReminder.targetCount,
      lastCompletedAt: DateTime.now(),
    );
    try {
      await _reminderRepository.updateReminder(updated);
    } catch (_) {}
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    final medReminder = _reminders.firstWhere(
      (r) => r.type == 'medicine',
      orElse:
          () => Reminder(
            id: 'rem_med',
            patientId: 'patient_aai_01',
            title: 'Blue tablet',
            subtitle: '(Aparna) Blood Pressure Medicine',
            scheduledTime: '10:00 AM',
            type: 'medicine',
            createdAt: DateTime.now(),
          ),
    );

    final waterReminder = _reminders.firstWhere(
      (r) => r.type == 'water',
      orElse:
          () => Reminder(
            id: 'rem_water',
            patientId: 'patient_aai_01',
            title: 'Drink Warm Water',
            subtitle: 'Stay hydrated throughout the day',
            scheduledTime: 'All Day',
            type: 'water',
            targetCount: 6,
            completedCount: 3,
            createdAt: DateTime.now(),
          ),
    );

    final activityReminder = _reminders.firstWhere(
      (r) => r.type == 'cognitive',
      orElse:
          () => Reminder(
            id: 'rem_act',
            patientId: 'patient_aai_01',
            title: 'Play Haat Bazaar',
            subtitle: 'Memory practice with familiar market goods',
            scheduledTime: '11:30 AM',
            type: 'cognitive',
            createdAt: DateTime.now(),
          ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Today / Aji', style: AppTypography.headingLarge()),
                  const MatiSpeakButton(
                    textToSpeak:
                        "Today's Guide. Here is your medicine, water, and activity schedule.",
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your gentle daily routine & care schedule',
                style: AppTypography.bodyMedium(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Medicine Card
              MedicineCard(
                reminder: medReminder,
                onAction:
                    (isDone) => _handleMedicineAction(medReminder, isDone),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Water Tracker Card
              WaterTrackerCard(
                waterReminder: waterReminder,
                onCountChanged:
                    (count) => _handleWaterCountChanged(waterReminder, count),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Activity Card
              ActivityCard(
                activityReminder: activityReminder,
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HaatBazaarScreen()),
                  ).then((_) => _loadReminders());
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
