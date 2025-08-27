import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'taboo.db');

    if (!await databaseExists(path)) {
      ByteData data = await rootBundle.load('assets/taboo.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    final db = await openDatabase(path);
    // İndeks oluştur (eğer yoksa)
    await db.execute('CREATE INDEX IF NOT EXISTS idx_counter ON kelimeler(counter);');
    return db;
  }

  Future<List<Map<String, dynamic>>> getRandomWords(int count) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT * FROM kelimeler
      WHERE counter = (SELECT MIN(counter) FROM kelimeler)
      ORDER BY RANDOM()
      LIMIT ?
    ''', [count]);
    return result;
  }

  Future<void> incrementCounter(String kelime) async {
    final db = await instance.database;
    await db.rawUpdate('''
      UPDATE kelimeler
      SET counter = counter + 1
      WHERE kelime = ?
    ''', [kelime]);
  }
}