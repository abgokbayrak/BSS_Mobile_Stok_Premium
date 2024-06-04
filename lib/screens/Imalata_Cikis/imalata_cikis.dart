import 'dart:io';
import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_datepicker/solar_datepicker.dart';
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

class ImalataCikis extends StatefulWidget {

  // In the constructor, require a Todo.
  ImalataCikis({Key? key})
      : super(key: key);

  @override
  _ImalataCikisState createState() => _ImalataCikisState();
}

class _ImalataCikisState extends State<ImalataCikis> {
  //region DEĞİŞKENLER
  var db = openDatabase('BSSBobinDB.db');
  var dbLog = openDatabase('BSSBobinDBLog.db');
  String dropdownValue = '';
  DateTime selectedDate = DateTime.now();
  var pDateNow;
  String? pselectedDate;
  String? makinaText = "";
  int? makinaID = 0;
  int? makinaDepoID = 0;
  bool makinaTextSelected = false;
  String tarihKontrolValue = "";
  var _makina = Makinalar();
  var _makinalarService = MakinalarService();
  List<Makinalar> _holList = <Makinalar>[];

  var _olukluDepolarService = OlukluDepolarService();
  List<OlukluDepolar> _olukluDepolarList = <OlukluDepolar>[];
  int? tappedIndex;
  int? stoklarIndex;
  List<dynamic> _depolarList = <dynamic>[];

  // final List<TextEditingController> _kgTextFieldController = List<TextEditingController>.filled(5, TextEditingController());
  late List<TextEditingController> _kgTextFieldController = [];
  late List<TextEditingController> _stokIsmiTextFieldController = [];
  var _barcodeTextFieldController = new TextEditingController();
  String? depoName;
  int? depoID;
  bool isBarcodeTextFieldEnabled = false;

  List<Map<String, dynamic>> stockInfo = [];
  TextStyle textFieldStyle = TextStyle(fontSize: 20.0, color: Colors.black);
  var textFieldBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black45, width: 2.0),
  );
  FocusNode? barcodeFocusNode;
  //endregion
  @override
  void initState() {
    super.initState();
    pDateNow = Jalali.fromDateTime(DateTime.now()).formatter;
    pselectedDate = '${pDateNow.yyyy}/${pDateNow.mm}/${pDateNow.dd}';
    depoName = "";
    depoID = 0;
    barcodeFocusNode = FocusNode();
    tappedIndex = 0;

    getAllOlukluDepolar(makinaID);
    getAllMakinalar();
    firstUpdate();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${LocaleKeys.outProduction_text.tr()}"),
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
            Expanded(child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: BarcodeRow(
                      barcodeTextFieldController: _barcodeTextFieldController,
                      getTextFieldText: getBarcodeInfos,
                      errorOnBarcodeControl: errorOnBarcodeControl,
                      barcodeFocusNode: barcodeFocusNode,
                    ),
                  ),
                  Text("STOKLAR\\MİKTAR : ",style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                        height: 0,
                        thickness: 2,
                        color: Colors.blueGrey,
                      ),
                      itemCount: stockInfo.length,
                      itemBuilder: (context, index) => Container(

                          color: stoklarIndex == index ? Colors.green : Colors.white,
                          child: ListTile(
                            dense: true,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${stockInfo[index]["StokIsmi"]} ',textAlign: TextAlign.start,maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 36,
                                    color: Colors.black,
                                    margin: EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  Expanded(

                                    flex: 0,
                                    child: Text(
                                      '${stockInfo[index]["Miktar"]}',textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  stoklarIndex = index;
                                });
                              })),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: buildDepoAndMakina(),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                        height: 0,
                        thickness: 2,
                        color: Colors.blueGrey,
                      ),
                      itemCount: _olukluDepolarList.length,
                      itemBuilder: (context, index) => Container(
                        height: 40,
                          color: tappedIndex == index ? Colors.blueGrey : Colors.white,
                          // margin: EdgeInsets.all(5),
                          // height: 40,
                          child: ListTile(
                              title: Container(
                                child: Text(
                                  '${_olukluDepolarList[index].AmbarIsmi}',
                                  // textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                // margin: EdgeInsets.symmetric(vertical: 4),
                                // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                              ),
                              onTap: () {
                                setState(() {
                                  tappedIndex = index;
                                });
                              })),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ]),
              ),
            )),
            ButtonsRow(
              onKapatPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
              },
              onYeniPressed: () {
                yeniButtonClicked(0);
              },
              onKaydetPressed: () {
                isSaveButtonActive();
              },
            )
          ],
        ),
      ),
    );
  }

  //region BARKOD İŞLEMLER
  checkStok(value) async {
    var query =
        "SELECT SUM(Depo_Hareketleri.Miktar) Stok FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod on Depo_Hareketleri.LotNo=Stok_Karti_Barkod.BarkodID WHERE (Depo_Hareketleri.Durum = 0) AND Depo_Hareketleri.HareketID NOT IN (17,18)AND Depo_Hareketleri.Modul = 7 AND Stok_Karti_Barkod.BobinNo = '$value'";
    var dbClient = await db;
    var result = await dbClient.rawQuery(query);
    print("res $result");
    return result[0]["Stok"];
  }

  getInfo(value) async {
    var query =
        "SELECT Depo_Hareketleri.Miktar, Stok_Karti.StokIsmi, Depo_Hareketleri.AmbarID FROM Stok_Karti_Barkod INNER JOIN Stok_Karti ON Stok_Karti_Barkod.StokID = Stok_Karti.StokID INNER JOIN Depo_Hareketleri ON Stok_Karti_Barkod.BarkodId = Depo_Hareketleri.LotNo WHERE Stok_Karti_Barkod.BobinNo = $value AND (Depo_Hareketleri.HareketID <> 17 AND Depo_Hareketleri.HareketID <> 18) AND Depo_Hareketleri.Modul IN (7) AND (Depo_Hareketleri.Durum = 0) ORDER BY Depo_Hareketleri.DepoHareketID DESC limit 1";
    var dbClient = await db;
    var result = await dbClient.rawQuery(query);
    print("res $result");
    return result;
  }

  fillTheTextFields() async {
    stockInfo = List.from(await stockCountControl(_barcodeTextFieldController.text));
    if(stockInfo.length == 0){
      EasyLoading.showInfo("Bu Barkodun Stoğu Olmadığından Çıkış Yapamazsınız.");
    }
    var result = await CheckBarkodDb.getBarcodeInfo(_barcodeTextFieldController.text);
    setState(() {
      depoID = result[0]["DepoHareketTipId"] == 18 ? result[0]["KarsiDepoId"] as int? : result[0]["DepoId"] as int?;
      var depo = _depolarList.where((element) => element["Id"] == depoID).toList();
      if (depo.length == 0) {
        showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}",
            LocaleKeys.bobbinNoneWareHouse_text.tr());
      } else {
        depoName = depo[0]["DepoAdi"];
        // _kgTextFieldController.text = result[0]["Miktar"].toString();
        // _stokIsmiTextFieldController.text = result[0]["RefAd"] as String;
      }
    });
  }

   stockCountControl(value) async {
    var query = '''select  DISTINCT dh.Id,Birim1Miktari as Miktar,RefAd as StokIsmi,skb.Id as BarkodId,sk.Id as StokId,ub.Durum from Depo_Hareketleri as dh
                    inner join Stok_Karti_Barkod as skb on dh.BarkodId = skb.Id
                    inner join Stok_Karti as sk on dh.StokId = sk.Id
					left join UretimBarkodHavuz as ub on dh.StokId = ub.StokUrunMasterId And skb.Id = ub.BarkodId
                    where skb.Barkod = $value and (ub.Durum IS NULL or ub.Durum = 0) order by dh.Id desc  LIMIT 1;''';
    var dbClient = await db;
    var result = await (await dbClient).rawQuery(query);
    setState((){

    });
    return result;
  }
  checkBarcodeFromDB(value) async {

    stoklarIndex = 0;
    var result = await CheckBarkodDb.getLastMove(_barcodeTextFieldController.text);
    print(result);
    if (result[1] == 17) {
      fillTheTextFields();
    }
    else{
      EasyLoading.showError(result[0]);
    }
  }

  getBarcodeInfos(value) async {
    // EasyLoading.show();
    await checkBarcodeFromDB(_barcodeTextFieldController.text);
  }
  errorOnBarcodeControl() {
    _kgTextFieldController.clear();
    _stokIsmiTextFieldController.clear();
    selectedDate = DateTime.now();
  }

  //endregion

  //region KAYDETME İŞLEMLERİ
  isSaveButtonActive() async {
    print(tappedIndex);
    print(_olukluDepolarList.length);
    if(_olukluDepolarList.length == 0){
        EasyLoading.showInfo("İstasyon bölümü seçmediniz.");
      }
    else if (
        _barcodeTextFieldController.text.isNotEmpty && makinaID != 0 &&
        makinaTextSelected == true && tappedIndex! >= 0 && stoklarIndex! >= 0) {
      await checkForSavingToDB();
      return true;
    }
    else if(makinaID == 0 || makinaID == null) {
      EasyLoading.showInfo("Makina seçiniz.");
    }
    else if(stoklarIndex == null) {
      EasyLoading.showInfo("Stok seçiniz.");
    }
    else {
      EasyLoading.showInfo("${LocaleKeys.fillAllFields_text.tr()}");
      return false;
    }
  }
  checkForSavingToDB() async {
    try{
      var dbClient = await db;
      var query = '''INSERT INTO UretimBarkodHavuz (BarkodId, IstasyonId, UretimSiparisId, StokUrunMasterId, Durum, Aktif, IsDeleted, CreatedById, ModifiedById, RecVersion, DbTableId, Barkod, OtomasyonDurum, IstasyonBolumlerId, AyakNumara, BobinSyncStatus)
                 VALUES (${stockInfo[stoklarIndex!]["BarkodId"]}, ${makinaID}, NULL, ${stockInfo[stoklarIndex!]["StokId"]}, 1, 1, 0, 1, 1, 1, 541, ${_barcodeTextFieldController.text}, 0,${_olukluDepolarList[tappedIndex!].AmbarID}, 0,1);''';
      var dataModelList = <UpdateAndInsertDataModel>[];
      print(makinaDepoID);
      if(depoID != makinaDepoID){
        transferHareket(dataModelList);
        var res = await SaveBarkodDb.updateAndInsertData(dataModelList,dbClient);
      }
      await dbClient.rawQuery(query);
      setState(() {
        stockInfo.removeAt(stoklarIndex!);
      });
      onSuccess();
    }
    catch(ex){
      EasyLoading.showError("Hata : $ex");
    }
  }
  transferHareket(dataModelList){

      dataModelList.add(UpdateAndInsertDataModel(
          barcode: _barcodeTextFieldController.text,
          kgController: stockInfo[stoklarIndex!]["Miktar"].toString(),
          selectedDate: '${DateTime.now().toIso8601String()}',
          depoID: depoID!,
          karsiDepoID: makinaDepoID ?? 0,
          stokId: int.parse(stockInfo[stoklarIndex!]["StokId"].toString()),
          fabrikaId: globals.factoryId,
          makinaId:makinaID ?? 0,
          depoHareketTipId: 9,
          depoHareketYonuId: 3
      ));

      dataModelList.add(UpdateAndInsertDataModel(
          barcode: _barcodeTextFieldController.text,
          kgController: stockInfo[stoklarIndex!]["Miktar"].toString(),
          selectedDate: '${DateTime.now().toIso8601String()}',
          depoID: makinaDepoID ?? 0,
          fabrikaId: globals.factoryId,
          stokId: int.parse(stockInfo[stoklarIndex!]["StokId"].toString()),
          makinaId:makinaID ?? 0,
          depoHareketTipId: 8,
          depoHareketYonuId: 3

      ));
  }
  onSuccess() async {
    yeniButtonClicked(1);
    EasyLoading.dismiss();
    if (globals.updatePeriod == 1) {
      await generalUpdateFunction(false);
    }
    EasyLoading.showSuccess("${LocaleKeys.saved_text.tr()}.");
    barcodeFocusNode!.requestFocus();
  }
  //endregion

//gal 75 , 1909-2630
  //region FUNCTIONS
  firstUpdate() async {
    if (globals.updatePeriod == 1) {
      await generalUpdateFunction(false);
    }
    barcodeFocusNode!.requestFocus();
  }


  getAllOlukluDepolar(int? makineId) async {
    _olukluDepolarList = <OlukluDepolar>[];
    // var categories = await _olukluDepolarService.readOlukluDepolar();
    var query = '''select * from OlukluDepolar where MakineId = $makineId''';
    print("query cat $query");
    var dbClient = await db;
    var categories = await dbClient.rawQuery(query);
    print("cat $categories");
    categories.forEach((depo) {
      setState(() {
        var depoModel = OlukluDepolar();
        depoModel.AmbarID = int.parse(depo['IstasyonBolumlerId'].toString());
        depoModel.AmbarIsmi = depo['IstasyonBolumlerAd'].toString();
        _olukluDepolarList.add(depoModel);
      });
    });
    print(_olukluDepolarList);
    _depolarList = await getAllDepolar();

    // displayBottomSheet(context);
  }

  getAllMakinalar() async {
    _holList = <Makinalar>[];
    var categories = await _makinalarService.readMakinalar();
    categories.forEach((depo) {
      setState(() {
        var depoModel = Makinalar();
        depoModel.Id = depo['Id'];
        depoModel.MakinaIsmi = depo['RefAd'];
        depoModel.DepoId = depo['DepoId'];
        _holList.add(depoModel);
      });
    });
    print(_holList);
    if (_holList.length == 1) {
      makinaTextSelected = true;
      makinaText = _holList[0].MakinaIsmi;
      makinaID = _holList[0].Id;
      makinaDepoID = _holList[0].DepoId;
    }
    else if (_holList.length > 1) {
      makinaTextSelected = true;
      makinaText = _holList[0].MakinaIsmi;
      makinaID = _holList[0].Id;
      makinaDepoID = _holList[0].DepoId;
      displayBottomSheet(context);
    }
    else{
      EasyLoading.showInfo("Makinalar Bulunamadı");
    }
  }
  yeniButtonClicked(int type) {
    if(stockInfo.length == 0 || type == 0){
      _barcodeTextFieldController.clear();
      barcodeFocusNode!.requestFocus();
      depoID = null;
      depoName = "";
      stockInfo = [];
    }
  }

  //endregion
  //region TAKVİM
  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
              initialDateTime: selectedDate,
              minimumYear: 2000,
              maximumYear: 2025,
            ),
          );
        });
  }

  Future buildMaterialPDatePicker(context) async {
    final picked = await showSolarDatePicker(
        context: context,
        initialDate: DateTime.now(),
        locale: Locale('fa', 'IR'),
        firstDate: DateTime.now().subtract(Duration(days: 100 * 365)),
        lastDate: DateTime.now(),
        isPersian: true,
        initialDatePickerMode: SolarDatePickerMode.day);
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        final f = Jalali.fromDateTime(picked).formatter;
        pselectedDate = '${f.yyyy}/${f.mm}/${f.dd}';
        print(selectedDate);
        print(pselectedDate);
      });
  }

  buildMaterialDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      locale: context.locale,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      helpText: '${LocaleKeys.chooseDate_text.tr()}',
      cancelText: LocaleKeys.cancel_text.tr(),
      confirmText: LocaleKeys.choose_text.tr().toUpperCase(),
      errorFormatText: 'Geçerli bir tarih giriniz.',
      errorInvalidText: 'Geçerli bir tarih giriniz.',
      fieldLabelText: LocaleKeys.date_text.tr(),
      fieldHintText: 'mm/dd/yyyy',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        print(selectedDate);
      });
  }
  _selectDate(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }
  //endregion
  //region WİDGETS
  onTapDepoRightBarButton() async {
    if (_depolarList.length == 1) {
      showAlertWithOKButton(context, "${LocaleKeys.wareHouseCount_text.tr()}", "${LocaleKeys.thereIsOne_text.tr()}");
    } else {
      displayDepoBottomSheet(context, _depolarList);
    }
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
                            print("depolls $_depoList");
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
  Row buildDepoAndMakina() {
    return Row(
      children: [
        Text(
          "DEPO : ",
        ),
        Expanded(
            child: RaisedButton(
              color: Colors.black45,
              onPressed: () => {},
              // onTapDepoRightBarButton(),
              child: Text(
                depoName!,
                style: TextStyle(
                    fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )),
        SizedBox(
          width: 5,
        ),
        Text("MAKİNA : "),
        Expanded(
          child: RaisedButton(
            color: Colors.black45,
            onPressed: () => getAllMakinalar(),
            child: Text(
              makinaTextSelected
                  ? makinaText!
                  : "${LocaleKeys.chooseMachine_text.tr()}",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
  displayBottomSheet(BuildContext context) {
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
                itemCount: _holList.length,
                itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                        title: Center(
                          child: Text('${_holList[index].MakinaIsmi}'),
                        ),
                        onTap: () {
                          setState(() {
                            makinaTextSelected = true;
                            makinaText = _holList[index].MakinaIsmi;
                            makinaID = _holList[index].Id;
                            makinaDepoID = _holList[index].DepoId;
                            Navigator.pop(context);
                            getAllOlukluDepolar(makinaID);
                            print(makinaDepoID);
                          });
                        })),
              ),
            ),
          );
        });
  }

//endregion
}

