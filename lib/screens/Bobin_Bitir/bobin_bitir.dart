import 'dart:ffi';
import 'dart:io';
import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:bss_mobile_premium/screens/Home/home.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../data_model/makinalar.dart';
import '../../data_model/oluklu_depolar.dart';
import '../../data_model/services/get_all_depolar_services.dart';
import '../../data_model/services/makinalar_services.dart';
import '../../data_model/services/oluklu_depolar_services.dart';
import '../../data_model/services/update_function.dart';
import '../../db_helper_class/db_barcode_control_helper.dart';
import '../../db_helper_class/db_save_helper.dart';
import '../../helper/alert.dart';
import '../../helper/languages/locale_keys.g.dart';
import '../../helper/widgetHelper.dart';
import 'bobin_bitir_search_modal.dart';

class BobinBitir extends StatefulWidget {

  BobinBitir({Key? key}) : super(key: key);

  @override
  _BobinBitirState createState() => _BobinBitirState();
}

class _BobinBitirState extends State<BobinBitir> {
  //region DEĞİŞKENLER
  var db = openDatabase('BSSBobinDB.db');
  var dbLog = openDatabase('BSSBobinDBLog.db');
  DateTime selectedDate = DateTime.now();

  //Oluklu Depo Veriler
  var _olukluDepolar = OlukluDepolar();
  var _olukluDepolarService = OlukluDepolarService();
  List<OlukluDepolar> _olukluDepolarList = <OlukluDepolar>[];
  String? olukluDepoText = "";
  int? olukluDepoID;
  bool olukluDepoTextSelected = false;

  List barkodAfterOlukluSelectedItems = [];
  String barkodAfterOlukluSelectedText = "";
  int? barkodAfterOlukluID;
  bool barkodAfterOlukluSelected = false;

  String? _makinaIDText;
  String _miktarFromDB = "0";
  var _stokIsmiTextFieldController = new TextEditingController();
  var _bobinBarkodNoTextField = new TextEditingController();
  var _olukluDepoTextField = new TextEditingController();
  FocusNode? barcodeFocusNode;

  String? depoName;
  int? depoID;
  List _imalatCikanlarList = [];
  int? tappedIndex;
  String? makinaText = "";
  int? makinaID;
  bool makinaTextSelected = false;
  List<Makinalar> _makinaList = <Makinalar>[];
  var _makinalarService = MakinalarService();

  //endregion
  @override
  void initState() {
    super.initState();
    barcodeFocusNode = FocusNode();
    depoName = "";
    depoID = 0;
    firstUpdate();
  }

  firstUpdate() async {
    if (globals.updatePeriod == 1) {
      await generalUpdateFunction(false);
    }
    barcodeFocusNode!.requestFocus();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${LocaleKeys.coilEnd_text.tr()}"),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: FloatingActionButton(
                  // backgroundColor: Color.fromRGBO(113, 6, 39, 1),
                  onPressed: () async {
                    await generalUpdateFunction(false);
                  },
                  child: Center(child: Icon(Icons.download)),
                )),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(children: <Widget>[
                        imalataCikanlar(context),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: BarcodeRow(
                            barcodeTextFieldController: _bobinBarkodNoTextField,
                            getTextFieldText: getBarcodeInfos,
                            errorOnBarcodeControl: errorOnBarcodeControl,
                            barcodeFocusNode: barcodeFocusNode,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: StokAdiWidget(
                            controller: _stokIsmiTextFieldController,
                          ),
                        ),
                        Column(
                          children: [
                            Text("OLUKLU DEPO :", style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500)),
                            TextField(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              controller: _olukluDepoTextField,
                              enabled: false,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black45, width: 1.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ])),
                ),
              ),
              ButtonsRow(
                onKapatPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MenuButtons()),
                    ModalRoute.withName('/'),
                  );
                },
                onYeniPressed: () {
                  yeniButtonClicked();
                },
                onKaydetPressed: () {
                  isSaveButtonActive();
                },
              ),
            ],
          ),
        ));
  }
  Widget imalataCikanlar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,0,0,5),
      child: ExpandableNotifier(
        child: Card(
          color: Colors.white24,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: false,
                  ),
                  header: Padding(
                      padding: EdgeInsets.all(0),
                      child: Text(
                        "İMALATA ÇIKANLAR",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  collapsed: SizedBox(),
                  expanded: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 0, child: Text("MAKİNA : ", style: textStyle)),
                            Expanded(
                              flex: 11,
                              child: RaisedButton(
                                color: Colors.black45,
                                onPressed:
                                    () => getAllMakinalar() ,
                                child: Text(
                                  makinaTextSelected ? makinaText! : "",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                                flex: 0, child: Text("DEPO : ", style: textStyle)),
                            Expanded(
                              flex: 11,
                              child: RaisedButton(
                                color: Colors.black45,
                                onPressed: () => {} ,
                                child: Text(
                                  depoName!,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey,
                          ),
                          itemCount: _imalatCikanlarList.length,
                          itemBuilder: (context, index) => Container(
                            // color:
                            // tappedIndex == index ? Colors.blueAccent : Colors.white,
                              margin: EdgeInsets.all(0),
                              height: 30,
                              child: ListTile(
                                  title: Container(
                                      height: 30,
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                            text:
                                            '${_imalatCikanlarList[index]["BobinNo"]} - ',
                                            style: TextStyle(
                                                color: tappedIndex == index
                                                    ? Colors.blueAccent
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                '${_imalatCikanlarList[index]["Miktar"]} - ',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              TextSpan(
                                                  text:
                                                  '${_imalatCikanlarList[index]["StokIsmi"]}'),
                                            ]),
                                      )),
                                  onTap: () {
                                    setState(() {
                                      selectExitManifact(index);
                                    });
                                  })),
                        ),
                      ),
                    ],
                  ),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 0),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //region BARCODE
  getBarcodeInfos(value) async {
    var result = await CheckBarkodDb.getLastMove(value);
    var stockCount = await CheckBarkodDb.getStockCount(value);
    print("son Hareket $result");
    if (result[1] == 18) {
      if(stockCount == 0){
        var result = await CheckBarkodDb.getBarcodeInfo(value);
        print(result);
        olukluDepoID = result[0]["KarsiDepoId"] as int?;
        depoID = result[0]["DepoId"] as int?;
        _makinaIDText = result[0]["MakinaId"].toString();
        _stokIsmiTextFieldController.text = result[0]["RefAd"] as String;
        olukluDepoTextSelected = true;
        _olukluDepoTextField.text = result[0]["IstasyonBolumlerAd"] ?? "";
        _miktarFromDB = result[0]["Miktar"].toString();

      }
      else{
        EasyLoading.showError("${LocaleKeys.bobbinFinish_text.tr()}");
      }
    }
    else {
      showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", result[0]);
    }

  }
  getImalattanCikanlar() async {
    // EasyLoading.show(dismissOnTap: true, maskType: EasyLoadingMaskType.black);
    var dbClient = await db;
    print("makina $makinaID");
    var query = "SELECT BarkodId, sk.RefAd, 0 as Miktar,  0 as DepoID,  skb.Barkod FROM Depo_Hareketleri dh inner join Stok_Karti_Barkod skb on skb.Id = dh.BarkodId inner join Stok_Karti sk on sk.Id = skb.StokID WHERE (SELECT  dh2.DepoHareketTipId  FROM    Depo_Hareketleri dh2  WHERE    dh2.BarkodId = dh.BarkodId  ORDER by dh2.Id desc LIMIT  1 ) = 17   AND (dh.MakinaID = ${makinaID}) AND datetime(dh.Tarih) >= datetime('now', '-7 days') group by dh.BarkodId";
    var result = await dbClient.rawQuery(query);
    if (result.isEmpty) {
      return;
    }
    for (var i = 0; i < result.length; i++) {
      var res = await getMiktarByLotNo(result[i]['BarkodId']);
      print("makine $res");
      var miktar = res[0]["Miktar"].toString();
      if (miktar != null) {
        _imalatCikanlarList.add({
          'LotNo': result[i]['BarkodId'],
          'BobinNo': result[i]['Barkod'],
          'Miktar': double.parse(miktar).abs(),
          'StokIsmi': result[i]['RefAd'],
          'DepoID': res[0]['DepoID']
        });
      }
    }
    setState(() {
      _imalatCikanlarList = _imalatCikanlarList;
    });
    EasyLoading.dismiss();
  }
  getMiktarByLotNo(lotNo) async {
    var dbClient = await db;
    var query =
        "SELECT Depo_Hareketleri.Miktar, Depo_Hareketleri.KarsiDepoId as DepoID FROM Stok_Karti_Barkod INNER JOIN Stok_Karti ON Stok_Karti_Barkod.StokID = Stok_Karti.Id INNER JOIN Depo_Hareketleri ON Stok_Karti_Barkod.Id = Depo_Hareketleri.BarkodId WHERE Depo_Hareketleri.BarkodId='${lotNo}' ORDER BY Depo_Hareketleri.Id DESC limit 1";

    var result = await dbClient.rawQuery(query);
    return result;
  }
  //endregion

  //region KAYDET
  isSaveButtonActive() async {
    if (_bobinBarkodNoTextField.text.isEmpty == false &&
            _stokIsmiTextFieldController.text.isEmpty == false
        ) {

      await checkForSavingToDB();
      // await getImalattanCikanlar();
      return true;
    } else {
      EasyLoading.showInfo("${LocaleKeys.fillAllFields_text.tr()}");
      return false;
    }
  }



  checkForSavingToDB() async {
    var dbClient = await db;
    var StokId = await SaveBarkodDb.getStokKartiInfo(
        _bobinBarkodNoTextField.text, dbClient);
    var dataModelList = <UpdateAndInsertDataModel>[];
    // dataModelList.add(UpdateAndInsertDataModel(
    //   barcode: _bobinBarkodNoTextField.text,
    //   kgController: _miktarFromDB,
    //   selectedDate: '${selectedDate.toIso8601String()}',
    //   depoID: olukluDepoID ?? 0,
    //   makinaId: int.parse(_makinaIDText.toString()),
    //   depoHareketTipId: 19,
    //   karsiDepoID: depoID!,
    //   stokId: StokId ?? 0,
    // ));

    var res = await SaveBarkodDb.updateAndInsertData(dataModelList,dbClient);
    res == null ?onSuccess() :EasyLoading.showError("${LocaleKeys.error_text.tr()}");
  }

  onSuccess() async {
    if (globals.updatePeriod == 1) {
      await generalUpdateFunction(false);
    }
    yeniButtonClicked();
    EasyLoading.dismiss();
    EasyLoading.showSuccess("${LocaleKeys.saved_text.tr()}");
  }
  //endregion

  //region FUNCTION
  getAllMakinalar() async {
    _makinaList = <Makinalar>[];
    var categories = await _makinalarService.readMakinalar();
    print(categories);
    categories.forEach((depo) {
      setState(() {
        var depoModel = Makinalar();
        depoModel.Id = depo['Id'];
        depoModel.MakinaIsmi = depo['RefAd'];
        _makinaList.add(depoModel);
      });
    });

    if (_makinaList.length == 1) {
      makinaTextSelected = true;
      makinaText = _makinaList[0].MakinaIsmi;
      makinaID = _makinaList[0].Id;
      getImalattanCikanlar();
    } else {
      displayBottomSheetMakina(context);
    }
  }
  void selectExitManifact(int index) async {
    tappedIndex = index;
    getBarcodeInfos(
        _bobinBarkodNoTextField.text);
    barcodeFocusNode!.unfocus();
  }

  yeniButtonClicked() {
    _bobinBarkodNoTextField.clear();
    _stokIsmiTextFieldController.clear();
    _olukluDepoTextField.clear();
    _olukluDepolarList.clear();
    barkodAfterOlukluSelectedItems.clear();
    makinaTextSelected = false;
    makinaID = 0;
    _imalatCikanlarList = [];
    setState(() {
      barkodAfterOlukluSelected = false;
      olukluDepoTextSelected = false;
    });
    selectedDate = DateTime.now();
  }

  errorOnBarcodeControl() {
    _stokIsmiTextFieldController.clear();
    _olukluDepoTextField.clear();

    setState(() {
      olukluDepoTextSelected = false;
    });
    selectedDate = DateTime.now();
  }


  displayBottomSheetMakina(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                ),
                itemCount: _makinaList.length,
                itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                        title: Center(
                          child: Text('${_makinaList[index].MakinaIsmi}'),
                        ),
                        onTap: () {
                          setState(() {
                            makinaTextSelected = true;
                            makinaText = _makinaList[index].MakinaIsmi;
                            makinaID = _makinaList[index].Id;
                            _imalatCikanlarList = [];
                            print(_makinaList);
                            getImalattanCikanlar();
                            Navigator.pop(context);
                          });
                        })),
              ),
            ),
          );
        });
  }

  displayDepoBottomSheet(BuildContext context, _depoList) {
    print(
        "_depoList.length ${_depoList.length} _depoList $_depoList  ${_depoList[0]}");
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                ),
                itemCount: _depoList.length,
                itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                        title: Center(
                          child: Text(
                            '${_depoList[index]["AmbarIsmi"]}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            depoName = _depoList[index]["AmbarIsmi"];
                            depoID = _depoList[index]["AmbarID"];
                            Navigator.pop(context);
                          });
                        })),
              ),
            ),
          );
        });
  }
//endregion
}
