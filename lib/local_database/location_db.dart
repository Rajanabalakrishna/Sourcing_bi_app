

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationDatabase {
  static final LocationDatabase instance = LocationDatabase._init();
  static Database? _database;
  LocationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tracking.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lat REAL,
        lng REAL,
        timestamp TEXT
      )
    ''');
  }

  Future<void> insertLocation(double lat, double lng) async {
    final db = await instance.database;
    await db.insert('locations', {
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllLocations() async {
    final db = await instance.database;
    return await db.query('locations');
  }

  Future<void> clearSyncedData() async {
    final db = await instance.database;
    await db.delete('locations');
  }

  // Senior Dev Tip: This implements your 2-day TTL rule
  Future<void> purgeExpiredData() async {
    final db = await instance.database;
    final twoDaysAgo = DateTime.now().subtract(Duration(hours: 48)).toIso8601String();
    await db.delete('locations', where: 'timestamp < ?', whereArgs: [twoDaysAgo]);
  }
}
