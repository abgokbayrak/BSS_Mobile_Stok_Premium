import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../helper/languages/locale_keys.g.dart';

class CheckBarkodDb {
  static final dbCheck = openDatabase('BSSBobinDB.db');

 static getBarkodMiktarAndDepoId(value) async {
    var query = "SELECT Depo_Hareketleri.DepoId,Depo_Hareketleri.Miktar,Depo_Hareketleri.Id FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod ON Depo_Hareketleri.Id = Stok_Karti_Barkod.DepoHareketId WHERE Stok_Karti_Barkod.Barkod = '$value' --AND Depo_Hareketleri.Aktif = 1";
    var result = await (await dbCheck).rawQuery(query);
    return result;
  }
  static getBarkodGirislerMiktar(value) async {
    var query = '''SELECT sum(Depo_Hareketleri.Birim1Miktari) as Miktar FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod ON Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id 
      WHERE Stok_Karti_Barkod.Id in (select Id from Stok_Karti_Barkod where Barkod = $value and DepoHareketTipiId = 14)''';
    print(query);
    var result = await (await dbCheck).rawQuery(query);
    return result;
  }
  static controlBarkodDefined(value) async {
    var query = "SELECT * FROM Stok_Karti_Barkod	WHERE Barkod = $value";
    // var query = "Delete from Depo_Hareketleri where Id = 749";
    var result = await (await dbCheck).rawQuery(query);
    print("controlBarkodDefined $result");
    if (result.isEmpty) {
      return "${LocaleKeys.bobbinNotDefined_text.tr()}.";
    }
    if (result.isNotEmpty) {
      return "Barkod sistemde tanımlı.Farklı bir hata olabilir.";
    }
  }

  static getLastMove(value) async {
    var query =
        "Select DepoHareketTipiId,Depo_Hareketleri.Birim1Miktari as Miktar "
        "from Depo_Hareketleri "
        "inner join Stok_Karti_Barkod on Depo_Hareketleri.BarkodId=Stok_Karti_Barkod.Id "
        "where Stok_Karti_Barkod.Barkod = '$value' order by Depo_Hareketleri.Id desc limit 1";
    var dbClient = await dbCheck;
    var result = await dbClient.rawQuery(query);
    print("res $result");
    if (result == null) {
      return [(LocaleKeys.bobbinNotDefined_text.tr()),0];
    }
    else if (result.length == 0) {
      return ["Barkodun Girişi Yapılmamış.",14];
    }
    else {
      switch (result.first["DepoHareketTipiId"]){
        case 4:
          return ["${LocaleKeys.bobbinReturnWarehouse_text.tr()}",17];
        case 14:
          return ["${LocaleKeys.bobbinAlreadyWarehouse_text.tr()}",17];
        case 17:
          return ["${LocaleKeys.bobbinSendProduction_text.tr()}",18,result.first["Miktar"]];
        case 18:
          return ["${LocaleKeys.bobbinReturnWarehouse_text.tr()}",17];
        case 19:
          return ["${LocaleKeys.bobbinFinish_text.tr()}",0];
        case 8:
          return ["İlgili Barkod imalattan depoya transfer giriş yapılmış.",17];
        case 9:
          return ["İlgili Barkod imalattan depoya transfer çıkış yapılmış.",0];

      }

    }
  }
  static getStockCount(value) async {
    var query =
        "SELECT SUM(Depo_Hareketleri.Birim1Miktari) Stok FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod on Depo_Hareketleri.BarkodId=Stok_Karti_Barkod.Id WHERE Stok_Karti_Barkod.Barkod = '$value' AND Depo_Hareketleri.DepoHareketTipiId not in (8,9)";
    var dbClient = await dbCheck;
    var result = await dbClient.rawQuery(query);
    return result[0]["Stok"];
  }
  static getBarcodeInfo(value) async {
    var query = '''select sk.RefAd,sk.Id,dh.DepoId,dh.DepoHareketTipiId,dh.KarsiDepoId,od.IstasyonBolumlerAd,
      dh.Birim1Miktari as Miktar,dh.MasrafYeriId as MakinaId
      from Depo_Hareketleri as dh 
      inner join Stok_Karti_Barkod as skb on skb.Id=dh.BarkodId
       left join Stok_Karti as sk on dh.StokId = sk.Id
       left join OlukluDepolar as od on od.Id = dh.KarsiDepoId 
       where skb.Barkod='${value}'   ORDER by dh.Id desc limit 1''';
    print(query);
    var result = await (await dbCheck).rawQuery(query);
    return result;
  }


}
