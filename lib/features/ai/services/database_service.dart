import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'migration_data.dart';
import 'sync_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    try {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database;
    } catch (e) {
      debugPrint("Database Error: $e");
      return null;
    }
  }

  Future<Database?> _initDatabase() async {
    if (kIsWeb) return null;

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'unica_memory.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
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
    debugPrint("Veritabanı tabloları kontrol ediliyor...");
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
    final profileCheck = await db.query(
      'user_profile',
      where: 'key = ?',
      whereArgs: ['name'],
    );
    if (profileCheck.isNotEmpty) {
      debugPrint("Migration verileri zaten mevcut, atlanıyor.");
      return;
    }

    debugPrint("Eski veriler aktarılıyor...");
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
    debugPrint("Migration tamamlandı.");
  }

  Future<void> insertLog(String user, String ai) async {
    final time = DateTime.now().toIso8601String();

    if (kIsWeb) {
      final box = Hive.box('unica_logs');
      await box.add({
        'time': time,
        'user': user,
        'ai': ai,
      });
    } else {
      final db = await database;
      if (db != null) {
        await db.insert('logs', {
          'time': time,
          'user': user,
          'ai': ai,
        });
      }
    }

    // Arka planda Firebase'e yükle (Web'de de çalışır)
    SyncService()
        .uploadLog(time, user, ai)
        .catchError((e) => debugPrint("Firebase upload error: $e"));
  }

  Future<void> checkAndInsertLog(Map<String, dynamic> log) async {
    final time = log['time'] as String;
    if (kIsWeb) {
      final box = Hive.box('unica_logs');
      final exists = box.values.any((e) => e['time'] == time);
      if (!exists) {
        await box.add(log);
      }
    } else {
      final db = await database;
      if (db == null) return;
      final exists =
          await db.query('logs', where: 'time = ?', whereArgs: [time]);
      if (exists.isEmpty) {
        await db.insert('logs', log);
      }
    }
  }

  Future<List<Map<String, dynamic>>> getLogs({
    int limit = 10,
    int offset = 0,
  }) async {
    if (kIsWeb) {
      final box = Hive.box('unica_logs');
      final List logs = box.values.toList();
      logs.sort((a, b) => (b['time'] as String).compareTo(a['time'] as String));

      final start = offset;
      final end =
          (offset + limit) > logs.length ? logs.length : (offset + limit);
      if (start >= logs.length) return [];

      return logs
          .sublist(start, end)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final db = await database;
    if (db == null) return [];

    return await db.query(
      'logs',
      orderBy: 'time DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<void> insertThought(String thought) async {
    final time = DateTime.now().toIso8601String();
    if (kIsWeb) {
      final box = Hive.box('unica_thoughts');
      await box.add({
        'time': time,
        'thought': thought,
      });
    } else {
      final db = await database;
      if (db == null) return;
      await db.insert('inner_thoughts', {
        'time': time,
        'thought': thought,
      });
    }
  }

  Future<void> checkAndInsertThought(Map<String, dynamic> thought) async {
    final time = thought['time'] as String;
    if (kIsWeb) {
      final box = Hive.box('unica_thoughts');
      final exists = box.values.any((e) => e['time'] == time);
      if (!exists) {
        await box.add(thought);
      }
    } else {
      final db = await database;
      if (db == null) return;
      final exists = await db
          .query('inner_thoughts', where: 'time = ?', whereArgs: [time]);
      if (exists.isEmpty) {
        await db.insert('inner_thoughts', thought);
      }
    }
  }

  Future<String?> getLastThought() async {
    if (kIsWeb) {
      final box = Hive.box('unica_thoughts');
      if (box.isEmpty) return null;
      final List thoughts = box.values.toList();
      thoughts
          .sort((a, b) => (b['time'] as String).compareTo(a['time'] as String));
      return thoughts.first['thought'] as String?;
    }

    final db = await database;
    if (db == null) return null;

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

  // Profil İşlemleri
  Future<void> updateProfile(String key, String value) async {
    final now = DateTime.now().toIso8601String();
    if (kIsWeb) {
      final box = Hive.box('unica_profile');
      await box.put(key, {
        'value': value,
        'updated_at': now,
      });
    } else {
      final db = await database;
      if (db != null) {
        await db.insert(
            'user_profile',
            {
              'key': key,
              'value': value,
              'updated_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<Map<String, dynamic>> getFullProfile() async {
    if (kIsWeb) {
      final box = Hive.box('unica_profile');
      return Map<String, dynamic>.from(box.toMap());
    } else {
      final db = await database;
      if (db == null) return {};
      final List<Map<String, dynamic>> rows = await db.query('user_profile');
      Map<String, dynamic> profile = {};
      for (var row in rows) {
        profile[row['key']] = {
          'value': row['value'],
          'updated_at': row['updated_at'],
        };
      }
      return profile;
    }
  }
}
