import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'db_helper_class.dart';

// class GeneralDBQueries{

//   static createQuery(id,value) async{
//     switch (id) {
//       case "1":
//           qq("SELECT Depo_Hareketleri.KarsiAmbarID FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod ON Depo_Hareketleri.DepoHareketID = Stok_Karti_Barkod.DepoHareketID WHERE BarkodID = $value AND Depo_Hareketleri.Modul = 11 AND Depo_Hareketleri.HareketID = 1 AND Depo_Hareketleri.Durum = 0 limit 1;");
//         break;
//       default:
//     }
    
//   }
//   static qq(query)async{
//     var database = openDatabase('BSSBobinDB.db');
//     // var query = "SELECT Depo_Hareketleri.KarsiAmbarID FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod ON Depo_Hareketleri.DepoHareketID = Stok_Karti_Barkod.DepoHareketID WHERE BarkodID = ${_barcodeTextFieldController.text} AND Depo_Hareketleri.Modul = 11 AND Depo_Hareketleri.HareketID = 1 AND Depo_Hareketleri.Durum = 0 limit 1;";
//     var dbClient = await database;
//     var result = await dbClient.rawQuery(query);
//     print(result);
//     return result;
//   }
// }

class GeneralDBQueries {
  late DatabaseConnection _databaseConnection;

  GeneralDBQueries() {
    // initialize database connection
    _databaseConnection = DatabaseConnection();
  }

  static Database? _database;
  createQuery(id,value) async{
    switch (id) {
      case "1":
          qq("SELECT Depo_Hareketleri.KarsiAmbarID FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod ON Depo_Hareketleri.DepoHareketID = Stok_Karti_Barkod.DepoHareketID WHERE BarkodID = $value AND Depo_Hareketleri.Modul = 11 AND Depo_Hareketleri.HareketID = 1 AND Depo_Hareketleri.Durum = 0 limit 1;");
        break;
      default:
    }
    
  }
  qq(query)async{
    var connection = await (database as FutureOr<Database>);
    return await connection.rawQuery(query);
    // var database = openDatabase('BSSBobinDB.db');
    // // var query = "SELECT Depo_Hareketleri.KarsiAmbarID FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod ON Depo_Hareketleri.DepoHareketID = Stok_Karti_Barkod.DepoHareketID WHERE BarkodID = ${_barcodeTextFieldController.text} AND Depo_Hareketleri.Modul = 11 AND Depo_Hareketleri.HareketID = 1 AND Depo_Hareketleri.Durum = 0 limit 1;";
    // var dbClient = await database;
    // var result = await dbClient.rawQuery(query);
    // print(result);
  }

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
}