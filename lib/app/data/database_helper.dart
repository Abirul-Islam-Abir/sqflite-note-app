import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final _tableName = "notes";
  static final _columnId = "id";
  static final _columnTitle = "title";
  static final _columnContent = "content";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute('''
             CREATE TABLE $_tableName (
               $_columnId INTEGER PRIMARY KEY,
               $_columnTitle TEXT,
               $_columnContent TEXT
             )
           ''');
      },
      version: 1,
    );
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(_tableName, row);
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[_columnId];
    return await db.update(
      _tableName,
      row,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await database;
    return await db.query(_tableName);
  }
}