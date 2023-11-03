import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'sms_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sms_messages(
        id INTEGER PRIMARY KEY,
        sender TEXT,
        body TEXT,
        date TEXT,
        amount REAL,
        transaction_type TEXT,
        payment_mode TEXT
      )
    ''');
  }

  Future<double> getSumOfAmounts() async {
  final Database db = await instance.database;
  final List<Map<String, dynamic>> result = await db.query('sms_messages');
  final List<double> amounts = result.map((map) => map['amount'] as double).toList();
  return amounts.reduce((value, element) => value + element);
}

}
