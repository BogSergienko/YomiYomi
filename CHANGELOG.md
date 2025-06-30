##[0.0.2-beta] - 2025-06-23
###Fixed

-Fixed compilation errors in furigana_screen.dart (syntax, missing brackets).
-Fixed popup positioning: now renders ~16px below word, or above if no space.
-Removed incorrect webViewScrollY usage, added RenderBox for WebView offset.
-Improved stability of WebView and translation popup.

###Notes

-This is a beta release. First launch may take ~2 seconds for furigana generation (dictionary scanning) and ~5 seconds for initial translation (translator setup). Subsequent operations are instant.

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