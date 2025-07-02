# YomiYomi

A Flutter-based mobile application for reading Japanese texts with furigana, translations, and tokenization support.

## Overview

YomiYomi is a mobile app designed to help learners of Japanese read native texts with ease. Built with Flutter and Dart, it integrates furigana rendering, dictionary lookups, and high-speed Sudachi tokenization — all offline and customizable for different JLPT levels. Supports interface localization for multiple languages.

⚠️ Currently tested and optimized for **Android** only. iOS support is planned but not yet verified.

## Features

- **Furigana Rendering**: Generates furigana (ruby text) for kanji, displayed via a WebView-based engine.
- **JLPT-Level Filtering**: Toggle furigana visibility by JLPT level (N1–N5 or all) with a dropdown menu and reset cycle.
- **JLPT Color-Coded Highlighting**: Words and kanji are highlighted by JLPT level (N1: purple, N2: red, N3: orange, N4: yellow, N5: green) using the [Yomitan JLPT Vocab](https://github.com/stephenmk/yomitan-jlpt-vocab) distribution.
- **Dictionary Integration**: Uses JMdict (English & Russian, v3.6.1) with language selection in settings.
- **Text Tokenization**: Powered by Sudachi (v0.7.5) with three tokenization modes:
  - **Mode A**: Fine-grained tokens for detailed analysis (e.g., "食べ物" → "食べ" + "物").
  - **Mode B**: Medium tokens for balanced analysis (e.g., "食べ物" as a single word).
  - **Mode C**: Coarse tokens for compound words (e.g., "食べ物" + "を" + "食べます").
- **Interface Localization**: Supports English, Russian, and Japanese with real-time switching via SettingsSheet.
- **Settings**: Dropdown menu for selecting tokenization mode and language, saved via SharedPreferences.
- **Note**: Dark theme is under development and will be added in an upcoming update.

## Performance Notes

- First Launch: Dictionary conversion to SQLite may take 2–5 seconds. Subsequent launches and operations are instant.
- Tokenization: <1 sec for 2000 characters.
- Initial white screen will be replaced with a loading indicator in a future update.

## In Development

- **JLPT Filter via jlpt-classifier**:
  - Integration of a Python script for word classification by JLPT levels.
  - SQLite database update with new JLPT levels.
  - Updated filtering logic in `toggleFuriganaByJLPT`.
- **Dark Theme**:
  - Toggle switch for dark theme in settings.
  - Implementation via ThemeData and CSS in `index.html`.
  - Support for automatic mode (based on system theme).
  - Restart prompt for theme changes.
- **User Library**: Save, tag, and revisit imported texts.

## Planned Features

- Contextual translation: Longest-match translation on tap or selection.
- Pitch accent display.
- Text import from ePub, PDF, and camera (OCR).
- Audio reading with synced highlighting & translation (TTS).
- Contextual search across the user library.
- Adjustable TTS speed and voice.
- Word tagging (e.g., "learned") to hide furigana for known vocabulary.
- Markdown/formatting support.
- Offline/online hybrid OCR support.
- Saved translations caching.
- Support for Japanese school grade levels to assist native children in learning to read.

## Getting Started

1. Clone the repository: `git clone https://github.com/BogSergienko/YomiYomi.git`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

> Note: Large files (`*.jar`, `*.dic`, `*.json`) are tracked using Git LFS.

## License

MIT License. See [LICENSE](LICENSE) for full terms.

## Download

Download the latest Android APK from [Releases](https://github.com/BogSergienko/YomiYomi/releases).