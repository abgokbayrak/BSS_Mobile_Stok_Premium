
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';

import '../../helper/alert.dart';
import '../../helper/languages/locale_keys.g.dart';


class BobinBitirBarkodSearchModal extends StatefulWidget {
  final barkodID;
  final olukluDepoID;
  BobinBitirBarkodSearchModal(
      {Key? key, required this.barkodID, required this.olukluDepoID})
      : super(key: key);

  @override
  _BobinBitirBarkodSearchModalState createState() =>
      _BobinBitirBarkodSearchModalState();
}

class _BobinBitirBarkodSearchModalState
    extends State<BobinBitirBarkodSearchModal> {
  var db = openDatabase('BSSBobinDB.db');
  List countries = [];
  List barkodAfterOlukluSelectedItems = [];

  bool isSearching = false;

  getBarkodsForSecondButton() async {
    EasyLoading.show(status: LocaleKeys.loading_text.tr());
    //barkodAfterOlukluSelectedItems.clear();
    var dbClient = await db;
    var query =
        "SELECT Stok_Karti_Barkod.BarkodID, Depo_Hareketleri.LotNo FROM Depo_Hareketleri INNER JOIN OlukluDepolar ON Depo_Hareketleri.AmbarID = OlukluDepolar.AmbarID INNER JOIN Stok_Karti_Barkod ON Stok_Karti_Barkod.BarkodID = Depo_Hareketleri.LotNo   INNER JOIN Stok_Karti ON Stok_Karti_Barkod.StokID = Stok_Karti.StokID WHERE     (Stok_Karti_Barkod.Durum = 0) AND (Depo_Hareketleri.Durum = 0) AND (Depo_Hareketleri.AmbarID = ${widget.olukluDepoID})  AND (Depo_Hareketleri.HareketID IN (9, 17)) AND (Stok_Karti_Barkod.BarkodID IN (SELECT     LotNo FROM        Depo_Hareketleri WHERE     (DepoHareketID IN (SELECT     MAX(DepoHareketID) AS DepID FROM        Depo_Hareketleri AS Depo_Hareketleri_1 WHERE     (AmbarID = ${widget.olukluDepoID}) AND (Durum = 0) GROUP BY LotNo)) AND (HareketID IN (9, 17)) AND (LotNo IS NOT NULL))) GROUP BY Depo_Hareketleri.LotNo,  Stok_Karti.En, Stok_Karti_Barkod.BarkodID";

    var result = await dbClient.rawQuery(query);
    print(result.length);
    print("result $result");
    for (int i = 0; i < result.length; i++) {
      setState(() {
        barkodAfterOlukluSelectedItems.insert(i, result[i]);
        countries.insert(i, result[i]);
      });
    }
    print(result);
    print("barkodAfterOlukluSelectedItems");
    print(barkodAfterOlukluSelectedItems);
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    super.initState();

    getBarkodsForSecondButton();
  }

  void _filterCountries(value) {
    setState(() {
      barkodAfterOlukluSelectedItems = countries
          .where((country) =>
              country["BarkodID"].toString().contains(value.toLowerCase()))
          .toList();
      //print("countries $countries");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _filterCountries(value);
          },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintText: "${LocaleKeys.search_text.tr()}",
              hintStyle: TextStyle(color: Colors.white)),
        ),
        actions: <Widget>[
          isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                      barkodAfterOlukluSelectedItems = countries;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
                )
        ],
      ),
      body: Container(
          padding: EdgeInsets.all(10),
          child: barkodAfterOlukluSelectedItems.length > 0
              ? ListView.builder(
                  itemCount: barkodAfterOlukluSelectedItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        onTapBarkod(index);
                      },
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child: Text(
                            barkodAfterOlukluSelectedItems[index]["BarkodID"]
                                .toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  })
              : null),
    );
  }

  onTapBarkod(index) async {
    EasyLoading.show(status: "Bobin bitir ekranına aktarılıyorsunuz..");
    controlFunctionsBeforeChoosingBarcode(index);
  }

  controlFunctionsBeforeChoosingBarcode(index) async {
    var dbClient = await db;
    var query =
        "Select Durum from Stok_Karti_Barkod where Durum=0 and BarkodID=${barkodAfterOlukluSelectedItems[index]["BarkodID"]}";
    var result = await dbClient.rawQuery(query);
    print(result);
    var durum = result[0]["Durum"];
    print(durum);
    if (durum == 0) {
      var bobinImalatCheck = await controlForBobinImalat(
          barkodAfterOlukluSelectedItems[index]["BarkodID"]);
      if (bobinImalatCheck == 17) {
        var stokCheck = await controlForStok(
            barkodAfterOlukluSelectedItems[index]["BarkodID"]);
        print(stokCheck);
        if (stokCheck > 0) {
          var data = await getMaKinaIDAndStokIsmiForSecondButton(
              barkodAfterOlukluSelectedItems[index]["BarkodID"]);
          Navigator.pop(context, [
            barkodAfterOlukluSelectedItems[index]["BarkodID"],
            data[0],
            data[1]
          ]);
          EasyLoading.dismiss();
        } else {
          showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", LocaleKeys.bobbinNotVisibleProduct_text.tr());
        }
      } else {
        showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", LocaleKeys.bobbinNotVisibleProduct_text.tr());
      }
    } else if (durum == 1) {
      showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", LocaleKeys.bobbinCancel_text.tr());
    } else if (durum == 2) {
      showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", "${LocaleKeys.bobbinDelete_text.tr()}");
    } else if (durum == 3) {
      showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", "${LocaleKeys.bobbinFinish_text.tr()}.");
    } else {
      showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", "${LocaleKeys.bobbinNotDefined_text.tr()}.");
    }
  }

  controlForBobinImalat(barkod) async {
    var dbClient = await db;
    var query =
        "Select  HareketID from Depo_Hareketleri where Durum=0 and Modul=7 and Depo_Hareketleri.LotNo= '$barkod' order by DepoHareketID desc limit 1";
    var result = await dbClient.rawQuery(query);
    print(result);
    return result[0]["HareketID"];
  }

  controlForStok(barkod) async {
    var dbClient = await db;
    var query =
        "SELECT SUM(Depo_Hareketleri.Miktar) Stok FROM Depo_Hareketleri WHERE (Depo_Hareketleri.Durum = 0) AND Depo_Hareketleri.HareketID IN (17,18)AND Depo_Hareketleri.Modul = 7 AND Depo_Hareketleri.LotNo = '$barkod'";
    var result = await dbClient.rawQuery(query);
    print(result);
    return result[0]["Stok"];
  }

  getMaKinaIDAndStokIsmiForSecondButton(barkodID) async {
    var dbClient = await db;
    var query =
        "SELECT  Depo_Hareketleri.MakinaID, Stok_Karti.StokIsmi FROM Stok_Karti_Barkod INNER JOIN Depo_Hareketleri ON Stok_Karti_Barkod.BarkodID = Depo_Hareketleri.LotNo inner join Stok_Karti on Stok_Karti.StokID=Stok_Karti_Barkod.StokID WHERE Depo_Hareketleri.Miktar > 0 AND (Depo_Hareketleri.Durum = 0) AND Stok_Karti_Barkod.BarkodID = $barkodID ORDER BY Depo_Hareketleri.DepoHareketID DESC limit 1";
    var result = await dbClient.rawQuery(query);
    print(result.length);
    print(result);
    return [result[0]["MakinaID"].toString(), result[0]["StokIsmi"]];
  }
}
