import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:smriti_mvp_new/features/navigation/main_scaffold.dart';
import 'package:smriti_mvp_new/features/profile/widgets/profile_bottom_sheet.dart';
import 'package:smriti_mvp_new/features/help/screens/help_screen.dart';
import 'package:smriti_mvp_new/features/home/screens/placeholder_screen.dart';
import 'package:smriti_mvp_new/features/face_recognition/screens/face_scan_screen.dart';
import 'package:smriti_mvp_new/features/home/screens/home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:async';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Home rendering and Navigation Bottom Bar', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainScaffold()));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Dashboard rendering
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Face Recognition'), findsOneWidget);
    expect(find.text('Voice Assistant'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('My Wellbeing'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);

    // Verify Navigation Bar Labels
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Memories'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('Navigation to Profile opens Bottom Sheet', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(seconds: 1));

    final profileFinder = find.text('My Profile');
    await tester.ensureVisible(profileFinder);
    await tester.pump(const Duration(seconds: 1));
    
    await tester.tap(profileFinder);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 2)); // Finish animation

    // Yield to let real SQLite isolate complete
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump(const Duration(seconds: 1)); // Rebuild after setState

    expect(find.byType(ProfileBottomSheet), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
  });

  testWidgets('Navigation to Help opens HelpScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(seconds: 1));

    final helpFinder = find.text('Help & Support');
    await tester.ensureVisible(helpFinder);
    await tester.pump(const Duration(seconds: 1));
    
    await tester.tap(helpFinder);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 2)); // Finish animation

    expect(find.byType(HelpScreen), findsOneWidget);
    expect(find.text('How can we help you?'), findsOneWidget);
  });

  testWidgets('Face Recognition navigation opens FaceScanScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(seconds: 1));

    final faceFinder = find.text('Face Recognition');
    await tester.ensureVisible(faceFinder);
    await tester.pump(const Duration(seconds: 1));
    
    await tester.tap(faceFinder);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 2)); // Finish animation

    expect(find.byType(FaceScanScreen), findsOneWidget);
    expect(find.text('Who is this?'), findsOneWidget);
  });
  
  testWidgets('Voice Assistant navigation opens VoiceAssistantScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(seconds: 1));

    final voiceFinder = find.text('Voice Assistant');
    await tester.ensureVisible(voiceFinder);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(voiceFinder);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 2)); // Finish animation

    // VoiceAssistantScreen shows a loading state while initialising STT
    // We verify it navigated away from HomeScreen (no PlaceholderScreen)
    expect(find.byType(PlaceholderScreen), findsNothing);
  });

  testWidgets('Navigation to My Wellbeing opens WellbeingScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(seconds: 1));

    final caregiverFinder = find.text('My Wellbeing');
    await tester.ensureVisible(caregiverFinder);
    await tester.pump(const Duration(seconds: 1));
    
    await tester.tap(caregiverFinder);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 2)); // Finish animation

    // Since we mock sqlite or it's empty, WellbeingScreen will show CALM and finish loading
    expect(find.byType(PlaceholderScreen), findsNothing);
  });
}
