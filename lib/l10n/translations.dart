class Translations {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'YomiYomi',
      'clear_button': 'Clear',
      'convert_button': 'Convert',
      'text_field_label': 'Enter Japanese text',
      'settings_title': 'Settings',
      'dark_theme': 'Dark Theme',
      'tokenization_mode': 'Tokenization Mode (coming soon)',
      'language': 'Language',
      'russian_translations': 'Russian Translations',
      'japanese_translations': 'Japanese Translations',
      'jlpt_label': 'JLPT',
    },
    'ru': {
      'app_title': 'YomiYomi',
      'clear_button': 'Очистить',
      'convert_button': 'Конвертировать',
      'text_field_label': 'Введите японский текст',
      'settings_title': 'Настройки',
      'dark_theme': 'Тёмная тема',
      'tokenization_mode': 'Режим токенизации (скоро)',
      'language': 'Язык',
      'russian_translations': 'Русские переводы',
      'japanese_translations': 'Японские переводы',
      'jlpt_label': 'JLPT',
    },
    'ja': {
      'app_title': 'YomiYomi',
      'clear_button': 'クリア',
      'convert_button': '変換',
      'text_field_label': '日本語テキストを入力',
      'settings_title': '設定',
      'dark_theme': 'ダークテーマ',
      'tokenization_mode': 'トークナイゼーションモード（近日公開）',
      'language': '言語',
      'russian_translations': 'ロシア語翻訳',
      'japanese_translations': '日本語翻訳',
      'jlpt_label': 'JLPT',
    },
  };

  static String get(String key, String language) {
    return _translations[language]?[key] ?? _translations['en']![key]!;
  }
}