# SMRITI-NER — Implementation Plan & Architecture Specification

## 1. Current State Assessment
- **Existing Codebase**: The project had standard Flutter starter code concatenated with a raw Figma-to-code export in `lib/main.dart`.
- **Analyzer Errors**: 7 compiler issues found due to duplicate `main()` declarations and invalid `padding` parameters on `SizedBox` widgets in the Figma export.
- **Visual Design Reference**: Figma export contains the core aesthetic tokens (Warm cream background `#FDFBF7`, Dark brown text `#2C2523`, Secondary text `#635854`, Coral `#C95A49`, Pale Coral `#F5DFDC`, Sage Green `#5F7D6B`, Neutral `#EFEFE9`, Warm Beige `#F7F1EB`, Fraunces & Figtree typography).
- **Missing Elements**: Dynamic routing, responsive scaling (Figma code was locked to `width: 402, minHeight: 874`), local SQLite database, state management, asset bundles, Haat Bazaar cognitive game logic, rule-based DDA engine, camera/ML Kit face recognition interface, local reminder notifications, and Supabase synchronization queue.

---

## 2. Target Architecture
A clean feature-first layered architecture ensuring separation of concerns, offline reliability, and elderly-friendly accessibility:

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── routing/
│   ├── theme/
│   └── utilities/
├── data/
│   ├── database/
│   ├── local/
│   ├── remote/
│   └── repositories/
├── features/
│   ├── caregiver/
│   ├── face_recognition/
│   ├── haat_bazaar/
│   ├── home/
│   ├── memories/
│   ├── navigation/
│   ├── play/
│   ├── profile/
│   ├── progress/
│   └── today/
├── models/
├── services/
│   ├── caregiver/
│   ├── dda/
│   ├── face/
│   ├── game/
│   ├── model_update/
│   ├── notifications/
│   ├── sync/
│   └── tts/
└── widgets/
```

---

## 3. Migration & Implementation Steps

1. **Environment & Dependency Setup**:
   - Update `pubspec.yaml` with essential production dependencies: `sqflite`, `path`, `path_provider`, `google_fonts`, `flutter_local_notifications`, `flutter_tts`, `camera`, `image_picker`, `google_mlkit_face_detection`, `supabase_flutter`, `shared_preferences`, `intl`, `uuid`.
   - Update Android configurations: `minSdk 21`, permissions for camera, notifications, boot completed, and vibration.

2. **Core Design System**:
   - `AppColors`, `AppTypography`, `AppSpacing`, `AppTheme` replicating the warm, high-contrast, elderly-friendly palette and Fraunces/Figtree typography with large interactive targets (56–64dp).

3. **Assets Creation & Bundling**:
   - Provide local bundled vector/image assets for cultural items (Assam Tea, Bhut Jolokia, Bamboo Shoots, Raw Turmeric), family avatars, and memories.

4. **Data Layer & SQLite Database**:
   - 12 comprehensive tables covering patients, family, memories, game sessions, game rounds, interaction events, difficulty events, reminders, sync queue, caregiver pairings, and model metadata.
   - First-launch seed data initialized gracefully with Aai, Riya, Birthday memory, and daily reminders.

5. **Cognitive Game — Haat Bazaar Recall**:
   - 3-round memory recall game with real cultural market items.
   - Multi-phase flow: Instructions -> Memory stage (item exposure) -> Recall phase (interactive choice grid) -> Gentle feedback -> Summary.
   - Comprehensive metric recording: latency, taps, retries, hesitation, correctness.

6. **Dynamic Difficulty Adjustment (DDA) Engine**:
   - `RuleBasedDifficultyEngine`: Calculates interaction difficulty based on latency spikes, error bursts, and rapid tapping.
   - Supportive intervention modal: "Let's try an easier one." with options to take a break or continue at an easier level without clinical/frustration labeling.

7. **Memories & Family Management**:
   - Photo-first reminiscence feed.
   - Add Family Member with camera capture or gallery selection, relationship tagging, and local SQLite persistence.

8. **Local Face Recognition Pipeline**:
   - ML Kit face detection + `FaceRecognitionEngine` abstraction.
   - Local privacy-first matching against family member face profiles.
   - Isolated debug demo fallback if TFLite model is not yet bundled.

9. **Today (Aji) Screen & Reminders**:
   - Medicine adherence tracker (Blue tablet 10:00 AM) with 'Done' and 'Remind Me Later'.
   - Visual 6-glass water tracker with interactive tap state.
   - Activity card and local notification scheduling.

10. **Progress Screen**:
    - Encouraging, non-medical elderly summary: "Wonderful Work, Aai!", completed games count, accuracy, and daily memory journey.

11. **Caregiver Sync & Supabase Foundation**:
    - Sync queue mechanism storing offline events and syncing to Supabase when connectivity resumes.
    - Caregiver pairing code `SMRITI-4821` and sync status indicator.
    - Initial SQL migration script for Supabase.

12. **Voice (Mati) Helper**:
    - Accessible Text-to-Speech service for reading instructions aloud with graceful fallback.

13. **Testing & QA Verification**:
    - Unit, widget, and integration tests.
    - Zero analyzer errors and debug APK build verification.
