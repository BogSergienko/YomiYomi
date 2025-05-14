import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FuriganaScreen extends StatefulWidget {
  final String text;

  const FuriganaScreen({super.key, required this.text});

  @override
  State<FuriganaScreen> createState() => _FuriganaScreenState();
}

class _FuriganaScreenState extends State<FuriganaScreen> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;

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
                callback: (args) {
                  debugPrint('Передаём текст: ${widget.text}');
                  return widget.text;
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