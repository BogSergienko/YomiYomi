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

await db.execute('CREATE INDEX idx_kanji ON terms(kanji)');
await db.execute('CREATE INDEX idx_kana ON terms(kana)');

await _loadJMdict(db);
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
// Проверяем комбинации символов, начиная с startIndex
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