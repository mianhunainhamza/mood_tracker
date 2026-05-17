# Mood Tracker

A Flutter web app for logging how you feel. Pick a mood, hit log, done. Your last 7 entries show up in a scrollable timeline — tap any card to see it animate.

> Built with a bit of help from Claude (Anthropic) for boilerplate and structure. All architecture decisions, design choices, and implementation details are my own.

---

## What it does

- Five mood options, each drawn from scratch with Flutter's canvas API (no emoji, no images)
- Tap a face → it highlights. Hit "Log" → it saves with a timestamp
- Horizontal timeline showing your last 7 entries
- Tap a past entry to see it pulse and shimmer
- Everything persists in the browser's localStorage — no backend, no login

---

## Stack

- **Flutter web** — single screen, no router needed
- **GetX** — state management and dependency injection
- **SharedPreferences** — wraps localStorage on web, keeps entries after refresh
- **CustomPainter** — every face is drawn with `drawCircle`, `drawArc`, `drawLine`

---

## Project layout

```
lib/
├── main.dart                        # App entry, wires up GetX bindings
├── controllers/
│   └── mood_controller.dart         # All state lives here
├── models/
│   └── mood_entry.dart              # MoodEntry + MoodType enum
├── views/
│   └── home_view.dart               # The one screen
└── widgets/
    ├── mood_picker_section.dart      # Five-face picker + log button
    ├── mood_face_widget.dart         # Handles all the face animations
    ├── timeline_section.dart         # Horizontal scrollable card list
    └── painters/
        └── mood_face_painter.dart    # The actual canvas drawing
```

---

## How state flows

Three reactive variables run the whole app:

| Variable | What it tracks |
|---|---|
| `entries` | Every logged mood, newest first |
| `selectedMood` | Which face is currently tapped in the picker |
| `highlightedEntry` | Which timeline card is animating |

Each `Obx()` widget only subscribes to what it reads, so only the piece of UI that actually changed rebuilds.

---

## The faces

All five expressions are drawn with canvas primitives. The main differences are eyebrow angle and mouth shape:

| Mood | Eyebrows | Mouth |
|---|---|---|
| Ecstatic | Strongly arched up | Wide open smile, white fill, blush circles |
| Happy | Gently arched up | Medium upward arc |
| Neutral | Flat | Straight line |
| Sad | Angled inward | Medium downward arc |
| Awful | Steeply angled down | Deep frown + quiver lines at the corners |

The `progress` value (0 → 1) from the animation controller drives the glow and scale on tap.

---

## Running it

```bash
git clone https://github.com/YOUR_USERNAME/mood-tracker.git
cd mood-tracker
flutter pub get
flutter run -d chrome
```

```bash
# tests
flutter test
```

Flutter SDK ≥ 3.19 required.

---

## What I'd add next

- **Mood notes** — the `MoodEntry` model already has a `note` field, just needs a UI
- **Weekly chart** — a bar chart showing mood trends over time using `fl_chart`
- **Haptic feedback** — a small vibration on log for mobile
- **Semantics labels** — so screen readers can actually announce the drawn faces
- **Cloud sync** — swap SharedPreferences for Firestore to persist across devices