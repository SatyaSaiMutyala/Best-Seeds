import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bestseeds.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE booking_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cache_key TEXT UNIQUE,
            response_json TEXT,
            cached_at TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveCache(String key, String responseJson) async {
    final db = await database;
    await db.insert(
      'booking_cache',
      {
        'cache_key': key,
        'response_json': responseJson,
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCache(String key) async {
    final db = await database;
    final result = await db.query(
      'booking_cache',
      where: 'cache_key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['response_json'] as String?;
    }
    return null;
  }

  Future<void> clearByPrefix(String prefix) async {
    final db = await database;
    await db.delete(
      'booking_cache',
      where: 'cache_key LIKE ?',
      whereArgs: ['$prefix%'],
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('booking_cache');
  }
}
