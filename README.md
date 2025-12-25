# Offline Article Reader

A Flutter application for saving and reading articles offline with a clean, distraction-free experience.

## Features

### Core
- 📥 **Save Articles** — Paste any URL to save articles for offline reading
- 📚 **Library** — Manage saved articles with hero images and gradient cards
- 📖 **Reader** — Clean, distraction-free reading with collapsible hero images
- 🔄 **Offline-First** — Saved articles load from cache, no internet required

### Reading Experience
- 🧹 **Smart Parser** — Removes ads, navigation, social buttons, and junk content
- 🎨 **Consistent Styling** — Forces readable text colors regardless of source site
- 📝 **Title Deduplication** — No duplicate titles in article content

### Customization
- 🎨 **Theme Switching** — System, Light, or Dark mode with persistence
- ⚙️ **Settings** — Theme, about page, licenses, clear data
- 🌙 **AMOLED Dark Mode** — Pure black background for OLED screens

### Onboarding
- 📱 **First-Launch Tutorial** — Animated 4-page onboarding experience
- 💡 **Feature Highlights** — Learn key features before starting

## Screenshots

| Library | Reader | Settings |
|---------|--------|----------|
| Article cards with hero images | Distraction-free reading | Theme selection |

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
│   ├── constants/      # Colors, sizes, strings
│   ├── providers/      # Theme provider
│   └── theme/          # Material 3 themes
├── features/
│   ├── library/        # Article library
│   ├── onboarding/     # First-launch tutorial
│   ├── reader/         # Article reader & parser
│   └── settings/       # Settings & about screens
├── router/             # Routes & navigation
└── main.dart           # App entry point
```

## Tech Stack

| Category | Technology |
|----------|------------|
| UI | Flutter, Material 3 |
| State | Riverpod |
| Routing | go_router |
| Database | sqflite |
| Article Parsing | html, http |
| HTML Rendering | flutter_widget_from_html |

## Key Features Detail

### Article Parser
The parser removes 100+ types of unwanted elements:
- Ads, iframes, social widgets
- Navigation, sidebars, footers
- Affiliate disclaimers, CTAs
- Related articles, comments
- Inline styles (forces consistent theming)

### Offline-First Architecture
1. **New URL** → Fetch from internet → Display → Optional save
2. **Saved Article** → Load instantly from SQLite → No network needed

## License

This project is licensed under the MIT License.
