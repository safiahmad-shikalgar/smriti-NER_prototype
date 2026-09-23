import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'data/database/app_database.dart';
import 'data/local/seed_data.dart';
import 'data/remote/supabase_service.dart';
import 'services/notifications/notification_service.dart';
import 'services/tts/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // 1. Initialize SQLite local database and seed demo data on first launch
  try {
    final db = await AppDatabase.instance.database;
    await SeedData.seedIfEmpty(db);
  } catch (e) {
    debugPrint('Database initialization warning: $e');
  }

  // 2. Initialize local notifications
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Notification service initialization warning: $e');
  }

  // 3. Initialize TTS helper
  try {
    await TtsService.instance.initialize();
  } catch (e) {
    debugPrint('TTS initialization warning: $e');
  }

  // 4. Initialize Supabase synchronization client
  try {
    await SupabaseService.instance.initialize();
  } catch (e) {
    debugPrint('Supabase initialization warning: $e');
  }

  runApp(const SmritiApp());
}
