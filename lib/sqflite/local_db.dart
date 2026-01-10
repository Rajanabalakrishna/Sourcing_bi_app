import 'package:sqflite/sqflite.dart';

//import 'sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('locations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 3, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL,
        longitude REAL,
        date TEXT,
        time TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<void> insertLocation(double lat, double lng, String date, String time) async {
    final db = await instance.database;
    await db.insert('user_locations', {
      'latitude': lat,  // Match the CREATE TABLE column name
      'longitude': lng, // Match the CREATE TABLE column name
      'date': date,
      'time': time,     // Now exists in CREATE TABLE
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllLocations() async {
    final db = await instance.database;
    return await db.query('user_locations');
  }

  Future<void> clearLocations() async {
    final db = await instance.database;
    await db.delete('user_locations');
  }
}
