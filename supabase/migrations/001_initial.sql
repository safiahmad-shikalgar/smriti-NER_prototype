-- Supabase Initial Migration Schema for SMRITI-NER Caregiver Sync Foundation

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Patients Table
CREATE TABLE IF NOT EXISTS public.patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    full_name TEXT NOT NULL,
    age INTEGER NOT NULL,
    preferred_language TEXT NOT NULL,
    caregiver_info TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Family Members Table (Metadata only, no raw biometric vectors uploaded)
CREATE TABLE IF NOT EXISTS public.family_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id TEXT REFERENCES public.patients(patient_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    relationship TEXT NOT NULL,
    photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Game Sessions Table
CREATE TABLE IF NOT EXISTS public.game_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id TEXT REFERENCES public.patients(patient_id) ON DELETE CASCADE,
    game_type TEXT NOT NULL,
    total_rounds INTEGER NOT NULL,
    completed_rounds INTEGER NOT NULL,
    correct_rounds INTEGER NOT NULL,
    accuracy_percentage NUMERIC(5, 2) NOT NULL,
    total_duration_ms INTEGER NOT NULL,
    starting_difficulty TEXT NOT NULL,
    final_difficulty TEXT NOT NULL,
    completed BOOLEAN DEFAULT TRUE,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 4. Interaction Events Table (Behavioral metrics)
CREATE TABLE IF NOT EXISTS public.interaction_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL,
    round_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    timestamp_ms INTEGER NOT NULL,
    payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Difficulty Events Table (DDA transitions)
CREATE TABLE IF NOT EXISTS public.difficulty_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL,
    previous_difficulty TEXT NOT NULL,
    new_difficulty TEXT NOT NULL,
    trigger_reason TEXT NOT NULL,
    difficulty_signal NUMERIC(4, 3) NOT NULL,
    supportive_intervention_shown BOOLEAN NOT NULL,
    patient_action TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Reminders Table
CREATE TABLE IF NOT EXISTS public.reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id TEXT REFERENCES public.patients(patient_id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT,
    scheduled_time TEXT NOT NULL,
    type TEXT NOT NULL,
    target_count INTEGER DEFAULT 1,
    completed_count INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    last_completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Reminder Logs Table
CREATE TABLE IF NOT EXISTS public.reminder_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reminder_id TEXT NOT NULL,
    action_taken TEXT NOT NULL,
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Caregiver Pairings Table
CREATE TABLE IF NOT EXISTS public.caregiver_pairings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id TEXT REFERENCES public.patients(patient_id) ON DELETE CASCADE,
    pairing_code TEXT NOT NULL,
    status TEXT NOT NULL,
    caregiver_name TEXT,
    caregiver_contact TEXT,
    last_synced_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Model Versions Table
CREATE TABLE IF NOT EXISTS public.model_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_name TEXT NOT NULL,
    version TEXT NOT NULL,
    compatible_feature_version TEXT NOT NULL,
    download_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interaction_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.difficulty_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminder_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caregiver_pairings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.model_versions ENABLE ROW LEVEL SECURITY;

-- Allow authenticated and anon reads for pairing and sync endpoints
CREATE POLICY "Allow public select for pairing" ON public.caregiver_pairings FOR SELECT USING (true);
CREATE POLICY "Allow patient upsert" ON public.game_sessions FOR ALL USING (true);
CREATE POLICY "Allow patient interaction upsert" ON public.interaction_events FOR ALL USING (true);
CREATE POLICY "Allow patient difficulty upsert" ON public.difficulty_events FOR ALL USING (true);
CREATE POLICY "Allow patient reminder upsert" ON public.reminders FOR ALL USING (true);
