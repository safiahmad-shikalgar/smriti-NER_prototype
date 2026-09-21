import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/remote/supabase_service.dart';

class AuthService {
  static AuthService instance = AuthService._init();
  AuthService._init();
  @visibleForTesting
  AuthService.test();

  SupabaseClient? get _client => SupabaseService.instance.client;

  Future<AuthResponse> signIn({required String email, required String password}) async {
    if (_client == null) {
      throw Exception('Database connection not available. Please check network or configuration.');
    }
    return await _client!.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({required String email, required String password}) async {
    if (_client == null) {
      throw Exception('Database connection not available. Please check network or configuration.');
    }
    return await _client!.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }

  Session? get currentSession => _client?.auth.currentSession;
  
  User? get currentUser => _client?.auth.currentUser;
  
  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;
}
