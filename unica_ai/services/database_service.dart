import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'migration_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    try {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print("Database Error: $e");
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'unica_memory.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Upgrade mantığı: Sadece tabloları kontrol et ve verileri aktar
          await _createTables(db);
          await _seedMigrationData(db);
        }
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedMigrationData(db);
  }

  Future<void> _createTables(Database db) async {
    print("Veritabanı tabloları kontrol ediliyor...");
    await db.execute('''
      CREATE TABLE IF NOT EXISTS logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        user TEXT,
        ai TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profile (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_summary (
        date TEXT PRIMARY KEY,
        summary TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inner_thoughts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        thought TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        priority INTEGER,
        status TEXT
      )
    ''');
  }

  Future<void> _seedMigrationData(Database db) async {
    // Verilerin zaten var olup olmadığını kontrol et (isim üzerinden)
    final profileCheck = await db.query(
      'user_profile',
      where: 'key = ?',
      whereArgs: ['name'],
    );
    if (profileCheck.isNotEmpty) {
      print("Migration verileri zaten mevcut, atlanıyor.");
      return;
    }

    print("Eski veriler aktarılıyor...");
    final now = DateTime.now().toIso8601String();

    for (var profile in MigrationData.userProfile) {
      await db.insert('user_profile', {
        'key': profile['key'],
        'value': profile['value'],
        'updated_at': now,
      });
    }

    for (var log in MigrationData.logs) {
      await db.insert('logs', {
        'time': now,
        'user': log['user'],
        'ai': log['ai'],
      });
    }
    print("Migration tamamlandı.");
  }

  // Helper methods for logs
  Future<void> insertLog(String user, String ai) async {
    final db = await database;
    await db.insert('logs', {
      'time': DateTime.now().toIso8601String(),
      'user': user,
      'ai': ai,
    });
  }

  Future<List<Map<String, dynamic>>> getLogs({
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(
      'logs',
      orderBy: 'time DESC',
      limit: limit,
      offset: offset,
    );
  }

  // Helper methods for inner thoughts
  Future<void> insertThought(String thought) async {
    final db = await database;
    await db.insert('inner_thoughts', {
      'time': DateTime.now().toIso8601String(),
      'thought': thought,
    });
  }

  Future<String?> getLastThought() async {
    final db = await database;
    final results = await db.query(
      'inner_thoughts',
      orderBy: 'time DESC',
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first['thought'] as String?;
    }
    return null;
  }
}
