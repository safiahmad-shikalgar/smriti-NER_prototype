import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smriti_mvp_new/features/auth/screens/login_screen.dart';
import 'package:smriti_mvp_new/features/auth/screens/auth_wrapper.dart';
import 'package:smriti_mvp_new/services/auth/auth_service.dart';

class MockAuthService extends AuthService {
  MockAuthService() : super.test();

  bool shouldThrow = false;
  bool isNetworkError = false;
  String errorMsg = '';
  Duration delayDuration = Duration.zero;
  
  bool _isLoggedIn = false;
  final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();
  
  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    if (delayDuration != Duration.zero) {
      await Future.delayed(delayDuration);
    }
    if (shouldThrow) {
      if (isNetworkError) {
        throw Exception(errorMsg);
      }
      throw AuthException(errorMsg);
    }
    _isLoggedIn = true;
    _authStateController.add(AuthState(AuthChangeEvent.signedIn, currentSession));
    return AuthResponse(session: currentSession, user: currentUser);
  }

  @override
  Future<AuthResponse> signUp({required String email, required String password}) async {
    if (delayDuration != Duration.zero) {
      await Future.delayed(delayDuration);
    }
    if (shouldThrow) {
      if (isNetworkError) {
        throw Exception(errorMsg);
      }
      throw AuthException(errorMsg);
    }
    _isLoggedIn = true;
    _authStateController.add(AuthState(AuthChangeEvent.signedIn, currentSession));
    return AuthResponse(session: currentSession, user: currentUser);
  }

  @override
  Future<void> signOut() async {
    _isLoggedIn = false;
    _authStateController.add(AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  Session? get currentSession => _isLoggedIn 
    ? Session(
        accessToken: 'fake_token',
        tokenType: 'bearer',
        user: currentUser!,
      ) 
    : null;

  @override
  User? get currentUser => _isLoggedIn 
    ? User(
        id: 'fake_id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      )
    : null;

  @override
  Stream<AuthState> get authStateChanges => _authStateController.stream;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    AuthService.instance = MockAuthService();
  });

  testWidgets('Login screen rendering (default create account mode)', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to SMRITI'), findsOneWidget);
    expect(find.text('Create your account to get started.'), findsOneWidget);
    expect(find.text('Gmail Address'), findsOneWidget);
    expect(find.text('Create SMRITI-NER Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('Toggle to Sign In mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    final toggleBtn = find.text('Already have an account? Sign In');
    await tester.ensureVisible(toggleBtn);
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    expect(find.text('Please sign in to continue.'), findsOneWidget);
    expect(find.text('SMRITI-NER Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsNothing);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Empty email validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    final toggleBtn = find.text('Already have an account? Sign In');
    await tester.ensureVisible(toggleBtn);
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    final submitBtn = find.text('Sign In');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email.'), findsOneWidget);
  });

  testWidgets('Invalid email validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
    
    final submitBtn = find.text('Create Account');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });

  testWidgets('Empty password validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    final toggleBtn = find.text('Already have an account? Sign In');
    await tester.ensureVisible(toggleBtn);
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    
    final submitBtn = find.text('Sign In');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a password.'), findsOneWidget);
  });

  testWidgets('Password validation passes with input in login mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    final toggleBtn = find.text('Already have an account? Sign In');
    await tester.ensureVisible(toggleBtn);
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    
    final submitBtn = find.text('Sign In');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump(); // Start loading
    
    // Validation messages should not be present
    expect(find.text('Please enter a password.'), findsNothing);
  });

  testWidgets('Password mismatch validation in signup mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
    
    final submitBtn = find.text('Create Account');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  testWidgets('Invalid credentials display error message', (WidgetTester tester) async {
    final mockAuth = AuthService.instance as MockAuthService;
    mockAuth.shouldThrow = true;
    mockAuth.errorMsg = 'Invalid login credentials';

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    final toggleBtn = find.text('Already have an account? Sign In');
    await tester.ensureVisible(toggleBtn);
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
    
    final submitBtn = find.text('Sign In');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Invalid login credentials'), findsOneWidget);
  });

  testWidgets('Network/authentication failure display generic error', (WidgetTester tester) async {
    final mockAuth = AuthService.instance as MockAuthService;
    mockAuth.shouldThrow = true;
    mockAuth.isNetworkError = true;
    mockAuth.errorMsg = 'Database connection not available.';

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    final toggleBtn = find.text('Already have an account? Sign In');
    await tester.ensureVisible(toggleBtn);
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
    
    final submitBtn = find.text('Sign In');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Database connection not available.'), findsOneWidget);
  });

  testWidgets('Successful login triggers loading state', (WidgetTester tester) async {
    final mockAuth = AuthService.instance as MockAuthService;
    mockAuth.delayDuration = const Duration(milliseconds: 500); // Simulate network delay
    
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    final toggleBtn = find.text('Already have an account? Sign In');
    await tester.ensureVisible(toggleBtn);
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    
    final submitBtn = find.text('Sign In');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump(); // Trigger setState

    // Should show loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sign In'), findsNothing); // Button is replaced by loader
    
    await tester.pumpAndSettle(const Duration(seconds: 1)); // Finish delay
    expect(mockAuth.currentSession, isNotNull); // Verification it logged in
  });

  testWidgets('Logged-out navigation protection (AuthWrapper shows Login)', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthWrapper()));
    await tester.pumpAndSettle();
    
    // AuthWrapper should render LoginScreen
    expect(find.text('Welcome to SMRITI'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Session restoration / Logged-in navigation routes away from Login', (WidgetTester tester) async {
    final mockAuth = AuthService.instance as MockAuthService;
    await mockAuth.signIn(email: 'a', password: 'b'); // Pre-authenticate
    
    await tester.pumpWidget(const MaterialApp(home: AuthWrapper()));
    await tester.pump(const Duration(seconds: 2));
    
    // Should NOT be on Login Screen
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('Logout returns to Login Screen', (WidgetTester tester) async {
    final mockAuth = AuthService.instance as MockAuthService;
    await mockAuth.signIn(email: 'a', password: 'b'); // Pre-authenticate
    
    await tester.pumpWidget(const MaterialApp(home: AuthWrapper()));
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(LoginScreen), findsNothing);
    
    // Trigger logout
    await mockAuth.signOut();
    await tester.pump(const Duration(seconds: 2));
    
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
