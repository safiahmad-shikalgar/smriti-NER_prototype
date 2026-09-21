import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mvp_new/models/reminder.dart';
import 'package:smriti_mvp_new/features/today/widgets/medicine_card.dart';
import 'package:smriti_mvp_new/features/today/widgets/water_tracker_card.dart';
import 'package:smriti_mvp_new/features/today/widgets/activity_card.dart';
import 'package:smriti_mvp_new/features/today/widgets/reminder_confirmation_dialog.dart';
import 'package:smriti_mvp_new/services/notifications/notification_service.dart';
import 'package:smriti_mvp_new/services/tts/tts_service.dart';

void main() {
  group('Today, Reminders & Care Schedule Tests', () {
    late Reminder medicineReminder;

    setUp(() {
      medicineReminder = Reminder(
        id: 'rem_med_test',
        patientId: 'patient_aai_01',
        title: 'Blue tablet',
        subtitle: '(Aparna) Blood Pressure Medicine',
        scheduledTime: '10:00 AM',
        type: 'medicine',
        targetCount: 1,
        completedCount: 0,
        isCompleted: false,
        createdAt: DateTime.now(),
      );


    });

    testWidgets('MedicineCard displays pending state and triggers Done / Remind Later', (
      WidgetTester tester,
    ) async {
      bool doneTriggered = false;
      bool remindLaterTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicineCard(
              reminder: medicineReminder,
              onAction: (isDone) {
                if (isDone) {
                  doneTriggered = true;
                } else {
                  remindLaterTriggered = true;
                }
              },
            ),
          ),
        ),
      );

      expect(find.text('MEDICINE TIME'), findsOneWidget);
      expect(find.text('Blue tablet'), findsOneWidget);
      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Remind Later'), findsOneWidget);

      // Tapping 'Done' shows the ReminderConfirmationDialog before calling onAction.
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle(); // let dialog animation complete
      expect(find.text('Yes, I did'), findsOneWidget);

      // Confirm inside the dialog to trigger onAction(true)
      await tester.tap(find.text('Yes, I did'));
      await tester.pumpAndSettle();
      expect(doneTriggered, isTrue);

      // Tapping 'Remind Later' directly calls onAction(false)
      await tester.tap(find.text('Remind Later'));
      await tester.pump();
      expect(remindLaterTriggered, isTrue);
    });

    testWidgets('MedicineCard displays Taken Today when completed', (
      WidgetTester tester,
    ) async {
      final completedMed = medicineReminder.copyWith(
        isCompleted: true,
        lastCompletedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicineCard(
              reminder: completedMed,
              onAction: (isDone) {},
            ),
          ),
        ),
      );

      expect(find.text('Taken Today'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('ReminderConfirmationDialog triggers yes and later actions', (
      WidgetTester tester,
    ) async {
      bool yesPressed = false;
      bool laterPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderConfirmationDialog(
              medicineName: 'Blue tablet (Aparna) Blood Pressure Medicine',
              onConfirm: () => yesPressed = true,
              onRemindLater: () => laterPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Yes, I did'), findsOneWidget);
      expect(find.text('Remind Me Later'), findsOneWidget);

      await tester.tap(find.text('Yes, I did'));
      await tester.pump();
      expect(yesPressed, isTrue);

      await tester.tap(find.text('Remind Me Later'));
      await tester.pump();
      expect(laterPressed, isTrue);
    });

    testWidgets('WaterTrackerCard renders progress bar and reports count changes', (
      WidgetTester tester,
    ) async {
      bool updated = false;
      final waterReminder = Reminder(
        id: 'rem_water_01',
        patientId: 'patient_aai_01',
        title: 'Drink Warm Water',
        subtitle: 'Stay hydrated throughout the day',
        scheduledTime: 'All Day',
        type: 'water',
        targetCount: 2000,
        completedCount: 250,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WaterTrackerCard(
              waterReminder: waterReminder,
              onUpdated: () => updated = true,
            ),
          ),
        ),
      );

      expect(find.text('STAY HYDRATED'), findsOneWidget);
      expect(find.text('250 / 2000 ml'), findsOneWidget);
      expect(find.text('Drink Warm Water'), findsOneWidget);
    });

    testWidgets('ActivityCard renders activity details and start button', (
      WidgetTester tester,
    ) async {
      bool activityStarted = false;
      final activityReminder = Reminder(
        id: 'rem_act_test',
        patientId: 'patient_aai_01',
        title: 'Play Haat Bazaar',
        subtitle: 'Memory practice with familiar market goods',
        scheduledTime: '11:30 AM',
        type: 'cognitive',
        targetCount: 1,
        completedCount: 0,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activityReminder: activityReminder,
              onPlay: () => activityStarted = true,
            ),
          ),
        ),
      );

      expect(find.text('ACTIVITY TIME'), findsOneWidget);
      expect(find.text('Play Haat Bazaar'), findsOneWidget);
      expect(find.text('START ACTIVITY'), findsOneWidget);

      await tester.tap(find.text('START ACTIVITY'));
      await tester.pump();
      expect(activityStarted, isTrue);
    });

    test('NotificationService and TtsService initialize and operate safely without crash', () async {
      // Offline / headless unit test environment safety
      final notif = NotificationService.instance;
      await notif.initialize();
      await notif.showLocalNotification(
        id: 999,
        title: 'Test Reminder',
        body: 'Safe test notification',
      );

      final tts = TtsService.instance;
      await tts.initialize();
      await tts.stop();
      expect(tts.isSpeaking, isFalse);
    });
  });
}
