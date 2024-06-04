import 'dart:convert';
import 'package:bss_mobile_premium/helper/ipPortHelper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../helper/languages/locale_keys.g.dart';

class FirstLoad{
  static var db = openDatabase('BSSBobinDB.db');
  static var logDb = openDatabase('BSSBobinDBLog.db');
  static var ipPort = '';
  static startLoad(String? ipPortText) async{
    try{
      ipPort = ipPortText ?? await IpPort.get();
      print(ipPort);
      await loadCreateTableQuery();
      await createUpdateTable();
      await getBilgilerData(0);
      await getStokKartiData(0);
      await getIrsaliyelerData(0);
      await getDepoHareketleriData(0);
      await getStokKartiBarkodData(0);
      await getUretimBarkodHavuzData(0);
      await createLogDb();
      EasyLoading.showSuccess("YÜKLEME BAŞARILI");

    }
    catch(ex){
      EasyLoading.showError("$ex");
      throw Exception(ex);

    }

  }
  //region LOAD METHODS
  static loadCreateTableQuery() async {
    try{
      EasyLoading.show(status: "${LocaleKeys.loading_text.tr()}...", dismissOnTap: false);
      var url = ipPort + "/api/Bilgiler/createSQL";
      final response = await get(Uri.parse(url)).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        return fetchJSONForCreateTable(jsonDecode(response.body));
      } else {
        throw Exception('Bilgiler/createSQl : ${response.statusCode}-${response.body}');
      }
    }
    catch(ex){
      throw Exception('Bilgiler/createSQl : ${ex}');
    }
  }
  static createUpdateTable() async {
    var queries = [
      "CREATE TABLE IstekTakip (IstekAdi TEXT,IstekTarihi TEXT)",
      "INSERT INTO IstekTakip (IstekAdi, IstekTarihi) VALUES ('Bilgiler', '01.01.1970'),"
          "('DepoHareketleri', '01.01.1970'),"
          "('StokKartlari', '01.01.1970'),('StokKartiBarkodlar', '01.01.1970'),"
          "('Irsaliyeler', '01.01.1970'),"
          "('UretimBarkodHavuz', '01.01.1970')"
    ];
    print(queries);
    await writeDataSql(queries);
  }
  static getBilgilerData(updateType) async {
    try {
      var url = ipPort + "/api/Bilgiler/bilgiler?updateType=$updateType";
      final response = await get(Uri.parse(url)).timeout(Duration(minutes: 10));
      if (response.statusCode == 200) {
        return writeDataSql(jsonDecode(response.body));
      } else {
        EasyLoading.showError("Hata Bilgiler : ${response.statusCode}-${response.body}");
      }
    }
    catch (ex){
      throw Exception("Bilgiler $ex");
    }

  }
  static getStokKartiData(updateType) async {
    try {
      EasyLoading.instance.userInteractions = false;
      EasyLoading.show(
          status: "Stok Kartları Yükleniyor", dismissOnTap: false);

      var url =ipPort + "/api/StokKarti?updateType=$updateType";
      final response = await get(Uri.parse(url)).timeout(Duration(minutes: 10));
      if (response.statusCode == 200) {
        return writeDataSql(jsonDecode(response.body));
      } else {
        EasyLoading.showError("Hata Stok Kartı : ${response.statusCode}-${response.body}");
      }
    }
    catch (ex){
      throw Exception('Stok Karti $ex');
    }

  }
  static getIrsaliyelerData (updateType) async {
    try {
      EasyLoading.show(status: "Irsaliyeler Yükleniyor", dismissOnTap: false);
      var url = ipPort + "/api/Irsaliye?updateType=$updateType";
      final response = await get(Uri.parse(url)).timeout(Duration(minutes: 10));
      if (response.statusCode == 200) {
        return writeDataSql(jsonDecode(response.body));
      } else {
        EasyLoading.showError("Hata Irsaliyeler : ${response.statusCode}-${response.body}");
      }
    }
    catch (ex){
      throw Exception('Irsaliye $ex');
    }

  }

  static getDepoHareketleriData (updateType) async {
    var page = 0;
    while (true) {
      EasyLoading.show(
          status: "${LocaleKeys.wareHouseMoveLoad_text.tr()}/$page...", dismissOnTap: false);
      try {
        var url = ipPort +
            "/api/DepoHareketleri?updateType=$updateType&page=$page";
        final response = await get(Uri.parse(url)).timeout(Duration(minutes: 10));
        if (response.statusCode == 200) {
          await writeDataSql(jsonDecode(response.body));
          page++;
        }
        else {
          EasyLoading.showError("Hata Depo Hareketleri : ${response.statusCode}-${response.body}");
          break;
        }
      } catch (e) {
        throw Exception('Depo Hareketleri $e ');
      }
    }
  }
  static getStokKartiBarkodData(updateType) async {
    try {
      EasyLoading.show(status: "${LocaleKeys.stockBarcodeLoad_text.tr()}", dismissOnTap: false);
      var url = ipPort + "/api/StokKartiBarkod?updateType=$updateType";
      print("stok uri $url");
      final response = await get(Uri.parse(url)).timeout(Duration(minutes: 10));
      if (response.statusCode == 200) {
        return writeDataSql(jsonDecode(response.body));
      } else {
        EasyLoading.showError("Hata Barkodlar: ${response.statusCode}-${response.body}");
      }
    }
    catch (ex){
      throw Exception('Stok Karti Barkod ${ex}');
    }

  }
  static createLogDb() async {
    var dbClient = await logDb;

    var queries = [
      "CREATE TABLE IF NOT EXISTS LogHata(Id INTEGER PRIMARY KEY AUTOINCREMENT,Hata TEXT,Tarih Date)",
      "CREATE TABLE IF NOT EXISTS LogDepoHareketleri (DepoHareketID integer NOT NULL,HareketID SMALLINT,Tarih	Date,KarsiAmbarID INTEGER,AmbarID INTEGER, StokID	INTEGER,Miktar double,LotNo TEXT,Modul SMALLINT,Durum SMALLINT,EvrakID INTEGER, EvrakNo TEXT, BelgeNo	TEXT,MakinaID INTEGER,DahiliDepoTipi INTEGER, RefID INTEGER, MHesapNo INTEGER, CHesapNo INTEGER, UrtSipKalemID INTEGER, BirimID SMALLINT, Adres TEXT, BobinChangeTime DateTime, BobinSyncStatus INTEGER, IsSend INTEGER, GonderimKontrol INTEGER)",
      "CREATE TABLE IF NOT EXISTS LogGonderilenDh (DepoHareketID integer NOT NULL,HareketID SMALLINT,LotNo Text,Miktar Text,Tarih Date)"
    ];
    for (int i = 0; i < queries.length; i++) {
      if (queries[i].isNotEmpty) {
        try {
          await dbClient.rawQuery(queries[i]);
        } catch (e) {
          print("hata : $e Data : ${queries[i]}");
        }
      }
    }  }
  static getUretimBarkodHavuzData (updateType) async {
    var page = 0;
    while (true) {
      EasyLoading.show(
          status: "", dismissOnTap: false);
      try {
        var url = ipPort +
            "/api/UretimBarkodHavuz?updateType=$updateType&page=$page";
        final response = await get(Uri.parse(url)).timeout(Duration(minutes: 10));
        print(response.body);
        if (response.statusCode == 200) {
          await writeDataSql(jsonDecode(response.body));
          page++;
        }
        else {
          EasyLoading.showError("Hata UrettimBarkodHavuz : ${response.statusCode}-${response.body}");
          break;
        }
      } catch (e) {
        throw Exception('UrettimBarkodHavuz $e ');
      }
    }
  }

//endregion
  //region FUNCTIONS
  static fetchJSONForCreateTable(finalData) async {
    try{
      for (int i = 0; i < finalData.length; i++) {
        var dbClient = await db;
        await dbClient.execute(finalData[i]);
      }
    }
    catch(ex){
      throw Exception('fetchJSONForCreateTable ex:${ex}');
    }

  }
  static writeDataSql(data) async {
    var dbClient = await db;

    for (int i = 0; i < data.length; i++) {
      if (data[i].isNotEmpty) {
        try {
          await dbClient.rawQuery(data[i]);
        } catch (e) {
          print("hata : $e Data : ${data[i]}");
        }
      }
    }
  }

//endregion

}