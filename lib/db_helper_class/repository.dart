import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'db_helper_class.dart';

class Repository {
  late DatabaseConnection _databaseConnection;

  Repository() {
    // initialize database connection
    _databaseConnection = DatabaseConnection();
  }

  static Database? _database;

  // Check if database is exist or not
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _databaseConnection.setDatabase();
    return _database;
  }

  // Inserting data to Table
  insertData(table, data) async {
    var connection = await (database as FutureOr<Database>);
    return await connection.insert(table, data);
  }

  // Read data from Table
  readData(table) async {
    var connection = await database;
    return await connection!.query(table);
  }
  readDataDepo(query) async {
    var connection = await database;
    return await connection!.rawQuery(query);
  }
  // Read data from Table
  readLimitData(table,limit) async {
    var connection = await (database as FutureOr<Database>);
    return await connection.query(table,limit: limit);
  }
  searchData(table,searchText) async{
    var connection = await (database as FutureOr<Database>);
    return await connection.query(table,where:"MusteriAdi LIKE '%${searchText}%'",whereArgs:[searchText]);
  }

  // Read data from table by Id
  readDataById(table, itemId) async {
    var connection = await (database as FutureOr<Database>);
    return await connection.query(table, where: 'AmbarID=?', whereArgs: [itemId]);
  }
  readSayimlarByDepoId(table, itemId) async {
    var connection = await (database as FutureOr<Database>);
    return await connection.execute("SELECT EvrakID,count(*) as EvrakSayisi From Sayimlar where DepoID=$itemId GROUP BY EvrakID");
    // return await connection.query(table, where: 'DepoID=?', whereArgs: [itemId]);
  }

  // Update data from table
  updateData(table, data) async {
    var connection = await (database as FutureOr<Database>);
    return await connection
        .update(table, data, where: 'AmbarID=?', whereArgs: [data['id']]);
  }

  // Delete data from table
  deleteData(table, itemId) async {
    var connection = await (database as FutureOr<Database>);
    return await connection.rawDelete("DELETE FROM $table WHERE AmbarID = $itemId");
  }
  deleteStokKartiBarkodID(table, barkodID) async {
    var connection = await (database as FutureOr<Database>);
    return await connection.rawDelete("DELETE FROM $table WHERE BarkodID = $barkodID");
  }
  deleteDepoHareketID(table, depoHareketID) async {
    var connection = await (database as FutureOr<Database>);
    return await connection.rawDelete("DELETE FROM $table WHERE DepoHareketID = $depoHareketID");
  }
  deleteSayimID(table, sayimID) async {
    var connection = await (database as FutureOr<Database>);
    return await connection.rawDelete("DELETE FROM $table WHERE ID = $sayimID");
  }

  // Read data from table by Column Name
  readDataByColumnName(table, columnName, columnValue) async {
    var connection = await (database as FutureOr<Database>);
    return await connection
        .query(table, where: '$columnName=?', whereArgs: [columnValue]);
  }
  func() async{
    var connection = await (database as FutureOr<Database>);
    await connection.transaction((txn) async {
      
      await txn.execute('CREATE TABLE Test4 (id INTEGER PRIMARY KEY)');
      
      await txn.execute('CREATE TABLE Test5 (id INTEGER PRIMARY KEY)');
    });
  }

  getBeforeUpdateDate(table) async{
    var connection = await (database as FutureOr<Database>);
    return await connection
        .query(table, where: " BobinChangeType != 0 and IsSend is not null and IsSend = 1 ORDER BY BobinChangeTime ASC ");

  }
  getOnlyInserts(table) async{
    var connection = await (database as FutureOr<Database>);
    return await connection.execute("SELECT * FROM $table WHERE BobinChangeType= 1 and IsSend is not null and IsSend=1 ORDER BY BobinChangeTime ASC");

      }


  getCount(table,depoHareketId) async{
    var connection = await (database as FutureOr<Database>);
    return await connection.query(table,where: 'DepoHareketID=$depoHareketId');
    //"SELECT COUNT(*) FROM $table WHERE DepoHareketID = $depoHareketId;"
  }
}
