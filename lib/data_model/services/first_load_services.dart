import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import '../../helper/languages/locale_keys.g.dart';

class LoadServices{
  static String networkURL = "";
  static var db = openDatabase('BSSBobinDB.db');
  static void deleteEverything() async {
    EasyLoading.show();
    var db = openDatabase('BSSBobinDB.db');
    var dbClient = await db;
    var tableNames = [
      "Depo_Hareketleri",
      "Kullanicilar",
      "Stok_Karti_Barkod",
      "Depolar",
      "Holler",
      "Makinalar",
      "MerkezHesaplar",
      "Musteriler",
      "OlukluDepolar",
      "Sayimlar",
      "Stok_Karti",
      "Loglar"
      "UretimBarkodHavuz"
    ];
    for (int i = 0; i < tableNames.length; i++) {
      var tableQuery = "DROP TABLE IF EXISTS ${tableNames[i]}";
      await dbClient.execute(tableQuery);
    }

    // print(res);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('lastUpdateDate');
    await preferences.remove('depoHareketleriLastUpdateDate');
    await preferences.remove('stokKartiLastUpdateDate');
    await preferences.remove('sayimLastUpdateDate');
    LoadServices.retrieveTables();
    EasyLoading.dismiss();

  }

  static retrieveTables() async {
    var firstLoad = await getFirstLoad();

    if (firstLoad == null) {
      networkURL = await getSaveDPortAndIPToSharedPref();
      await fetchUrl();
      await start(0);
    } else {
      networkURL = await getSaveDPortAndIPToSharedPref();
      await fetchUrl();
      await start(1);
    }
  }
  static fetchUrl() async {
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show(status: "${LocaleKeys.loading_text.tr()}...", dismissOnTap: false);
    var url = networkURL + "/api/Bilgiler/createSQL";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print("response.body ${response.body}");
      return fetchJSONForCreateTable(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load createSQl');
    }
  }

  static fetchJSONForCreateTable(finalData) async {
    for (int i = 0; i < finalData.length; i++) {
      var operations = finalData[i];
      await genericDBOperations(operations);
    }
  }

  static genericDBOperations(newQuery) async {
    // print('Making DB Operations... newQuery');
    createUserTable(newQuery);
  }

  static Future createUserTable(tableQuery) async {
    // print(tableQuery + "Can");
    var dbClient = await db;
    var res = await dbClient.execute(tableQuery);
    return res;
  }
  static getFirstLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstLoad = prefs.getString('firstLoad');
    // print(lastUpdateDate);
    return firstLoad;
  }

  static getSaveDPortAndIPToSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastUpdateDate = prefs.getString('port_and_ip');
    // print(lastUpdateDate);
    return lastUpdateDate;
  }
  ////Fonk////
  static start(updateType) async {
    //EasyLoading.show(status: 'yükleniyor...', dismissOnTap: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await fetchData(0);
    var page = 0;
    while (true) {
      var response = await fetchDepoHareketi(updateType, page);
      if (response) {
        page++;
      } else
        break;
    }
    await fetchStokKartiBarkod(updateType);
    await fetchSayim(updateType);
    ////setState////
    // seen = true;
    await prefs.setBool('seen', true);
    EasyLoading.dismiss();
  }

  static fetchData(updateType) async {
    var url = networkURL + "/api/Bilgiler/bilgiler?updateType=$updateType";
    final response = await http.get(Uri.parse(url));
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return fetch1Data(jsonDecode(response.body));
    } else {
      EasyLoading.showError("${LocaleKeys.connectionError_text.tr()}");
      throw Exception('Failed to load');
    }
  }

  static fetchDepoHareketi(updateType, page) async {
    print(updateType);
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show(
        status: "${LocaleKeys.wareHouseMoveLoad_text.tr()}/$page...", dismissOnTap: false);
    try {
      var url =
          networkURL + "/api/DepoHareketleri?updateType=$updateType&page=$page";
      // print("url $url");
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("depo hareket ${response.body}");
        await fetch1Data(jsonDecode(response.body));
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        EasyLoading.showError("${LocaleKeys.connectionError_text.tr()}");
        throw Exception('Failed to load');
        return false;
      }
    } catch (e) {
      print("hata ${e.toString()}");
    }
  }

  static fetchStokKartiBarkod(updateType) async {
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show(
        status: "${LocaleKeys.stockBarcodeLoad_text.tr()}", dismissOnTap: false);

    var url = networkURL + "/api/StokKartiBarkod?updateType=$updateType";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return fetch1Data(jsonDecode(response.body));
    } else {
      EasyLoading.showError("${LocaleKeys.connectionError_text.tr()}");
      throw Exception('Failed to load');
    }
  }

  static fetchSayim(updateType) async {
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show(status: "${LocaleKeys.loadCount_text.tr()}", dismissOnTap: false);

    var url = networkURL + "/api/Sayim?updateType=$updateType";
    // print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return fetch1Data(jsonDecode(response.body));
    } else {
      EasyLoading.showError("${LocaleKeys.connectionError_text.tr()}");
      throw Exception('Failed to load');
    }
  }

  static fetch1Data(data) async {
    var dbClient = await db;

    for (int i = 0; i < data.length; i++) {
      if (data[i].isNotEmpty) {
        try {
          print("datai ${data[i]}");
          await dbClient.rawQuery(data[i]);
        } catch (e) {
          // print(data[i]);
          print('yazdırma hatası : $e');
        }
      }
    }
  }
}