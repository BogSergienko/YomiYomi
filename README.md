# YomiYomi

A Flutter-based mobile application for reading Japanese texts with furigana, translations, and tokenization support.

## English

### Overview
YomiYomi is a mobile app designed to help learners of Japanese read native texts with ease. Built with Flutter and Dart, it integrates furigana rendering, dictionary lookups, and high-speed Sudachi tokenization — all offline and customizable for different JLPT levels.

⚠️ Currently tested and optimized for **Android** only. iOS support is planned but not yet verified.

### Features
- **Furigana Rendering**: Generates furigana (ruby text) for kanji, displayed via a WebView-based engine.
- **Dictionary Integration**: Uses JMdict (English & Russian, v3.6.1) for bilingual word translations.
- **Text Tokenization**: Powered by Sudachi (v0.7.5) for precise Japanese morphological parsing.
- **JLPT-Level Highlighting** *(in development)*: Color-coded kanji/vocab by JLPT level (N5–N1).
- **Offline Mode**: All components work without internet: dictionaries, tokenizer, future OCR modules.
- **User Library** *(in development)*: Save, tag, and return to your imported texts.
- **Smart Lookup** *(planned)*: Longest-match contextual translation on tap or selection.

### In Development
- JLPT-based furigana filtering.
- Text library: bug fixes, design improvements, and save/load functionality.

### Planned Features
- Pitch accent display.
- Text import from ePub, PDF, and camera (OCR).
- Audio reading with synced highlighting & translation (TTS).
- Contextual search across the user library ("where did I see this word?").
- Adjustable TTS speed and voice.
- Word tagging (e.g. "learned") to hide furigana on known vocabulary.
- Markdown/formatting support.
- Offline/online hybrid OCR support.
- Saved translations caching.

### Known Issues
- Furigana alignment may shift on very complex sentence layouts.
- UI scaling issues on tablets.
- Translation popup may occasionally go off-screen (fix coming soon).
- iOS build not yet tested or verified.

### Getting Started
1. Clone the repository: `git clone https://github.com/BogSergienko/YomiYomi.git`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`
> Note: Large files (`*.jar`, `*.dic`, `*.json`) are tracked using Git LFS.

### License
MIT License. See [LICENSE](LICENSE) for full terms.

---

## 日本語

### 概要
YomiYomiは、日本語学習者がネイティブテキストを簡単に読めるように設計されたモバイルアプリです。FlutterとDartで構築されており、フリガナ表示、辞書検索、形態素解析をすべてオフラインで提供します。

⚠️ 現時点では**Androidのみ**で動作確認済みです。iOSは今後対応予定ですが、まだ未検証です。

### 機能
- **フリガナ表示**: 漢字に自動でルビ（フリガナ）を追加。WebViewベースの描画エンジン使用。
- **辞書統合**: JMdict（英語・ロシア語対応、v3.6.1）を使用したバイリンガル辞書検索。
- **テキスト解析**: Sudachi（v0.7.5）による正確な日本語形態素解析。
- **JLPT対応の色分け**（開発中）: 語彙や漢字をレベルごとに色分け。
- **オフライン動作**: 全機能がインターネット接続不要で使用可能。
- **テキストライブラリ**（開発中）: 読んだテキストを保存・タグ付け・再読可能。
- **スマート翻訳**（予定）: 長い語句でも最適な翻訳を表示。

### 開発中
- JLPTに基づくフリガナ表示のフィルター機能。
- テキストライブラリのバグ修正・デザイン調整・保存機能。

### 今後の計画
- ピッチアクセントの可視化。
- ePub・PDF・カメラスキャン（OCR）によるテキストインポート。
- 音声読み上げとリアルタイム翻訳表示。
- ユーザーライブラリ内の語彙検索機能。
- 音声再生速度や音声タイプの選択。
- フリガナ非表示のための「覚えた単語」タグ機能。
- Markdown/書式サポート。
- オフライン／オンラインOCRのハイブリッド対応。
- 翻訳結果のキャッシュ機能。

### 既知の問題
- 複雑な文構造でフリガナの位置が若干ずれる可能性あり。
- タブレットでのUIスケーリングに問題がある場合があります。
- 翻訳ウィンドウが画面外にはみ出ることがあります（近日修正予定）。
- iOSでの動作確認はまだ行われていません。

### はじめ方
1. リポジトリをクローン: `git clone https://github.com/BogSergienko/YomiYomi.git`
2. 依存パッケージを取得: `flutter pub get`
3. アプリを起動: `flutter run`
> 注意: 大容量ファイル（`*.jar`, `*.dic`, `*.json`）はGit LFSで管理しています。

### ライセンス
MITライセンスです。詳細は[LICENSE](LICENSE)をご覧ください。

---

## Русский

### Обзор
YomiYomi — мобильное приложение для чтения японских текстов с фуриганой, переводами и морфологическим анализом. Разработано на Flutter и Dart, оно работает оффлайн и адаптируется под уровень пользователя.

⚠️ В настоящее время протестировано только на **Android**. Поддержка iOS планируется, но ещё не проверена.

### Возможности
- **Фуригана**: Автоматическая подстановка фуриганы над кандзи через движок на WebView.
- **Словарь**: Подключён JMdict (версия 3.6.1, английский и русский).
- **Токенизация текста**: Используется Sudachi (v0.7.5) для точного морфоанализа японского.
- **Подсветка JLPT** *(в разработке)*: Подсветка кандзи и слов по уровню сложности.
- **Офлайн-режим**: Всё работает без интернета, включая словарь, токенизацию, и в будущем — сканирование.
- **Библиотека текстов** *(в разработке)*: Возможность сохранять, тегировать и повторно читать тексты.
- **Контекстный перевод** *(в планах)*: Перевод длинных фраз по нажатию или выделению.

### В разработке
- Фильтрация фуриганы по уровню JLPT.
- Библиотека текстов (фиксы, дизайн, сохранение).

### В планах
- Отображение тонового акцента.
- Импорт текста из PDF, ePub и через камеру (OCR).
- Аудиоозвучка текста с переводом и подсветкой.
- Поиск слов по всей библиотеке.
- Настройка скорости озвучки и голоса.
- Отметка "Выучил слово" — скрытие фуриганы.
- Поддержка Markdown-формата.
- Гибридный OCR: офлайн (Tesseract) и онлайн (Google API).
- Кэширование переводов для оффлайн-доступа.

### Известные баги
- Фуригана может немного смещаться в сложных предложениях.
- Возможны проблемы с масштабированием интерфейса на планшетах.
- Окно с переводом может вылезать за пределы экрана (в процессе исправления).
- Поддержка iOS пока не тестировалась.

### Как начать
1. Склонируйте репозиторий: `git clone https://github.com/BogSergienko/YomiYomi.git`
2. Установите зависимости: `flutter pub get`
3. Запустите приложение: `flutter run`
> Примечание: Крупные файлы (`*.jar`, `*.dic`, `*.json`) отслеживаются через Git LFS.

### Лицензия
MIT License. См. [LICENSE](LICENSE) для подробностей.
