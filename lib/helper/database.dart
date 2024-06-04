import 'package:sqflite/sqflite.dart';

class DatabaseService {
  late Database _db;
  late Database _dbLog;

  // Singleton örneği
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    _initDatabases();
  }

  Future<void> _initDatabases() async {
    _db = await openDatabase('BSSBobinDB.db');
    _dbLog = await openDatabase('BSSBobinDBLog.db');
  }

  Database get database => _db;
  Database get logDatabase => _dbLog;
}