import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _uiLanguage = 'en';
  bool _showEnglishTranslations = true;
  bool _showRussianTranslations = true;
  bool _showJapaneseTranslations = true;
  String _tokenizationMode = 'C'; // По умолчанию режим C

  String get uiLanguage => _uiLanguage;
  bool get showEnglishTranslations => _showEnglishTranslations;
  bool get showRussianTranslations => _showRussianTranslations;
  bool get showJapaneseTranslations => _showJapaneseTranslations;
  String get tokenizationMode => _tokenizationMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _uiLanguage = prefs.getString('ui_language') ?? 'en';
    _showEnglishTranslations = prefs.getBool('show_english_translations') ?? true;
    _showRussianTranslations = prefs.getBool('show_russian_translations') ?? true;
    _showJapaneseTranslations = prefs.getBool('show_japanese_translations') ?? true;
    _tokenizationMode = prefs.getString('tokenization_mode') ?? 'C';
    debugPrint('Loaded settings: language=$_uiLanguage, eng=$_showEnglishTranslations, rus=$_showRussianTranslations, ja=$_showJapaneseTranslations, mode=$_tokenizationMode');
    notifyListeners();
  }

  Future<void> setUILanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ui_language', language);
    _uiLanguage = language;
    debugPrint('Set language: $language');
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
    debugPrint('Set translations: eng=$_showEnglishTranslations, rus=$_showRussianTranslations, ja=$_showJapaneseTranslations');
    notifyListeners();
  }

  Future<void> setTokenizationMode(String mode) async {
    if (!['A', 'B', 'C'].contains(mode)) {
      debugPrint('Invalid tokenization mode: $mode');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokenization_mode', mode);
    _tokenizationMode = mode;
    debugPrint('Set tokenization mode: $mode');
    notifyListeners();
  }
}