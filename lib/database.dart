import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
        static final DatabaseHelper _instance = DatabaseHelper._internal();
        factory DatabaseHelper() => _instance;
        DatabaseHelper._internal();

        Database? _database;

        Future<Database> get database async {
                if (_database != null) return _database!;
                _database = await _initDatabase();
                return _database!;
        }

        Future<Database> _initDatabase() async {
                final dbPath = await getDatabasesPath();
                final path = join(dbPath, 'jmdict.db');

                return openDatabase(
                        path,
                        version: 1,
                        onCreate: (db, version) async {
                                await db.execute('''
          CREATE TABLE terms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            kanji TEXT,
            kana TEXT,
            gloss TEXT,
            lang TEXT
          )
        ''');
                                await db.execute('''
          CREATE TABLE jlpt_vocab (
            word TEXT PRIMARY KEY,
            reading TEXT,
            jlpt_level TEXT CHECK(jlpt_level IN ('N5', 'N4', 'N3', 'N2', 'N1')),
            source TEXT CHECK(source IN ('yomitan', 'classifier'))
          )
        ''');

                                await db.execute('CREATE INDEX idx_kanji ON terms(kanji)');
                                await db.execute('CREATE INDEX idx_kana ON terms(kana)');

                                await _loadJMdict(db);
                                await _loadJLPTData(db);
                        },
                );
        }

        Future<void> _loadJMdict(Database db) async {
                try {
                        final ruJson = await rootBundle.loadString('assets/jmdict-rus-3.6.1.json');
                        final enJson = await rootBundle.loadString('assets/jmdict-eng-3.6.1.json');
                        final ruData = jsonDecode(ruJson)['words'] as List<dynamic>;
                        final enData = jsonDecode(enJson)['words'] as List<dynamic>;

                        final batch = db.batch();
                        for (var entry in ruData) {
                                final kanji = entry['kanji']?.isNotEmpty == true ? entry['kanji'][0]['text'] : '';
                                final kana = entry['kana']?.isNotEmpty == true ? entry['kana'][0]['text'] : '';
                                final gloss = entry['sense']?.isNotEmpty == true && entry['sense'][0]['gloss']?.isNotEmpty == true
                                    ? entry['sense'][0]['gloss'][0]['text']
                                    : '';
                                if (kanji.isNotEmpty && kana.isNotEmpty && gloss.isNotEmpty) {
                                        batch.insert('terms', {
                                                'kanji': kanji,
                                                'kana': kana,
                                                'gloss': gloss,
                                                'lang': 'rus',
                                        });
                                }
                        }
                        for (var entry in enData) {
                                final kanji = entry['kanji']?.isNotEmpty == true ? entry['kanji'][0]['text'] : '';
                                final kana = entry['kana']?.isNotEmpty == true ? entry['kana'][0]['text'] : '';
                                final gloss = entry['sense']?.isNotEmpty == true && entry['sense'][0]['gloss']?.isNotEmpty == true
                                    ? entry['sense'][0]['gloss'][0]['text']
                                    : '';
                                if (kanji.isNotEmpty && kana.isNotEmpty && gloss.isNotEmpty) {
                                        batch.insert('terms', {
                                                'kanji': kanji,
                                                'kana': kana,
                                                'gloss': gloss,
                                                'lang': 'eng',
                                        });
                                }
                        }
                        await batch.commit(noResult: true);
                        debugPrint('JMdict загружен: ru=${ruData.length}, en=${enData.length}');
                } catch (e) {
                        debugPrint('Ошибка загрузки JMdict: $e');
                }
        }

        Future<void> _loadJLPTData(Database db) async {
                try {
                        final jsonString = await rootBundle.loadString('assets/data/jlpt_vocab.json');
                        final jsonData = jsonDecode(jsonString) as List<dynamic>;
                        final batch = db.batch();
                        for (var entry in jsonData) {
                                final term = entry[0] as String;
                                final reading = entry[2]['reading'] as String;
                                final jlptLevel = entry[2]['frequency']['displayValue'] as String;
                                batch.insert('jlpt_vocab', {
                                        'word': term,
                                        'reading': reading,
                                        'jlpt_level': jlptLevel,
                                        'source': 'yomitan',
                                }, conflictAlgorithm: ConflictAlgorithm.replace);
                        }
                        await batch.commit(noResult: true);
                        debugPrint('Yomitan JLPT загружен: ${jsonData.length} записей');
                } catch (e) {
                        debugPrint('Ошибка загрузки Yomitan JLPT: $e');
                }
        }

        Future<String?> getJLPTLevel(String word) async {
                final db = await database;
                final result = await db.query(
                        'jlpt_vocab',
                        where: 'word = ?',
                        whereArgs: [word],
                        limit: 1,
                );
                return result.isNotEmpty ? result.first['jlpt_level'] as String? : null;
        }

        Future<List<Map<String, dynamic>>> findTerm(String query) async {
                final db = await database;
                return db.query(
                        'terms',
                        where: 'kanji = ? OR kana = ?',
                        whereArgs: [query, query],
                        limit: 10,
                );
        }

        Future<List<Map<String, dynamic>>> findTermWithContext(String query, String context) async {
                final db = await database;
                return db.query(
                        'terms',
                        where: 'kanji = ? OR kanji = ? OR kana = ? OR kana = ?',
                        whereArgs: [query, query + context, query, query + context],
                        limit: 10,
                );
        }

        Future<List<Map<String, dynamic>>> findFullTerm(String fullText, int startIndex) async {
                final db = await database;
                final results = <Map<String, dynamic>>[];
                for (int length = 1; length <= fullText.length - startIndex; length++) {
                        final term = fullText.substring(startIndex, startIndex + length);
                        final terms = await db.query(
                                'terms',
                                where: 'kanji = ? OR kana = ?',
                                whereArgs: [term, term],
                                limit: 1,
                        );
                        if (terms.isNotEmpty) {
                                results.add(terms.first);
                        }
                }
                return results;
        }
}