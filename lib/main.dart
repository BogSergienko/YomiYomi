import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(YomiReaderApp());
}

class YomiReaderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yomi Reader',
      home: FuriganaReader(),
    );
  }
}

class FuriganaReader extends StatefulWidget {
  @override
  _FuriganaReaderState createState() => _FuriganaReaderState();
}

class _FuriganaReaderState extends State<FuriganaReader> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Загружаем наш HTML из папки assets/kuroshiro/
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/index.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Фуригана Читалка')),
      body: WebViewWidget(controller: _controller),
    );
  }
}