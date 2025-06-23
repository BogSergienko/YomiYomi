import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'database.dart';
import 'sudachi.dart';

class FuriganaScreen extends StatefulWidget {
  final String text;

  const FuriganaScreen({super.key, required this.text});

  @override
  State<FuriganaScreen> createState() => _FuriganaScreenState();
}

class _FuriganaScreenState extends State<FuriganaScreen> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  OverlayEntry? _overlayEntry;
  final GlobalKey _webViewKey = GlobalKey();

  void _showTranslationPopup(BuildContext context, Map<String, dynamic> translation, double wordBottom, double wordTop) {
    _overlayEntry?.remove();
    String selectedLang = 'rus';

    final screenHeight = MediaQuery.of(context).size.height;
    final popupHeight = 200.0;

    // Получаем позицию WebView на экране
    final RenderBox? renderBox = _webViewKey.currentContext?.findRenderObject() as RenderBox?;
    final webViewOffset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final webViewTop = webViewOffset.dy;

    // Позиция: низ слова + отступ WebView + 16px
    double topPosition = wordBottom + webViewTop + 16;
    if (topPosition + popupHeight > screenHeight - 8) {
      // Если не помещается, рендерим выше слова
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
        title: const Text('Текст с фуриганой'),
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
            onWebViewCreated: (controller) {
              _webViewController = controller;
              _webViewController.addJavaScriptHandler(
                handlerName: 'getText',
                callback: (args) async {
                  debugPrint('Передаём текст: ${widget.text}');
                  final tokens = await Sudachi.tokenize(widget.text);
                  debugPrint('Токены: $tokens');
                  return tokens;
                },
              );
              _webViewController.addJavaScriptHandler(
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
              _webViewController.addJavaScriptHandler(
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
              _webViewController.addJavaScriptHandler(
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
            },
            onLoadStart: (controller, url) {
              debugPrint('Началась загрузка: $url');
            },
            onLoadStop: (controller, url) {
              debugPrint('Загрузка завершена: $url');
              setState(() {
                _isLoading = false;
              });
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