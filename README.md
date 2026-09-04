# PrepX Pro

**AI-Powered Interview Preparation App** — built with Flutter, GetX, Firebase, and Google Gemini AI.

PrepX Pro helps job seekers prepare for technical interviews in one place: a searchable question bank, coding practice problems, AI-generated mock interviews (with voice mode and STAR-method scoring), resume analysis, flashcards, cheat sheets, and a peer community.

---

## ✨ Features

| Module | What it does |
|---|---|
| **Onboarding** | Collects target role, experience level, target companies, and a short skill quiz |
| **Dashboard** | Readiness score, practice streak, daily challenge, 14-day weakness heatmap, quick stats |
| **Question Bank** | Searchable/filterable interview questions with bookmarking |
| **Coding Problems** | LeetCode-style problems (via external API) with an in-app code editor |
| **Mock Interview** | Gemini-generated Technical / Behavioral / Mixed interviews, chat or **voice mode** (speech-to-text + text-to-speech), STAR evaluation, radar-chart results |
| **Resume Upload** | PDF resume parsing, AI skill detection, and resume-tailored practice questions |
| **Flashcards** | Flip-card review for quick concept revision |
| **Cheat Sheets** | Topic reference sheets |
| **Community** | Shared interview experiences and peer matching |
| **Profile** | View/edit personal profile and preferences |

---

## 🛠 Tech Stack

- **Framework:** Flutter (Dart ≥ 3.0)
- **State management / DI / routing:** [GetX](https://pub.dev/packages/get) (`get`, `get_storage`)
- **Backend:** Firebase — Auth, Cloud Firestore (Spark/free tier)
- **AI:** Google Generative AI — Gemini (`gemini-1.5-flash`) for question generation, resume analysis, and STAR evaluation
- **Voice:** `speech_to_text`, `flutter_tts`, `audioplayers`
- **Networking / files:** `dio`, `file_picker`, `pdfx`, `syncfusion_flutter_pdf`
- **Charts:** `syncfusion_flutter_charts`
- **UI/UX:** `flutter_animate`, `shimmer`, `flutter_html`, `linked_scroll_controller`
- **Notifications:** `flutter_local_notifications`, `timezone`

---

## 📁 Project Structure

```
lib/
 └─ app/
     ├─ bindings/        # GetX Bindings — wire up controllers per route
     ├─ controllers/      # GetX controllers (state + business logic)
     ├─ data/
     │   ├─ models/       # Plain Dart data classes
     │   └─ providers/     # Firestore, Gemini AI, LeetCode API clients
     ├─ routes/           # Route names & route table
     ├─ services/         # App-wide singletons: storage, audio, notifications
     ├─ theme/            # Centralized colors, text styles, ThemeData
     ├─ ui/
     │   ├─ pages/         # Screens, grouped by feature
     │   └─ widgets/       # Shared reusable widgets
     └─ utils/            # Cross-cutting helpers (error handling, etc.)
 └─ main.dart             # App entry point
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (channel stable)
- A Firebase project with **Authentication** and **Cloud Firestore** enabled
- A free [Gemini API key](https://aistudio.google.com/)

### Setup

1. **Clone and install dependencies**
   ```bash
   git clone <https://github.com/lybah-gif/prep_x_pro_flutter_app>
   cd prepx_pro
   flutter pub get
   ```

2. **Connect Firebase**
   Run FlutterFire CLI to generate your own `firebase_options.dart` / platform config files:
   ```bash
   flutterfire configure
   ```

3. **Add your Gemini API key**
   The key **must not** be committed to source control. Provide it at build/run time instead, e.g.:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```
   and read it in `GeminiProvider` via `String.fromEnvironment('GEMINI_API_KEY')` rather than a hard-coded literal.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🎨 Design System

Dark-first theme with an indigo accent:

| Token | Hex |
|---|---|
| Primary | `#6366F1` |
| Primary Dark | `#4F46E5` |
| Background | `#0F172A` |
| Surface | `#1E293B` |
| Success / Warning / Error / Info | `#22C55E` / `#F59E0B` / `#EF4444` / `#3B82F6` |

---

## 🧪 Testing

```bash
flutter test
```

> The project currently ships with the default Flutter widget-test template. Adding controller-level unit tests (e.g. `DashboardController`, `MockInterviewController`) and widget tests for the core flows (onboarding → dashboard → mock interview) is recommended before production use.

---

## 🔒 Security Notes

- **Rotate and externalize the Gemini API key** — do not commit it as a string literal.
- Review **Firestore security rules** to ensure per-user read/write restrictions.
- The external LeetCode-style problems API is unauthenticated third-party — consider caching/fallback handling.

---

## 🗺 Roadmap

- Automated test coverage for controllers, providers, and key user flows
- Environment-based secrets configuration
- Trend charts on the Dashboard (historical readiness, not just point-in-time)
- Offline caching of AI-generated content
- Push notifications for community/peer-match activity
- Expanded company-persona and industry-specific question sets
- Accessibility pass across all screens

---

