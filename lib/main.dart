import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'furigana_screen.dart';
import 'settings_sheet.dart';
import 'l10n/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestStoragePermission();
  runApp(const MyApp());
}

Future<void> _requestStoragePermission() async {
  var status = await Permission.photos.status;
  if (!status.isGranted) {
    var result = await Permission.photos.request();
    if (!result.isGranted) {
      debugPrint('Разрешение READ_MEDIA_IMAGES не предоставлено');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YomiYomi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _uiLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _uiLanguage = prefs.getString('ui_language') ?? 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(Translations.get('app_title', _uiLanguage)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => showSettingsSheet(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80.0), // Отступ сверху для TextField
              TextField(
                controller: _controller,
                maxLines: 10,
                minLines: 10,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: Translations.get('text_field_label', _uiLanguage),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _controller.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        Translations.get('clear_button', _uiLanguage),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          debugPrint('Отправляем текст: ${_controller.text}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FuriganaScreen(text: _controller.text),
                            ),
                          );
                        } else {
                          debugPrint('Текст пустой!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        Translations.get('convert_button', _uiLanguage),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}