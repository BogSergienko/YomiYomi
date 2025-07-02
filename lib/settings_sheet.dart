import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/translations.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({Key? key}) : super(key: key);

  @override
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  String _uiLanguage = 'en';
  bool _showEnglishTranslations = true;
  bool _showRussianTranslations = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _uiLanguage = prefs.getString('ui_language') ?? 'en';
      _showEnglishTranslations = prefs.getBool('show_english_translations') ?? true;
      _showRussianTranslations = prefs.getBool('show_russian_translations') ?? true;
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ui_language', language);
    setState(() {
      _uiLanguage = language;
    });
  }

  Future<void> _saveTranslationSettings({bool? english, bool? russian}) async {
    final prefs = await SharedPreferences.getInstance();
    if (english != null) {
      await prefs.setBool('show_english_translations', english);
      setState(() {
        _showEnglishTranslations = english;
      });
    }
    if (russian != null) {
      await prefs.setBool('show_russian_translations', russian);
      setState(() {
        _showRussianTranslations = russian;
      });
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.get('language', _uiLanguage)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                _saveLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Русский'),
              onTap: () {
                _saveLanguage('ru');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('日本語'),
              onTap: () {
                _saveLanguage('ja');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              Translations.get('settings_title', _uiLanguage),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text(Translations.get('dark_theme', _uiLanguage)),
            trailing: const Icon(Icons.lock),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    Translations.get('dark_theme', _uiLanguage) + ' (скоро)',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text(Translations.get('tokenization_mode', _uiLanguage)),
            trailing: const Icon(Icons.lock),
          ),
          ListTile(
            title: Text(Translations.get('language', _uiLanguage)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: _showLanguageDialog,
          ),
          ListTile(
            title: Text(Translations.get('english_translations', _uiLanguage)),
            trailing: Switch(
              value: _showEnglishTranslations,
              activeColor: Colors.green,
              onChanged: (value) => _saveTranslationSettings(english: value),
            ),
          ),
          ListTile(
            title: Text(Translations.get('russian_translations', _uiLanguage)),
            trailing: Switch(
              value: _showRussianTranslations,
              activeColor: Colors.green,
              onChanged: (value) => _saveTranslationSettings(russian: value),
            ),
          ),
        ],
      ),
    );
  }
}

void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black54,
    builder: (context) => const SettingsSheet(),
  );
}