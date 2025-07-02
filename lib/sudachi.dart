import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; // Для BuildContext
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';

class Sudachi {
  static const _channel = MethodChannel('com.example.yomi_reader/sudachi');
  static final _logger = Logger('Sudachi');
  static bool _isInitialized = false;

  static void initLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  static Future<void> init() async {
    initLogging();
    if (_isInitialized) {
      _logger.info('Sudachi уже инициализирован');
      return;
    }
    try {
      _logger.info('Инициализация Sudachi...');
      await _channel.invokeMethod('initSudachi');
      _isInitialized = true;
      _logger.info('Sudachi успешно инициализирован');
    } catch (e) {
      _logger.severe('Ошибка инициализации Sudachi: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> tokenize(BuildContext context, String text) async {
    if (!_isInitialized) {
      _logger.warning('Sudachi не инициализирован, вызываем init...');
      await init();
    }
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      _logger.info('Токенизация текста: $text, режим: ${settings.tokenizationMode}');
      final result = await _channel.invokeMethod<List<dynamic>>('tokenize', {
        'text': text,
        'mode': settings.tokenizationMode,
      });
      if (result == null) {
        _logger.warning('Токенизация вернула null');
        return [];
      }
      final tokens = result.cast<Map<dynamic, dynamic>>().map((token) {
        return {
          'surface': token['surface'] as String,
          'reading': token['reading'] as String,
          'pos': token['pos'] as String,
        };
      }).toList();
      _logger.info('Получено токенов: ${tokens.length}');
      return tokens;
    } catch (e) {
      _logger.severe('Ошибка токенизации: $e');
      return [];
    }
  }
}