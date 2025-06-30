# YomiYomi

A Flutter-based mobile application for reading Japanese texts with furigana, translations, and tokenization support.

## Overview
YomiYomi is a mobile app designed to help learners of Japanese read native texts with ease. Built with Flutter and Dart, it integrates furigana rendering, dictionary lookups, and high-speed Sudachi tokenization — all offline and customizable for different JLPT levels.

⚠️ Currently tested and optimized for **Android** only. iOS support is planned but not yet verified.

## Features
- **Furigana Rendering**: Generates furigana (ruby text) for kanji, displayed via a WebView-based engine.
- **JLPT-Level Filtering**: Toggle furigana visibility by JLPT level (N1–N5 or all) with a dropdown menu and reset cycle.
- **JLPT Color-Coded Highlighting**: Words and kanji are highlighted by JLPT level (N1: purple, N2: red, N3: orange, N4: yellow, N5: green) using the [Yomitan JLPT Vocab](https://github.com/stephenmk/yomitan-jlpt-vocab) distribution.
- **Dictionary Integration**: Uses JMdict (English & Russian, v3.6.1) for bilingual word translations.
- **Text Tokenization**: Powered by Sudachi (v0.7.5) for precise Japanese morphological parsing.
- **Offline Mode**: All components work without internet: dictionaries, tokenizer, future OCR modules.
- **User Library** *(in development)*: Save, tag, and return to your imported texts.
- **Smart Lookup** *(planned)*: Longest-match contextual translation on tap or selection.

## Performance Notes
- First Launch: Dictionary conversion to SQLite may take 2–5 seconds. Subsequent launches and operations are instant. The initial white screen will be replaced with a loading indicator in a future update.

## In Development
- Text library: bug fixes, design improvements, and save/load functionality.

## Planned Features
- Pitch accent display.
- Text import from ePub, PDF, and camera (OCR).
- Audio reading with synced highlighting & translation (TTS).
- Contextual search across the user library ("where did I see this word?").
- Adjustable TTS speed and voice.
- Word tagging (e.g. "learned") to hide furigana on known vocabulary.
- Markdown/formatting support.
- Offline/online hybrid OCR support.
- Saved translations caching.
- Support for Japanese school grade levels (e.g., elementary and middle school) to assist native children in learning to read.

## Known Issues
- UI scaling issues on tablets.
- iOS build not yet tested or verified.

## Getting Started
1. Clone the repository: `git clone https://github.com/BogSergienko/YomiYomi.git`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`
> Note: Large files (`*.jar`, `*.dic`, `*.json`) are tracked using Git LFS.

## License
MIT License. See [LICENSE](LICENSE) for full terms.

## Download
Download the latest Android APK from [Releases](https://github.com/BogSergienko/YomiYomi/releases).