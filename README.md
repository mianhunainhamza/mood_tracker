# 🎭 Mood Tracker

A Flutter web app where you tap to log how you feel, see your past 7 entries in a horizontal scrollable timeline, and tap any entry to animate it.

Built as a take-home evaluation task demonstrating:

- **GetX** for reactive state management and dependency injection
- **CustomPainter** faces drawn from scratch with Flutter's canvas API
- **SharedPreferences** for local persistence (browser `localStorage` under the hood on web)
- Clean, senior-level Flutter architecture

---

## Architecture Overview

```
lib/
├── main.dart                        # App entry, GetMaterialApp + BindingsBuilder
├── controllers/
│   └── mood_controller.dart         # Single source of truth (GetxController)
├── models/
│   └── mood_entry.dart              # Immutable data model + MoodType enum
├── views/
│   └── home_view.dart               # Single screen (GetView<MoodController>)
└── widgets/
    ├── mood_picker_section.dart      # Five-face picker row + Log button
    ├── mood_face_widget.dart         # AnimatedBuilder wrapper for painter
    ├── timeline_section.dart         # Horizontal scrollable 7-entry list
    └── painters/
        └── mood_face_painter.dart    # CustomPainter — all canvas drawing
```

### State Management (GetX)

| Reactive variable          | Type               | Purpose                                    |
|----------------------------|--------------------|---------------------------------------------|
| `entries`                  | `RxList<MoodEntry>`| Full log, newest-first                      |
| `selectedMood`             | `Rx<MoodType?>`    | Currently highlighted face in the picker   |
| `highlightedEntry`         | `Rx<MoodEntry?>`   | Timeline card that is pulsing              |
| `isLoading`                | `RxBool`           | Shows loader while reading SharedPrefs     |

`Obx()` widgets subscribe to the minimal reactive slice they need — no unnecessary rebuilds.

### CustomPainter Faces

`MoodFacePainter` draws five distinct expressions using only canvas primitives:

| Mood       | Eyes      | Eyebrows          | Mouth                              |
|------------|-----------|-------------------|------------------------------------|
| Ecstatic   | Standard  | Strongly arched ↑ | Wide open smile + blush circles    |
| Happy      | Standard  | Gently arched ↑   | Medium upward arc                  |
| Neutral    | Standard  | Flat →            | Straight line                      |
| Sad        | Low drop  | Angled inward ↓   | Medium downward arc                |
| Awful      | Low drop  | Steeply angled ↓  | Wide frown + quiver corner lines   |

The `progress` parameter (0→1) drives a pulse animation on timeline tap: `scale` and `glow` intensify, then return.

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.19 (`flutter --version`)
- Chrome / any modern browser for local web dev

### Install & run locally

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/mood-tracker.git
cd mood-tracker

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (web)
flutter run -d chrome
```

### Run tests

```bash
flutter test
```

---

## Deployment

### Option A — Firebase Hosting

```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login and initialise (first time only)
firebase login
firebase init hosting   # select existing project, public dir = build/web

# 3. Build for web (release mode)
flutter build web --release

# 4. Deploy
firebase deploy --only hosting
```

### Option B — Vercel

```bash
# 1. Install Vercel CLI
npm install -g vercel

# 2. Build for web
flutter build web --release

# 3. Deploy
vercel --prod
# ↳ Set output directory to build/web when prompted
```

Both `firebase.json` and `vercel.json` are already committed. The SPA rewrite rule ensures Flutter's client-side router handles all paths.

---

## What I'd Improve With More Time

1. **Note-taking** — each mood log could carry a short text note; the model already has a `note` field ready.
2. **Mood chart** — a mini bar/line chart showing mood trend over the week (Recharts equivalent in Flutter: `fl_chart`).
3. **Haptic feedback** — on mobile, a subtle vibration on log reinforces the action.
4. **Accessibility** — add `Semantics` labels to the CustomPainter faces so screen readers announce the mood correctly.
5. **Sync** — swap SharedPreferences for Firestore so the timeline persists across devices.

---

## Commit History Strategy

Commits are structured to show natural feature development:

```
feat: scaffold Flutter project with GetX and pubspec
feat: add MoodEntry model with serialisation
feat: implement MoodController with SharedPreferences persistence  
feat: build MoodFacePainter with five CustomPainter expressions
feat: build MoodPickerSection with animated selection state
feat: build TimelineSection with horizontal scrollable cards
feat: add pulse animation on timeline entry tap
style: polish dark-theme UI, typography, glow effects
deploy: add firebase.json and vercel.json configs
test: unit tests for MoodController and MoodEntry serialisation
```
