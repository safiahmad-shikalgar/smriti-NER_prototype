import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mvp_new/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite FFI for the test environment (no native platform channel)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('SmritiApp renders Home and bottom navigation properly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmritiApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Header Greetings
    expect(find.text('Namaskar, Aai'), findsOneWidget);
    expect(find.text('Shall we spend a little time together?'), findsOneWidget);

    // Verify Action Cards
    expect(find.text("Let's Play"), findsWidgets);
    expect(find.text("My Memories"), findsWidgets);
    expect(find.text("Today's Guide"), findsOneWidget);

    // Verify Navigation Bar Labels
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Memories'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);

    // Switch to Play tab
    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('HAAT BAZAAR RECALL'), findsOneWidget);
    expect(find.text('LOOM PATTERN WEAVER'), findsOneWidget);
    expect(find.text('SUR-TAAL ECHO'), findsOneWidget);

    // Switch to Memories tab
    await tester.tap(find.text('Memories'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('My Family'), findsOneWidget);
    expect(find.text('Photo Album'), findsOneWidget);

    // Switch to Today tab
    await tester.tap(find.text('Today'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('MEDICINE TIME'), findsOneWidget);
    expect(find.text('STAY HYDRATED'), findsOneWidget);
    expect(find.text('ACTIVITY TIME'), findsOneWidget);
  });
}
