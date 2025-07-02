## [0.0.4] - 2025-07-02

### Added
- Sudachi tokenization modes (A, B, C) with a DropdownButton in SettingsSheet for mode selection:
  - **Mode A**: Short tokens for detailed morphological analysis (e.g., "食べ物" → "食べ" + "物").
  - **Mode B**: Medium tokens for balanced analysis (e.g., "食べ物" as a single word).
  - **Mode C**: Long tokens for compound words (e.g., "食べ物" + "を" + "食べます").
- Persistent tokenization mode storage using SharedPreferences, preserved across app restarts.
- Language selection (English, Russian, Japanese) with real-time updates via SettingsProvider.
- Translation toggles in SettingsSheet for enabling/disabling JMdict translations.
- Locked dark theme for consistent UI experience.
- Settings button in FuriganaScreen for quick access to configuration.
- Updated SettingsProvider to manage tokenization mode and language state.
- Modified sudachi.dart and SudachiTokenizer.java to pass and process tokenization mode.
- Updated MainActivity.kt to handle tokenization mode via MethodChannel.
- Enhanced debug logging for tokenization modes and language updates in Sudachi and FuriganaScreen.

### Fixed
- Ensured FuriganaScreen compatibility with new tokenization modes, maintaining correct furigana rendering and JLPT level filtering.
- Fixed null check errors in SettingsSheet and FuriganaScreen using `context.read<SettingsProvider>()`.
- Improved translation filtering to synchronize with language selection.
- Fixed HomeScreen UI for better layout consistency.

### Notes
- Tested on Android with sample texts (e.g., "食べ物を食べます", "日本語を勉強しています").
- Tokenization performance remains fast (<1 sec for 2000 characters).
- Fully offline mode preserved.
- First launch may take 2–5 seconds for dictionary setup. Subsequent operations are instant.
- See [README](README.md) for details and known issues.

## [0.0.3] - 2025-06-30
### Added
- Color-coded word underlining based on JLPT levels (N1: purple, N2: red, N3: orange, N4: yellow, N5: green).
- JLPT level filtering with a dropdown menu to toggle furigana by level (N1-N5 or all).
- Circular zoom buttons (+/-) in AppBar for text size adjustment.
- JLPT button toggle cycle (JLPT → N3 → N3 → JLPT).
- Pastel colors for JLPT levels for a softer UI.
### Fixed
- Fixed word underlining display and JLPT level synchronization between Dart and JS.
- Added debug logs for better issue tracking.

## [0.0.2-beta] - 2025-06-23
### Fixed
- Fixed compilation errors in furigana_screen.dart (syntax, missing brackets).
- Fixed popup positioning: now renders ~16px below word, or above if no space.
- Removed incorrect webViewScrollY usage, added RenderBox for WebView offset.
- Improved stability of WebView and translation popup.
### Notes
- This is a beta release. First launch may take ~2 seconds for furigana generation (dictionary scanning) and ~5 seconds for initial translation (translator setup). Subsequent operations are instant.