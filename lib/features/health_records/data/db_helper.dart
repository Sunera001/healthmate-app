import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_record.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('healthmate.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE health_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        water INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertRecord(HealthRecord r) async {
    final db = await database;
    return await db.insert('health_records', r.toMap());
  }

  Future<List<HealthRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('health_records', orderBy: 'date DESC');
    return maps.map((m) => HealthRecord.fromMap(m)).toList();
  }

  Future<List<HealthRecord>> getRecordsByDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'health_records',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map((m) => HealthRecord.fromMap(m)).toList();
  }

  Future<int> updateRecord(HealthRecord r) async {
    final db = await database;
    return await db.update(
      'health_records',
      r.toMap(),
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllRecords() async {
    final db = await database;
    return await db.delete('health_records');
  }
}
