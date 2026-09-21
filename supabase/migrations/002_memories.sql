-- Fix family_members schema to match SQLite model precisely
ALTER TABLE public.family_members 
  ADD COLUMN IF NOT EXISTS story TEXT,
  ADD COLUMN IF NOT EXISTS photo_path TEXT,
  ADD COLUMN IF NOT EXISTS voice_note_path TEXT,
  ADD COLUMN IF NOT EXISTS face_embedding TEXT;

-- Drop photo_url as Flutter SQLite model uses photo_path exclusively right now
ALTER TABLE public.family_members DROP COLUMN IF EXISTS photo_url;

-- Create memories table
CREATE TABLE IF NOT EXISTS public.memories (
    id UUID PRIMARY KEY,
    patient_id TEXT REFERENCES public.patients(patient_id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    photo_path TEXT,
    audio_path TEXT,
    date_description TEXT,
    is_highlight INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.memories ENABLE ROW LEVEL SECURITY;

-- Drop previous open policies if they exist (from migration 001 or previous runs)
DROP POLICY IF EXISTS "Allow patient family_members upsert" ON public.family_members;
DROP POLICY IF EXISTS "Allow patient memory upsert" ON public.memories;

-- Enforce strict User Isolation (patient_id = auth.uid())
CREATE POLICY "Allow patient memory upsert" 
  ON public.memories 
  FOR ALL 
  USING (patient_id = auth.uid()::text) 
  WITH CHECK (patient_id = auth.uid()::text);

CREATE POLICY "Allow patient family_members upsert" 
  ON public.family_members 
  FOR ALL 
  USING (patient_id = auth.uid()::text) 
  WITH CHECK (patient_id = auth.uid()::text);
