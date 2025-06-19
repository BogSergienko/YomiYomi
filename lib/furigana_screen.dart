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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Текст с фуриганой'),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('file:///android_asset/flutter_assets/assets/index.html'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
              allowFileAccess: true,
              allowFileAccessFromFileURLs: true,
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
                    final results = await _dbHelper.findTerm(query);
                    debugPrint('Найдено для "$query": ${results.length} записей');
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
                    debugPrint('Найдено для текста "$text" с индекса $startIndex: ${results.length} записей');
                    return results;
                  } catch (e) {
                    debugPrint('Ошибка поиска полного терма: $e');
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
              debugPrint('Ошибка загрузки: ${request.url}, ошибка: ${error.description}');
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