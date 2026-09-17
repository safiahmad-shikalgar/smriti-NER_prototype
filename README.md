# SMRITI-NER

> **Elderly-Friendly Cognitive and Memory-Support Android Application**
> Reminiscence • Cultural Working Memory (Haat Bazaar Recall) • Dynamic Difficulty Adjustment • On-Device Family Recognition • Offline-First SQLite • Caregiver Sync

---

## 📸 Overview & Visual Identity

SMRITI-NER is crafted specifically for elderly cognitive care (targeting patients such as **Aai**). The visual identity directly honors the warm, high-contrast, uncluttered aesthetic from the Figma design reference:
- **Palette**: Warm cream background (`#FDFBF7`), Dark readable text (`#2C2523`), Sage Green (`#5F7D6B`), Coral accents (`#C95A49`), Warm pale coral (`#F5DFDC`), Soft Neutral (`#EFEFE9`).
- **Typography**: Google Fonts `Fraunces` for warm serif headings & `Figtree` for clear sans-serif body and navigation.
- **Elderly UX**: Minimum 56–60dp touch targets, high-contrast labels, large buttons, non-stigmatizing gentle voice feedback via **Mati / Speak**.

---

## 🚀 Key Modules & Architecture

1. **Haat Bazaar Recall (Cognitive Activity)**:
   - 3-round working memory practice with authentic local Assamese goods: *Assam Tea*, *Bhut Jolokia*, *Bamboo Shoots (Khorisa)*, and *Raw Turmeric (Haldi)*.
   - Flow: Instruction -> Memorize (countdown bar) -> Recall Choices -> Evaluation -> Gentle Encouraging Feedback ("Wonderful!", "That's okay. Let's try again.").

2. **Interaction-Difficulty Engine & DDA**:
   - Deterministic `RuleBasedDifficultyEngine` tracking response latency, hesitation, error bursts, and rapid tapping.
   - When high difficulty signal occurs, pauses game and triggers a gentle elderly intervention modal: *"Let's try an easier one."* (`TAKE A BREAK` / `KEEP GOING`).

3. **My Memories & Family Recognition**:
   - Photo-first reminiscence feed (e.g. *Riya's 20th Birthday in Guwahati*).
   - Add family members with custom photo, name, and relationship (*Son, Daughter, Grandson, Granddaughter, Brother, Sister, Friend*).
   - Dedicated face scan camera button with ML Kit detection + MobileFaceNet local embeddings architecture (includes isolated DEBUG DEMO fallback).

4. **Today (Aji) Schedule**:
   - Medicine adherence tracker (*Blue tablet - Aparna, 10:00 AM*) with confirmation modal.
   - 6-glass interactive water hydration tracker.
   - Activity reminder card.

5. **Offline-First Persistence & Sync Queue**:
   - 12 SQLite tables covering all patient, memory, game, reminder, and sync events.
   - Offline-first operation: full functionality without internet connection.
   - Automatic sync queue posting to Supabase when connectivity resumes.

---

## 🛠 Setup & Running Instructions

### Prerequisites
- Flutter SDK 3.13.2+
- Android SDK (API 21+) / Android Studio
- Java 17

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Static Analysis & Tests
```bash
flutter analyze
flutter test
```

### 3. Build Debug APK
```bash
flutter build apk --debug
```

### 4. Run on Connected Device or Emulator
```bash
flutter run
```

---

## 🌐 Supabase Configuration (Optional)
To connect live cloud synchronization:
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```
Execute `supabase/migrations/001_initial.sql` in your Supabase SQL Editor.

---

## 🧪 Testing Verification Checklist
- [x] Static Analysis: 0 issues with strict Flutter lints
- [x] Unit Tests: DDA Rule-based Engine calculation and transitions
- [x] Repository Tests: SQLite database seeding and retrieval
- [x] Widget Tests: Main scaffold, tabs, and Haat Bazaar Recall flow
- [x] Responsive layout across varied aspect ratios

---

## 📄 Documentation Links
- [Implementation Plan](file:///docs/IMPLEMENTATION_PLAN.md)
- [Caregiver Data Contract](file:///docs/caregiver_data_contract.md)
- [Supabase Migration Schema](file:///supabase/migrations/001_initial.sql)
