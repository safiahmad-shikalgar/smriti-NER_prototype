import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  bool _isInitialized = false;

  SupabaseService._init();

  bool get isInitialized => _isInitialized;

  Future<void> initialize({String? url, String? anonKey}) async {
    final supabaseUrl =
        url ??
        const String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'https://placeholder.supabase.co',
        );
    final supabaseAnonKey =
        anonKey ??
        const String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue: 'placeholder-anon-key',
        );

    // Only attempt init if valid looking URL provided
    if (supabaseUrl.startsWith('http')) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
        _isInitialized = true;
      } catch (_) {
        _isInitialized = false;
      }
    }
  }

  SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
