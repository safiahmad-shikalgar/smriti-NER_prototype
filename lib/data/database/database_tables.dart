class DatabaseTables {
  static const String patients = 'patients';
  static const String familyMembers = 'family_members';
  static const String memories = 'memories';
  static const String faceProfiles = 'face_profiles';
  static const String gameSessions = 'game_sessions';
  static const String gameRounds = 'game_rounds';
  static const String interactionEvents = 'interaction_events';
  static const String difficultyEvents = 'difficulty_events';
  static const String reminders = 'reminders';
  static const String reminderLogs = 'reminder_logs';
  static const String syncQueue = 'sync_queue';
  static const String appSettings = 'app_settings';
  static const String modelMetadata = 'model_metadata';
  static const String caregiverPairings = 'caregiver_pairings';

  static const List<String> createTableQueries = [
    '''
    CREATE TABLE $patients (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      full_name TEXT NOT NULL,
      age INTEGER NOT NULL,
      preferred_language TEXT NOT NULL,
      profile_photo_path TEXT,
      caregiver_info TEXT,
      created_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $familyMembers (
      id TEXT PRIMARY KEY,
      patient_id TEXT NOT NULL,
      name TEXT NOT NULL,
      relationship TEXT NOT NULL,
      photo_path TEXT NOT NULL,
      voice_note_path TEXT,
      face_embedding TEXT,
      created_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $memories (
      id TEXT PRIMARY KEY,
      patient_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      photo_path TEXT NOT NULL,
      audio_path TEXT,
      date_description TEXT,
      is_highlight INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $faceProfiles (
      id TEXT PRIMARY KEY,
      family_member_id TEXT NOT NULL,
      embedding_vector TEXT NOT NULL,
      quality_score REAL NOT NULL,
      created_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $gameSessions (
      id TEXT PRIMARY KEY,
      patient_id TEXT NOT NULL,
      game_type TEXT NOT NULL,
      total_rounds INTEGER NOT NULL,
      completed_rounds INTEGER NOT NULL,
      correct_rounds INTEGER NOT NULL,
      accuracy_percentage REAL NOT NULL,
      total_duration_ms INTEGER NOT NULL,
      starting_difficulty TEXT NOT NULL,
      final_difficulty TEXT NOT NULL,
      completed INTEGER NOT NULL,
      started_at TEXT NOT NULL,
      completed_at TEXT
    );
    ''',
    '''
    CREATE TABLE $gameRounds (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      round_index INTEGER NOT NULL,
      difficulty TEXT NOT NULL,
      target_object_count INTEGER NOT NULL,
      target_objects_json TEXT NOT NULL,
      presented_options_json TEXT NOT NULL,
      selected_options_json TEXT NOT NULL,
      is_correct INTEGER NOT NULL,
      response_latency_ms INTEGER NOT NULL,
      hesitation_ms INTEGER NOT NULL,
      tap_count INTEGER NOT NULL,
      retry_count INTEGER NOT NULL,
      created_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $interactionEvents (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      round_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      timestamp_ms INTEGER NOT NULL,
      payload_json TEXT,
      created_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $difficultyEvents (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      previous_difficulty TEXT NOT NULL,
      new_difficulty TEXT NOT NULL,
      trigger_reason TEXT NOT NULL,
      difficulty_signal REAL NOT NULL,
      supportive_intervention_shown INTEGER NOT NULL,
      patient_action TEXT,
      created_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $reminders (
      id TEXT PRIMARY KEY,
      patient_id TEXT NOT NULL,
      title TEXT NOT NULL,
      subtitle TEXT,
      scheduled_time TEXT NOT NULL,
      type TEXT NOT NULL,
      target_count INTEGER DEFAULT 1,
      completed_count INTEGER DEFAULT 0,
      is_completed INTEGER DEFAULT 0,
      last_completed_at TEXT,
      created_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $reminderLogs (
      id TEXT PRIMARY KEY,
      reminder_id TEXT NOT NULL,
      action_taken TEXT NOT NULL,
      logged_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $syncQueue (
      id TEXT PRIMARY KEY,
      table_name TEXT NOT NULL,
      record_id TEXT NOT NULL,
      operation TEXT NOT NULL,
      payload_json TEXT NOT NULL,
      status TEXT NOT NULL,
      retry_count INTEGER DEFAULT 0,
      last_error TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $appSettings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $modelMetadata (
      id TEXT PRIMARY KEY,
      model_name TEXT NOT NULL,
      version TEXT NOT NULL,
      compatible_feature_version TEXT NOT NULL,
      status TEXT NOT NULL,
      local_file_path TEXT,
      created_at TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE $caregiverPairings (
      id TEXT PRIMARY KEY,
      patient_id TEXT NOT NULL,
      pairing_code TEXT NOT NULL,
      status TEXT NOT NULL,
      caregiver_name TEXT,
      caregiver_contact TEXT,
      last_synced_at TEXT,
      created_at TEXT NOT NULL
    );
    ''',
  ];
}
