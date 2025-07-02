import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/translations.dart';
import 'providers/settings_provider.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({Key? key}) : super(key: key);

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    debugPrint('Opening language dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.get('language', settings.uiLanguage)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                debugPrint('Selected language: en');
                settings.setUILanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Русский'),
              onTap: () {
                debugPrint('Selected language: ru');
                settings.setUILanguage('ru');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('日本語'),
              onTap: () {
                debugPrint('Selected language: ja');
                settings.setUILanguage('ja');
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
    final settings = Provider.of<SettingsProvider>(context);
    debugPrint('SettingsSheet: uiLanguage=${settings.uiLanguage}, mode=${settings.tokenizationMode}');
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
              Translations.get('settings_title', settings.uiLanguage),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text(Translations.get('dark_theme', settings.uiLanguage)),
            trailing: const Icon(Icons.lock),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    Translations.get('dark_theme', settings.uiLanguage) + ' (скоро)',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text(Translations.get('tokenization_mode', settings.uiLanguage)),
            trailing: DropdownButton<String>(
              value: settings.tokenizationMode,
              items: ['A', 'B', 'C'].map((mode) => DropdownMenuItem(
                value: mode,
                child: Text('Mode $mode'),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.setTokenizationMode(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text(Translations.get('language', settings.uiLanguage)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () => _showLanguageDialog(context, settings),
          ),
          ListTile(
            title: Text(Translations.get('russian_translations', settings.uiLanguage)),
            trailing: Switch(
              value: settings.showRussianTranslations,
              activeColor: Colors.green,
              onChanged: (value) => settings.setTranslationSettings(russian: value),
            ),
          ),
          ListTile(
            title: Text(Translations.get('japanese_translations', settings.uiLanguage)),
            trailing: Switch(
              value: settings.showJapaneseTranslations,
              activeColor: Colors.green,
              onChanged: (value) => settings.setTranslationSettings(japanese: value),
            ),
          ),
        ],
      ),
    );
  }
}

void showSettingsSheet(BuildContext context) {
  debugPrint('Showing SettingsSheet');
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black54,
    builder: (context) => const SettingsSheet(),
  );
}