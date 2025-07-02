import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _uiLanguage = 'en';
  bool _showEnglishTranslations = true;
  bool _showRussianTranslations = true;
  bool _showJapaneseTranslations = true;

  String get uiLanguage => _uiLanguage;
  bool get showEnglishTranslations => _showEnglishTranslations;
  bool get showRussianTranslations => _showRussianTranslations;
  bool get showJapaneseTranslations => _showJapaneseTranslations;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _uiLanguage = prefs.getString('ui_language') ?? 'en';
    _showEnglishTranslations = prefs.getBool('show_english_translations') ?? true;
    _showRussianTranslations = prefs.getBool('show_russian_translations') ?? true;
    _showJapaneseTranslations = prefs.getBool('show_japanese_translations') ?? true;
    notifyListeners();
  }

  Future<void> setUILanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ui_language', language);
    _uiLanguage = language;
    notifyListeners();
  }

  Future<void> setTranslationSettings({
    bool? english,
    bool? russian,
    bool? japanese,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (english != null) {
      await prefs.setBool('show_english_translations', english);
      _showEnglishTranslations = english;
    }
    if (russian != null) {
      await prefs.setBool('show_russian_translations', russian);
      _showRussianTranslations = russian;
    }
    if (japanese != null) {
      await prefs.setBool('show_japanese_translations', japanese);
      _showJapaneseTranslations = japanese;
    }
    notifyListeners();
  }
}