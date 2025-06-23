[0.0.2-beta] - 2025-06-23
Fixed

Fixed compilation errors in furigana_screen.dart (syntax, missing brackets).
Fixed popup positioning: now renders ~16px below word, or above if no space.
Removed incorrect webViewScrollY usage, added RenderBox for WebView offset.
Improved stability of WebView and translation popup.

Notes

This is a beta release. First launch may take ~2 seconds for furigana generation (dictionary scanning) and ~5 seconds for initial translation (translator setup). Subsequent operations are instant.
