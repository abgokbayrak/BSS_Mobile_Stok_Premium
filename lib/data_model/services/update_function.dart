import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bss_mobile_premium/data_model/services/stok_karti_barkod.dart';
import 'package:bss_mobile_premium/data_model/services/uretim_barkod_havuz.dart';
import 'package:bss_mobile_premium/helper/ipPortHelper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../../helper/languages/locale_keys.g.dart';
import '../stok_karti_barkod.dart';

generalUpdateFunction(sendLogs) async {
  EasyLoading.show(status: "GÜNCELLENİYOR");
  var internetConnection = await InternetConnectionChecker().hasConnection;
  if(!internetConnection){
    EasyLoading.showInfo("${LocaleKeys.internetConnectionInfo_text.tr()}");
    return;
  }
  var networkURL = await IpPort.get();
  var dbLog = openDatabase('BSSBobinDBLog.db');
  try{
     await postDepoHareketleriUpdateData(networkURL);
    print("DEPO HAREKETLERİ BİTTİ");
     await postUretimBarkodHavuzUpdateData(networkURL);
    print("URETIM BARKOD HAVUZ BİTTİ");
    await setStokKartiBarkodUpdates(networkURL);
    print("STOK KARTI BARKODLARI BİTTİ");
    await setStokKartiUpdate(networkURL);
    print("STOK KARTLARI BİTTİ");
    await setIrsaliyeUpdate(networkURL);
    print("İRSALİYELER BİTTİ");
    EasyLoading.showSuccess("GÜNCELLENDİ");
  }on SocketException catch (_) {
    EasyLoading.showError("İnternet bağlantısı koptu.Tekrar deneyiniz",duration: Duration(seconds: 20),dismissOnTap: true );
    var dbClient = await dbLog;
    // var query =
    //     "INSERT INTO LogHata (Hata,Tarih) select 'İnternet bağlantısı koptu','${DateTime.now()}'";
    // await dbClient.rawQuery(query);

  }
  catch(e){
    // var dbClient = await dbLog;
    // var query =
    //     "INSERT INTO LogHata (Hata,Tarih) select '${e.toString()}','${DateTime.now()}'";
    // await dbClient.rawQuery(query);
    print("hata : ${e.toString()}");
    EasyLoading.showError("Genel bir hata meydana geldi.tekrar deneyiniz 1 ${e.toString()}",duration: Duration(seconds: 10),dismissOnTap: true );
  }

}

/////////Bilgiler////////////
List<dynamic> removeEmptySpaces(List<dynamic> list) {
  List<dynamic> resultList = [];

  for (String item in list) {
    String trimmedItem = item.trim();
    if (trimmedItem.isNotEmpty) {
      resultList.add(trimmedItem);
    }
  }

  return resultList;
}
 setBilgilerUpdate(networkUrl,macAddress) async {
  try{
    var url = networkUrl + "/api/Bilgiler/bilgiler?updateType=1&macAddress=$macAddress";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await saveUpdatedDataToDB(removeEmptySpaces(jsonDecode(response.body)));

    } else {

      EasyLoading.showError("${LocaleKeys.connectionError_text.tr()}");
      throw Exception('Failed to load');
    }
  }
  catch(e){

    throw Exception('$e setBigilerUpdate');

  }

}

setStokKartiUpdate(networkUrl) async {
  try{
    var lastUpdatedate = await getLastUpdateDateDB("select IstekTarihi from IstekTakip where IstekAdi = 'StokKartlari'");
    print("lastt $lastUpdatedate");
    var url = networkUrl + "/api/StokKarti?updateType=1&lastUpdateDate=$lastUpdatedate";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await saveUpdatedDataToDB(removeEmptySpaces(jsonDecode(response.body)));

    } else {
      EasyLoading.showError("${LocaleKeys.connectionError_text.tr()}");
      throw Exception('Failed to load response.statusCode');
    }
  }
  catch(e){
    throw Exception('$e stokkarti');

  }

}

setIrsaliyeUpdate(networkUrl) async {
  try{
    var lastUpdatedate = await getLastUpdateDateDB("select IstekTarihi from IstekTakip where IstekAdi = 'Irsaliyeler'");
    var url = networkUrl + "/api/Irsaliye?updateType=1&lastUpdateDate=$lastUpdatedate";
    final response = await http.get(Uri.parse(url));
    print("İRSALİYE İSTEK YAPILDI ${response.statusCode}");
    if (response.statusCode == 200) {
      print("İRSALİYE DATA ALINDI");
      await saveUpdatedDataToDB(removeEmptySpaces(jsonDecode(response.body)));
    } else {
      EasyLoading.showError("${LocaleKeys.connectionError_text.tr()}");
      throw Exception('Failed to load');
    }
  }
  catch(e){
    throw Exception('$e stokkarti');

  }

}

////////////////////////////////STOK KARTI BARKOD ////////////////////////////////
var _stokKartiBarkodService = StokKartiBarkodService();

setStokKartiBarkodUpdates(networkUrl) async {
  var db = openDatabase('BSSBobinDB.db');
  var dbClient = await db;
  var query =
      "SELECT * FROM Stok_Karti_Barkod WHERE BobinSyncStatus = 2";
  var _categories = await dbClient.rawQuery(query);
  print("ssss ${jsonEncode({"preStokKartiBarkod": _categories})}");
  print("ssss");
  if (_categories.isEmpty) {
    await getStokKartiBarkodAfterUpdate(networkUrl);
  } else {
    var url = networkUrl + "/api/StokKartiBarkod";
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(_categories),
          )
          .timeout(const Duration(seconds: 300));
      if (response.statusCode == 200) {
        await getStokKartiBarkodAfterUpdate(networkUrl);
      } else {
        EasyLoading.showError("Bağlantı Hatası Oluştu");
        throw Exception('SKBP:${response.statusCode}-${response.body}');
      }
    } on SocketException catch (_) {
      await getStokKartiBarkodAfterUpdate(networkUrl);
      EasyLoading.showToast(
          "İnternet bağlantısında problem var.Güncelle butonu ile güncelleme yapmayı unutmayınız.");
      throw Exception('STKB:İnternet baglantısı koptu');
    }
    on Exception catch (e) {
      EasyLoading.showToast("Genel Bir hata meydana geldi tekrar deneyiniz 3 ${e.toString()}");
      throw Exception('${e.toString()}:STKB');
    }
  }
}

getStokKartiBarkodAfterUpdate(networkUrl) async {
  var lastUpdatedate = await getLastUpdateDateDB("select IstekTarihi from IstekTakip where IstekAdi = 'StokKartiBarkodlar'");
  var url = networkUrl + "/api/StokKartiBarkod?updateType=1&lastUpdateDate=$lastUpdatedate";
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 300));
    if (response.statusCode == 200) {
      await deleteOldStokKartiBarkod();
      await saveUpdatedDataToDB(jsonDecode(response.body));
    } else {
      EasyLoading.showInfo("hata stok kartı ${response.body}",
          duration: Duration(seconds: 10));
      throw Exception('STKG: ${response.statusCode}-${response.body}');
    }

  } on SocketException catch (_) {
    EasyLoading.showToast(
        "İnternet bağlantısında problem var.Güncelle butonu ile güncelleme yapmayı unutmayınız.");
    throw Exception('STKG:internet Exception');
  } on Exception catch (e) {
    EasyLoading.showToast("Genel Bir hata meydana geldi tekrar deneyiniz 3 ${e.toString()}");
    throw Exception('${e.toString()}:STKG');
  }
}

deleteOldStokKartiBarkod() async {
  try {
    var stokKartiBarkodUpdatesIDs = [];
    var db = openDatabase('BSSBobinDB.db');
    var dbClient = await db;
    var query =
        "SELECT Id FROM Stok_Karti_Barkod WHERE BobinSyncStatus not in (4,2)";
    var data = await dbClient.rawQuery(query);
    if (data.isNotEmpty) {
      // var data = await _stokKartiBarkodService.getInsertsOnly(lastUpdateDate);
      for (int i = 0; i < data.length; i++) {
        stokKartiBarkodUpdatesIDs.add(data[i]["BarkodID"]);
      }
      for (int i = 0; i < stokKartiBarkodUpdatesIDs.length; i++) {
        await dbClient.rawQuery(
            "DELETE FROM Stok_Karti_Barkod WHERE BarkodID = ${stokKartiBarkodUpdatesIDs[i]}");

        //await _stokKartiBarkodService.deleteStokKartiBarkod(stokKartiBarkodUpdatesIDs[i]);
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  } catch (e) {
    EasyLoading.showError(
        "Güncelleme yapılırken hata meydana geldi.'deleteOldStokKartiBarkod' ${e.toString()}");
    throw Exception('${e.toString()} deleteOldStokKartiBarkod');
  }
}

////////////////////////////////SAYIMLAR////////////////////////////////

 setSayimlarUpdates(networkUrl,depoID,holID) async {
   EasyLoading.show(status: "Güncelleniyor");
   var db = openDatabase('BSSBobinDB.db');
  var dbClient = await db;
  var _depoQ = depoID == null ? "DepoID IS NULL" : "DepoID=${depoID}";
  var _holQ = holID == null ? "HolID IS NULL" : "HolID=${holID}";
  var query =
      "SELECT * FROM Sayimlar WHERE BobinSyncStatus !=4 and $_depoQ and $_holQ";
   var postArray = [];

  var _categories = await dbClient.rawQuery(query);
   print(_categories);
   _categories.forEach((element) {
     int? sayimID = 0;
     if (element["BobinSyncStatus"] != 1) {
       sayimID = element["Id"] as int?;
     }
     postArray.add( {
       "Id": sayimID,
       "FisNo": element["FisNo"],
       "BarkodId": element["BarkodId"],
       "Miktar": element["Miktar"],
       "StokID": element["StokID"],
       "Tarih": element["Tarih"],
       "Modul": element["Modul"],
       "Durum": element["Durum"],
       "DepoId": element["DepoId"],
       "HolId": element["HolId"],
       "EvrakId": element["EvrakId"],
       "Aktif": 1,
       "IsDeleted": 0,
       "CreatedById": element["CreatedById"],
       "ModifiedById": element["ModifiedById"],
       "RecVersion": element["RecVersion"],
       "DbTableId": element["DbTableId"],
       "CreatedDate": element["CreatedDate"],
       "ModifiedDate": element["ModifiedDate"],
       "BobinSyncStatus": element["BobinSyncStatus"]
     });

   });

  if (_categories.isEmpty) {
    await getSayimlarAfterUpdate(networkUrl,depoID,holID);
  }
  else {
   String body = jsonEncode(postArray);
   // var body = jsonEncode(postArray);
   print(body);
    var _depoId = depoID ?? "";
    var _holId = holID ?? "";
    var url = networkUrl + "/api/Sayim?depoId=$_depoId&holId=$_holId";
    var logUrl = networkUrl + "/api/SayimLog";
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 300));
      if (response.statusCode == 200) {
        await getSayimlarAfterUpdate(networkUrl,depoID,holID);
      } else {
        throw Exception('Failed to load post ${response.body}');
      }
    } on TimeoutException catch (_) {
      EasyLoading.showToast("İnternet Bağlantısında Problem Var");
    }
    on Exception catch (e) {
      EasyLoading.showToast("Genel bir hata meydana geldi setSayimlarUpdates ${e.toString()}");
      throw Exception('${e.toString()} setSayimlarUpdates');
    }
  }

 }

getSayimlarAfterUpdate(networkUrl,depoID,holID) async {
  var _depoID = depoID ?? "";
  var _holId = holID ?? "";
  var url = networkUrl + "/api/Sayim?depoId=$_depoID&holId=$_holId";
  final response = await get(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    await deleteOldSayimlar(depoID,holID);
    await saveUpdatedDataToDB([jsonDecode(response.body)["Sorgu"]]);
  } else {
    EasyLoading.showError("Hata oluştu.");
    throw Exception('Failed to load getSayimlarAfterUpdate');
  }
}

deleteOldSayimlar(depoID, holID) async {
  try {
    var _depoQ = depoID == null ? "DepoID IS NULL" : "DepoID=${depoID}";
    var _holQ = holID == null ? "HolID IS NULL" : "HolID=${holID}";
    var sayimlarUpdatesIDs = [];
    var db = openDatabase('BSSBobinDB.db');
    var dbClient = await db;
    var query =
        "Delete from sayimlar where ${_depoQ} and ${_holQ}"; // burada Depo ve hol şartı koy!!!
    var data = await dbClient.rawQuery(query);
    // if (data.isNotEmpty) {
    //   // var data = await _sayimlarService.getInsertsOnly(lastUpdateDate);
    //   for (int i = 0; i < data.length; i++) {
    //     sayimlarUpdatesIDs.add(data[i]["ID"]);
    //   }
    //   for (int i = 0; i < sayimlarUpdatesIDs.length; i++) {
    //     await dbClient.rawQuery(
    //         "DELETE FROM Sayimlar WHERE ID = ${sayimlarUpdatesIDs[i]}");
    //     //await _sayimlarService.deleteSayimlar(sayimlarUpdatesIDs[i]);
    //   }
    //   await Future.delayed(const Duration(milliseconds: 500));
    // }
  } catch (e) {
    EasyLoading.showError(
        "Güncelleme yapılırken hata meydana geldi.'deleteOldSayimlar' ${e.toString()}");
    throw Exception("deleteOldSayimlar ${e.toString()}");
  }
}

////////////////////////////////DEPO HAREKETLERİ////////////////////////////////
postDepoHareketleriUpdateData(networkUrl) async {
  var db = openDatabase('BSSBobinDB.db');
  var dbClient = await db;
  var query = "SELECT * FROM Depo_Hareketleri WHERE BobinSyncStatus !=4 and IsSend is not null and IsSend = 1";
  List<Map<String, dynamic>> depoHareketleriData = await dbClient.rawQuery(query);
  print(jsonEncode({"preDepoHareketi": depoHareketleriData}));
  List<int> depoHareketleriIdler = [];
  for (var row in depoHareketleriData) {
    depoHareketleriIdler.add(row['Id']);
  }
  if (depoHareketleriData.isEmpty) {
    await  getDepoHareketleriAfterUpdate(networkUrl);
    return;
  }
  try {
    var url = networkUrl + "/api/depohareketleri";
    var gonderimKontrolQuery = "UPDATE Depo_Hareketleri SET GonderimKontrol=1 WHERE Id IN (${depoHareketleriIdler.toSet().toList().join(",")})";
    await dbClient.rawQuery(gonderimKontrolQuery);
    final response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(depoHareketleriData),
          ).timeout(const Duration(seconds: 300));
      if (response.statusCode == 200) {
        await getDepoHareketleriAfterUpdate(networkUrl);
      } else {
        throw Exception("DHP:${response.statusCode}-${response.body}");
      }
    }
  on TimeoutException catch (_) {
      throw Exception('DHP: internet Exception');
    }
  catch (e) {
      throw Exception('${e.toString()}:DHP');
    }
}

postUretimBarkodHavuzUpdateData(networkUrl) async {
  var db = openDatabase('BSSBobinDB.db');
  var dbClient = await db;
  var query = "SELECT * FROM UretimBarkodHavuz WHERE BobinSyncStatus IS NOT NULL";
  List<Map<String, dynamic>> uretimBarkodHavuz = await dbClient.rawQuery(query);
  print(uretimBarkodHavuz);
  List<int> uretimBarkodHavuzIdler = [];
  for (var row in uretimBarkodHavuz) {
    uretimBarkodHavuzIdler.add(row['Id']);
  }
  if (uretimBarkodHavuz.isEmpty) {
    await  getUretimBarkodHavuzAfterUpdate(networkUrl);
    return;
  }
  try {
    var url = networkUrl + "/api/UretimBarkodHavuz";

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(uretimBarkodHavuz),
    ).timeout(const Duration(seconds: 300));
    if (response.statusCode == 200) {
      await getUretimBarkodHavuzAfterUpdate(networkUrl);
    } else {
      throw Exception("UBH:${response.statusCode}-${response.body}");
    }
  }
  on TimeoutException catch (_) {
    throw Exception('UBH: internet Exception');
  }
  catch (e) {
    throw Exception('${e.toString()}:UBH');
  }
}

getDepoHareketleriAfterUpdate(networkUrl) async {
  try {
    var lastUpdatedate = await getLastUpdateDateDB("select IstekTarihi from IstekTakip where IstekAdi = 'DepoHareketleri'");
    var url = networkUrl + "/api/depohareketleri?updateType=1&lastUpdateDate=$lastUpdatedate";
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 300));
    if (response.statusCode == 200) {
      await deleteOldDepoHareketleri();
      await saveUpdatedDataToDB(jsonDecode(response.body));
    } else {
      EasyLoading.showToast("${LocaleKeys.error_text.tr()} ${response.body}",
          duration: Duration(seconds: 10));
      EasyLoading.dismiss();
      throw Exception('DHG:${response.statusCode},${response.body}');
    }
  } on SocketException catch (_) {
    EasyLoading.showToast(
        "İnternet bağlantısında problem oluştu.Tekrar Güncelleyin ");
    throw Exception('DHG internet Exception');
  } on Exception catch (e) {
    EasyLoading.showToast("Genel Bir hata meydana geldi tekrar deneyiniz 4 ${e.toString()}");
    throw Exception('DHG:${e.toString()}');

  }
}
getUretimBarkodHavuzAfterUpdate(networkUrl) async {
  try {
    var lastUpdatedate = await getLastUpdateDateDB("select IstekTarihi from IstekTakip where IstekAdi = 'UretimBarkodHavuz'");
    var url = networkUrl + "/api/UretimBarkodHavuz?updateType=1&lastUpdateDate=$lastUpdatedate";
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 300));
    if (response.statusCode == 200) {
      await deleteOldUretimBarkodHavuz();
      await saveUpdatedDataToDB(jsonDecode(response.body));
    } else {
      EasyLoading.showToast("${LocaleKeys.error_text.tr()} ${response.body}",
          duration: Duration(seconds: 10));
      EasyLoading.dismiss();
      throw Exception('UBh:${response.statusCode},${response.body}');
    }
  } on SocketException catch (_) {
    EasyLoading.showToast(
        "İnternet bağlantısında problem oluştu.Tekrar Güncelleyin ");
    throw Exception('UBH internet Exception');
  } on Exception catch (e) {
    EasyLoading.showToast("Genel Bir hata meydana geldi tekrar deneyiniz 4 ${e.toString()}");
    throw Exception('UBH:${e.toString()}');

  }
}

deleteOldDepoHareketleri() async {
  try {
    var depoHareketleriUpdatesIDs = [];
    var db = openDatabase('BSSBobinDB.db');
    var dbClient = await db;

    var query = "SELECT Id FROM Depo_Hareketleri WHERE (BobinSyncStatus not in (4,2) and IsSend is not null and IsSend = 1) or GonderimKontrol = 2";

    var data = await dbClient.rawQuery(query);
    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        depoHareketleriUpdatesIDs.add(data[i]["Id"]);
      }
      for (int i = 0; i < depoHareketleriUpdatesIDs.length; i++) {
        await dbClient.rawQuery(
            "DELETE FROM Depo_Hareketleri WHERE Id = ${depoHareketleriUpdatesIDs[i]}");
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    EasyLoading.showError(
        "Güncellemede hata meydana geldi.'deleteOldDepoHareketleri' ${e.toString()}");
    throw Exception('${e.toString()} deleteOldDepoHareketleri');
  }
}

deleteOldUretimBarkodHavuz() async {
  try {
    var uretimbarkodHavuzUpdatesIDs = [];
    var db = openDatabase('BSSBobinDB.db');
    var dbClient = await db;

    var query = "SELECT Id FROM UretimBarkodHavuz WHERE BobinSyncStatus IS NOT NULL";

    var data = await dbClient.rawQuery(query);
    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        uretimbarkodHavuzUpdatesIDs.add(data[i]["Id"]);
      }
      for (int i = 0; i < uretimbarkodHavuzUpdatesIDs.length; i++) {
        await dbClient.rawQuery(
            "DELETE FROM UretimBarkodHavuz WHERE Id = ${uretimbarkodHavuzUpdatesIDs[i]}");
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    EasyLoading.showError(
        "Güncellemede hata meydana geldi.'deleteOlduretimbarkodHavuzUpdatesIDs' ${e.toString()}");
    throw Exception('${e.toString()} deleteOlduretimbarkodHavuzUpdatesIDs');
  }
}

saveUpdatedDataToDB(data) async {
  try {
  var db = openDatabase('BSSBobinDB.db');
  var dbClient = await db;
  for (int i = 0; i < data.length; i++) {
    if (data[i].isNotEmpty) {
      print(data[i]);
      await dbClient.rawQuery(data[i]).catchError((onError) {
        EasyLoading.showInfo("Hata ${onError.toString()}",duration: Duration(seconds: 10));
      });
    }
  }
  }
  catch (e) {
    EasyLoading.showError(
        "Güncelleme yapılırken hata meydana geldi.'saveUpdatedDataToDB' ${e.toString()}");
    throw Exception('${e.toString()} saveUpdatedDataToDB');
    // return Future.error('${e.toString()} saveUpdatedDataToDB');
  }
}
getLastUpdateDateDB(query) async {
  try {
    var db = openDatabase('BSSBobinDB.db');
    var dbClient = await db;
    var res = (await dbClient.rawQuery(query)).first["IstekTarihi"].toString();
    return res;
  }
  catch (e) {
    EasyLoading.showError(
        "Güncelleme yapılırken hata meydana geldi.'saveUpdatedDataToDB' ${e.toString()}");
    throw Exception('${e.toString()} saveUpdatedDataToDB');
    // return Future.error('${e.toString()} saveUpdatedDataToDB');
  }
}

getStokKartiUpdates() async {
  var categories = await _stokKartiBarkodService.getUpdates();
  categories.forEach((depo) {
    var depoModel = StokKartiBarkod();
    depoModel.BarkodID = depo['BarkodID'];
    depoModel.BobinChangeTime = depo['BobinChangeTime'];
    // depoModel.BobinChangeType = depo['BobinChangeType'];
    depoModel.BobinNo = depo['BobinNo'];
  });
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

getSaveDPortAndIPToSharedPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? getPortAndIP = prefs.getString('port_and_ip');
  String? macAddress = prefs.getString('deviceId');
  return [getPortAndIP,macAddress];
}
