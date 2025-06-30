import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';
import 'sudachi.dart';

class FuriganaScreen extends StatefulWidget {
  final String text;

  const FuriganaScreen({super.key, required this.text});

  @override
  State<FuriganaScreen> createState() => _FuriganaScreenState();
}

class _FuriganaScreenState extends State<FuriganaScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  OverlayEntry? _overlayEntry;
  final GlobalKey _webViewKey = GlobalKey();
  String? _selectedJLPTLevel;
  double _fontSize = 16.0;
  bool _isJLPTMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadJLPTLevel();
  }

  Future<void> _loadJLPTLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedJLPTLevel = prefs.getString('jlpt_level') ?? 'all';
    });
    if (_webViewController != null && _selectedJLPTLevel != null) {
      await _webViewController!.evaluateJavascript(source: 'toggleFuriganaByJLPT("$_selectedJLPTLevel")');
    }
  }

  Future<void> _toggleJLPTLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedJLPTLevel == level) {
      await prefs.remove('jlpt_level');
      setState(() {
        _selectedJLPTLevel = 'all';
        _isJLPTMenuOpen = false;
      });
      if (_webViewController != null) {
        await _webViewController!.evaluateJavascript(source: 'toggleFuriganaByJLPT("all")');
      }
    } else {
      await prefs.setString('jlpt_level', level);
      setState(() {
        _selectedJLPTLevel = level;
        _isJLPTMenuOpen = false;
      });
      if (_webViewController != null) {
        await _webViewController!.evaluateJavascript(source: 'toggleFuriganaByJLPT("$level")');
      }
    }
  }

  Future<void> _resetJLPTLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jlpt_level');
    setState(() {
      _selectedJLPTLevel = 'all';
      _isJLPTMenuOpen = false;
    });
    if (_webViewController != null) {
      await _webViewController!.evaluateJavascript(source: 'toggleFuriganaByJLPT("all")');
    }
  }

  Future<void> _changeFontSize(double delta) async {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(12.0, 24.0);
    });
    if (_webViewController != null) {
      await _webViewController!.evaluateJavascript(source: 'setFontSize($_fontSize)');
    }
  }

  void _toggleJLPTMenu() {
    setState(() {
      _isJLPTMenuOpen = !_isJLPTMenuOpen;
    });
  }

  void _showTranslationPopup(BuildContext context, Map<String, dynamic> translation, double wordBottom, double wordTop) {
    _overlayEntry?.remove();
    String selectedLang = 'rus';

    final screenHeight = MediaQuery.of(context).size.height;
    final popupHeight = 200.0;

    final RenderBox? renderBox = _webViewKey.currentContext?.findRenderObject() as RenderBox?;
    final webViewOffset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final webViewTop = webViewOffset.dy;

    double topPosition = wordBottom + webViewTop + 16;
    if (topPosition + popupHeight > screenHeight - 8) {
      topPosition = wordTop + webViewTop - popupHeight - 16;
    }
    debugPrint('wordBottom: $wordBottom, wordTop: $wordTop, webViewTop: $webViewTop, topPosition: $topPosition, screenHeight: $screenHeight');

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              left: 16.0,
              right: 16.0,
              top: topPosition,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Container(
                  width: 300,
                  height: popupHeight,
                  padding: const EdgeInsets.all(8),
                  child: StatefulBuilder(
                    builder: (context, setState) => SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => setState(() => selectedLang = 'rus'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      minimumSize: const Size(40, 24),
                                    ),
                                    child: const Text('RU', style: TextStyle(fontSize: 12)),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() => selectedLang = 'eng'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      minimumSize: const Size(40, 24),
                                    ),
                                    child: const Text('EN', style: TextStyle(fontSize: 12)),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() => selectedLang = 'ja'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      minimumSize: const Size(40, 24),
                                    ),
                                    child: const Text('JA', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  _overlayEntry?.remove();
                                  _overlayEntry = null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            translation['word'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedLang == 'rus'
                                ? 'Русский: ${translation['rus'] ?? 'Нет перевода'}'
                                : selectedLang == 'eng'
                                ? 'English: ${translation['eng'] ?? 'No translation'}'
                                : '日本語: ${translation['ja'] ?? '大辞林: Coming soon'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _resetJLPTLevel();
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: IconButton(
                onPressed: () => _changeFontSize(2.0),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  backgroundColor: Colors.grey[300],
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.add, size: 24, color: Colors.black, weight: 700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: IconButton(
                onPressed: () => _changeFontSize(-2.0),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  backgroundColor: Colors.grey[300],
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.remove, size: 24, color: Colors.black, weight: 700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: TextButton(
                onPressed: _toggleJLPTMenu,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(60, 36),
                  backgroundColor: _selectedJLPTLevel != 'all'
                      ? (_selectedJLPTLevel == 'N5'
                      ? const Color(0xFFB3E4B3)
                      : _selectedJLPTLevel == 'N4'
                      ? const Color(0xFFE8E4A6)
                      : _selectedJLPTLevel == 'N3'
                      ? const Color(0xFFF7CDA8)
                      : _selectedJLPTLevel == 'N2'
                      ? const Color(0xFFF4A8A8)
                      : const Color(0xFFD4B3E4))
                      : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  _selectedJLPTLevel == 'all' ? 'JLPT' : _selectedJLPTLevel!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedJLPTLevel == 'all' ? Colors.black : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: _isJLPTMenuOpen
            ? PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['N1', 'N2', 'N3', 'N4', 'N5'].map((level) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: TextButton(
                  onPressed: () {
                    _toggleJLPTLevel(level);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(40, 36),
                    backgroundColor: level == 'N5'
                        ? const Color(0xFFB3E4B3)
                        : level == 'N4'
                        ? const Color(0xFFE8E4A6)
                        : level == 'N3'
                        ? const Color(0xFFF7CDA8)
                        : level == 'N2'
                        ? const Color(0xFFF4A8A8)
                        : const Color(0xFFD4B3E4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        )
            : null,
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: _webViewKey,
            initialUrlRequest: URLRequest(
              url: WebUri('file:///android_asset/flutter_assets/assets/index.html'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
              allowFileAccess: true,
              allowFileAccessFromFileURLs: false,
              allowUniversalAccessFromFileURLs: true,
            ),
            onWebViewCreated: (controller) async {
              _webViewController = controller;
              _webViewController!.addJavaScriptHandler(
                handlerName: 'getText',
                callback: (args) async {
                  debugPrint('Передаём текст: ${widget.text}');
                  final tokens = await Sudachi.tokenize(widget.text);
                  final enhancedTokens = [];
                  for (var token in tokens) {
                    final jlptLevel = await _dbHelper.getJLPTLevel(token['surface']);
                    enhancedTokens.add({
                      'surface': token['surface'],
                      'reading': token['reading'],
                      'jlptLevel': jlptLevel?.toUpperCase() ?? 'unknown',
                    });
                  }
                  debugPrint('Токены с JLPT: $enhancedTokens');
                  return enhancedTokens;
                },
              );
              _webViewController!.addJavaScriptHandler(
                handlerName: 'findTerm',
                callback: (args) async {
                  try {
                    final query = args[0] as String;
                    final wordBottom = args.length > 1 ? (args[1] as num).toDouble() : 0.0;
                    final wordTop = args.length > 2 ? (args[2] as num).toDouble() : 0.0;
                    final results = await _dbHelper.findTerm(query);
                    debugPrint('Найдено для "$query": ${results.length} записей');
                    if (results.isNotEmpty) {
                      String rus = 'Нет перевода';
                      String eng = 'No translation available';
                      for (var entry in results) {
                        if (entry['lang'] == 'rus' && entry['gloss'] != null) rus = entry['gloss'];
                        if (entry['lang'] == 'eng' && entry['gloss'] != null) eng = entry['gloss'];
                      }
                      _showTranslationPopup(context, {
                        'word': query,
                        'rus': rus,
                        'eng': eng,
                        'ja': '大辞林: Coming soon',
                      }, wordBottom, wordTop);
                    }
                    return results;
                  } catch (e) {
                    debugPrint('Ошибка поиска терма: $e');
                    return [];
                  }
                },
              );
              _webViewController!.addJavaScriptHandler(
                handlerName: 'findTermWithContext',
                callback: (args) async {
                  try {
                    final query = args[0] as String;
                    final context = args[1] as String;
                    final results = await _dbHelper.findTermWithContext(query, context);
                    debugPrint('Найдено для "$query" с контекстом "$context": ${results.length} записей');
                    return results;
                  } catch (e) {
                    debugPrint('Ошибка поиска терма с контекстом: $e');
                    return [];
                  }
                },
              );
              _webViewController!.addJavaScriptHandler(
                handlerName: 'findFullTerm',
                callback: (args) async {
                  try {
                    final text = args[0] as String;
                    final startIndex = args[1] as int;
                    final results = await _dbHelper.findFullTerm(text, startIndex);
                    debugPrint('Найдено для текста "$text" с индексом $startIndex: ${results.length} записей');
                    return results;
                  } catch (e) {
                    debugPrint('Ошибка поиска терма: $e');
                    return [];
                  }
                },
              );
              _webViewController!.addJavaScriptHandler(
                handlerName: 'setJLPTLevel',
                callback: (args) async {
                  final level = args[0] as String;
                  debugPrint('Устанавливаем JLPT уровень: $level');
                  return true;
                },
              );
            },
            onLoadStart: (controller, url) {
              debugPrint('Началась загрузка: $url');
            },
            onLoadStop: (controller, url) async {
              debugPrint('Загрузка завершена: $url');
              setState(() {
                _isLoading = false;
              });
              if (_webViewController != null && _selectedJLPTLevel != null) {
                await Future.delayed(const Duration(milliseconds: 100));
                await _webViewController!.evaluateJavascript(source: 'toggleFuriganaByJLPT("$_selectedJLPTLevel")');
              }
              if (_webViewController != null) {
                await _webViewController!.evaluateJavascript(source: 'setFontSize($_fontSize)');
              }
            },
            onReceivedError: (controller, request, error) {
              debugPrint('Ошибка загрузки: ${request.url}, error: ${error.description}');
              setState(() {
                _isLoading = false;
              });
            },
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint('JS Console: ${consoleMessage.message}');
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}