# SMRITI-NER - Antigravity Project Handoff

## Project
SMRITI-NER

Elderly-Friendly Cognitive and Memory-Support Flutter Application.

## Current Project Structure

- android/ - Android application
- assets/ - images, models and project assets
- docs/ - project documentation
- lib/ - Flutter/Dart source code
- supabase/ - Supabase database/synchronization files
- test/ - automated tests
- web/ - Flutter web configuration
- pubspec.yaml - dependencies and project configuration
- README.md - project documentation

## Implemented Features

### 1. Haat Bazaar Recall
- 3-round working-memory activity
- Local Assamese goods
- Memorization countdown
- Recall choices
- Evaluation
- Encouraging feedback

### 2. Dynamic Difficulty Adjustment
- Rule-based difficulty engine
- Response latency tracking
- Hesitation detection
- Error-burst tracking
- Rapid-tapping detection
- Difficulty intervention modal
- Take a Break / Keep Going flow

### 3. My Memories
- Photo-first reminiscence feed
- Memory/photo content
- Family-member information

### 4. Family Recognition
- Add family members
- Name and relationship
- Custom photos
- Camera-based face detection
- ML Kit face detection
- Local face-embedding architecture

### 5. Today / Aji
- Medicine adherence
- Medicine confirmation
- Six-glass hydration tracker
- Activity reminders

### 6. Offline Storage
- SQLite persistence
- Offline-first operation
- Patient, memory, game, reminder and sync data

### 7. Cloud Synchronization
- Supabase integration
- Sync queue
- Synchronization when connectivity resumes

### 8. Accessibility / Elderly UX
- Large touch targets
- High contrast
- Large buttons
- Gentle voice feedback
- TTS support

## Main Dependencies

- Flutter
- sqflite
- path
- path_provider
- flutter_local_notifications
- flutter_tts
- camera
- image_picker
- google_mlkit_face_detection
- supabase_flutter
- shared_preferences
- intl
- uuid

## Testing

Documented project verification includes:
- flutter analyze
- flutter test
- DDA engine tests
- SQLite repository tests
- widget tests
- responsive layout testing

## Important Project Requirements

- Preserve elderly-friendly UX.
- Do not unnecessarily redesign working screens.
- Preserve offline-first architecture.
- Preserve SQLite persistence.
- Preserve Supabase synchronization.
- Preserve family recognition architecture.
- Keep existing tests passing.
- Do not remove existing functionality when adding features.
- Check existing implementation before changing architecture.
- Prefer small, controlled changes.
- Run tests after meaningful code changes.

## Current Development Rule

Before changing code:
1. Inspect the existing implementation.
2. Identify dependencies and affected files.
3. Make the smallest appropriate change.
4. Run flutter analyze.
5. Run relevant tests.
6. Verify the application behavior.

## Important

This document is the persistent handoff context for continuing the project in another Antigravity account.

Update this file whenever a significant feature, architecture decision, bug fix, or project requirement changes.
