# Offline Article Reader

A Flutter application for saving and reading articles offline.

## Features

- 📥 Save articles from any URL for offline reading
- 📚 Library view to manage saved articles
- 📖 Clean, distraction-free reader experience
- 🌙 Dark mode support
- 💾 Local SQLite storage

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/offline_article_reader.git
   cd offline_article_reader
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App-wide constants (colors, sizes, strings)
│   └── theme/          # App themes
├── features/
│   ├── library/        # Article library feature
│   │   ├── models/     # Article model
│   │   ├── screens/    # Library screen
│   │   └── services/   # Storage service
│   └── reader/         # Article reader feature
│       ├── screens/    # Reader & URL input screens
│       └── services/   # Article parser service
├── router/             # App routing (go_router)
└── main.dart           # App entry point
```

## Tech Stack

- **State Management**: Riverpod
- **Routing**: go_router
- **Database**: sqflite
- **Article Parsing**: html package

## License

This project is licensed under the MIT License.
