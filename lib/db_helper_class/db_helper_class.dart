import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import '../data_model/depolar.dart';
import '../data_model/stok_kabul_model.dart';

class DbHelper {
  static final DbHelper _dbHelper = DbHelper._internal();
  static const String sTblNotes = "Barkod3";
  static const String sColId = "id";
  static const String sColTitle = "firmaBobinNo";
  static const String sColDetail = "kg";
  static const String sBarcodeCode = "barcodeCode";
  
  static Database? _db;

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  Future<bool> openDb() async {
    if (_db == null) {
      // Directory dir = await getApplicationDocumentsDirectory();
      // _db = await openDatabase("${dir.path}/BSSBobinDB.db",
      //     version: 1);
    }
    return (_db != null);
  }

  void insertData (data) async {
    var query = "INSERT INTO Barkod(title) VALUES ($data)";

    await _db!.rawInsert('INSERT INTO Barkod(id,title,detail) VALUES(1,Can,Can2)'); // Dangerous!
  }
  Future<void> insertSKM(StokKabulModel skm) async {
  // Get a reference to the database.
  // final Database db = _db;

  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
  //
  // In this case, replace any previous data.
  await _db!.insert(
    'Barkod3',
    skm.toMap(),
    // conflictAlgorithm: ConflictAlgorithm.replace,
  );
  }

  Future<List> getNoteRecs() async {
    return await _db!
        .rawQuery("SELECT * FROM $sTblNotes ORDER BY $sColTitle ASC");
  }
  Future<List<Depolar>> getDepolar() async {
    final Database db = _db!;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('Depolar');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      print("MAps");
      print(maps);
      return Depolar(
        AmbarID: maps[i]['AmbarID'],
        AmbarIsmi: maps[i]['AmbarIsmi'],
      );
    });
  }
}


class DatabaseConnection{
  setDatabase(){
    var database = openDatabase('BSSBobinDB.db');
    return database;
  }
}