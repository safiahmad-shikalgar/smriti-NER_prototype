# SMRITI-NER — Caregiver Data Contract & Synchronization Specification

This document details the interface and data contract between the SMRITI-NER mobile application and the future web-based caregiver dashboard.

---

## 1. Privacy Boundary & Data Residency

### Data That Remains Strictly On-Device (Local SQLite Only)
1. **Raw Camera Streams & Video Frames**: Never recorded or transmitted.
2. **Face Biometric Embeddings**: High-dimensional face vector encodings remain in local SQLite (`face_profiles` and `family_members` tables).
3. **Sensitive Raw Audio**: Voice notes and Mati text-to-speech recordings are processed and kept locally.

### Data Synchronized to Cloud (Supabase)
1. **Patient Profile Metadata**: Name, Age, Language preference, Caregiver assignment.
2. **Cognitive Performance & Adherence Summaries**:
   - Game sessions completed, total duration, accuracy percentage.
   - Per-round performance (latency in ms, retry counts, correctness).
3. **Behavioral Interaction Signals & DDA Events**:
   - Difficulty transitions (e.g. `normal` -> `easy`).
   - Trigger reasons (`latency_spike`, `error_burst`, `rapid_tapping`).
   - Supportive intervention responses (`break_taken`, `continued`).
4. **Care Reminders & Daily Routine Logs**:
   - Medication adherence timestamp (`medicine_taken`, `reminded_later`).
   - Hydration milestones (e.g. `3/6 glasses completed`).
   - Activity completions.
5. **Caregiver Pairing & Connection State**:
   - Pairing code (e.g. `SMRITI-4821`), pairing status, and last synced timestamp.

---

## 2. Sync Queue Architecture & Offline Resilience

```
Local Event Triggered (e.g., Round completed / Med taken)
                  │
                  ▼
         Persist to SQLite Table
                  │
                  ▼
       Enqueue in `sync_queue` (Status: 'pending')
                  │
        [Network Connectivity Check]
         ┌────────┴────────┐
         ▼                 ▼
   [Offline]           [Online]
  Remain Safe       Update Status to 'syncing'
   in SQLite               │
                           ▼
                    Post to Supabase
                           │
                     ┌─────┴─────┐
                     ▼           ▼
                [Success]     [Failure]
              Status: 'synced' Status: 'failed'
                                (Retried on next cycle)
```

- **Guaranteed No Data Loss**: Records are never purged if cloud synchronization fails.

---

## 3. Data Schema Contract (JSON Payloads)

### 3.1 `game_sessions` Payload
```json
{
  "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "patient_id": "patient_aai_01",
  "game_type": "haat_bazaar_recall",
  "total_rounds": 3,
  "completed_rounds": 3,
  "correct_rounds": 2,
  "accuracy_percentage": 66.67,
  "total_duration_ms": 42150,
  "starting_difficulty": "normal",
  "final_difficulty": "easy",
  "completed": true,
  "started_at": "2026-09-17T10:15:30.000Z",
  "completed_at": "2026-09-17T10:16:12.000Z"
}
```

### 3.2 `difficulty_events` (DDA) Payload
```json
{
  "id": "a1b2c3d4-e5f6-7890-1234-56789abcdef0",
  "session_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "previous_difficulty": "normal",
  "new_difficulty": "easy",
  "trigger_reason": "latency_spike",
  "difficulty_signal": 0.720,
  "supportive_intervention_shown": true,
  "patient_action": "continued",
  "created_at": "2026-09-17T10:15:58.000Z"
}
```

### 3.3 `reminders` Payload
```json
{
  "id": "rem_med_01",
  "patient_id": "patient_aai_01",
  "title": "Blue tablet",
  "subtitle": "(Aparna) Blood Pressure Medicine",
  "scheduled_time": "10:00 AM",
  "type": "medicine",
  "target_count": 1,
  "completed_count": 1,
  "is_completed": true,
  "last_completed_at": "2026-09-17T10:05:00.000Z"
}
```

---

## 4. Caregiver Dashboard Integration Expectations
The future caregiver web portal will:
1. Connect using pairing code `SMRITI-4821`.
2. Display longitudinal cognitive trends without clinical diagnostic terminology.
3. Allow caregivers to remotely schedule new medication and hydration reminders.
4. Upload family photos to be synced down to the patient's reminiscence album.
