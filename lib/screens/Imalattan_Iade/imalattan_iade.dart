import 'dart:io';
import 'package:bss_mobile_premium/db_helper_class/db_barcode_control_helper.dart';
import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:expandable/expandable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:solar_datepicker/solar_datepicker.dart';
import 'package:sqflite/sqflite.dart';
import '../../data_model/depolar.dart';
import '../../data_model/holler.dart';
import '../../data_model/makinalar.dart';
import '../../data_model/oluklu_depolar.dart';
import '../../data_model/services/holler_services.dart';
import '../../data_model/services/makinalar_services.dart';
import '../../data_model/services/oluklu_depolar_services.dart';
import '../../data_model/services/update_function.dart';
import '../../db_helper_class/db_save_helper.dart';
import '../../helper/alert.dart';
import '../../helper/languages/languages_model.dart';
import '../../helper/languages/locale_keys.g.dart';
import '../../helper/widgetHelper.dart';
import '../Home/home.dart';

class ImalattanIade extends StatefulWidget {
  ImalattanIade({Key? key}) : super(key: key);

  @override
  _ImalattanIadeState createState() => _ImalattanIadeState();
}

class _ImalattanIadeState extends State<ImalattanIade> {
  //region DEĞİŞKENLER
  var db = openDatabase('BSSBobinDB.db');
  var dbLog = openDatabase('BSSBobinDBLog.db');

  // bool isSaveButtonActive = false;
  DateTime selectedDate = DateTime.now();
  String tarihKontrolValue = "";

  //Oluklu Depo Veriler
  var _olukluDepolar = OlukluDepolar();
  var _olukluDepolarService = OlukluDepolarService();
  List<OlukluDepolar> _olukluDepolarList = <OlukluDepolar>[];
  List _imalatCikanlarList = [];
  String? olukluDepoText = "";
  int? olukluDepoID;
  bool olukluDepoTextSelected = false;
  int? tappedIndex;

  //Holler
  String? holText = "";
  int? holID;
  bool holTextSelected = false;
  var _hol = Holler();
  var _hollerService = HollerService();
  List<Holler> _holList = <Holler>[];
  List<Makinalar> _makinaList = <Makinalar>[];

  List barkodAfterOlukluSelectedItems = [];
  String barkodAfterOlukluSelectedText = "";
  int? barkodAfterOlukluID;
  bool barkodAfterOlukluSelected = false;

  String? _makinaIDText;
  late String _miktarFromDB;
  var _stokIsmiTextFieldController = new TextEditingController();
  var _bobinBarkodNoTextField = new TextEditingController();

  //var _barcodeTextFieldController = new TextEditingController();
  var _kgTextFieldController = new TextEditingController();
  FocusNode? barcodeFocusNode;
  List<Depolar> tumDepolar = <Depolar>[];
  String? depoName;
  bool depoNameSelected = false;
  int? depoID;
  var _makinalarService = MakinalarService();
  String? makinaText = "";
  int? makinaID;
  bool makinaTextSelected = false;

  var pDateNow;
  String? pselectedDate;
  bool buttonEnabled = true;
  double cikisMiktar = 0;
  List<Map<String, dynamic>> stockInfo = [];
  int? stockIndex;

  //endregion

  @override
  void initState() {
    super.initState();
    Init();
  }

  Init() async {
    pDateNow = Jalali.fromDateTime(DateTime.now()).formatter;
    pselectedDate = '${pDateNow.yyyy}/${pDateNow.mm}/${pDateNow.dd}';
    barcodeFocusNode = FocusNode();
    if (globals.updatePeriod == 1) {
      await generalUpdateFunction(false);
    }
    barcodeFocusNode!.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${LocaleKeys.returnProduction_text.tr().toUpperCase()}"),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: FloatingActionButton(
                  // backgroundColor: Color.fromRGBO(113, 6, 39, 1),
                  onPressed: () async {
                    await generalUpdateFunction(false);
                  },
                  child: Center(child: Icon(Icons.download)),
                  // child: Center(child: Text("Güncelle")),
                )),
            // Container(
            //     alignment: Alignment.center,
            //     padding: new EdgeInsets.only(right: 20),
            //     child: Text(widget.depoName.toString()))
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              imalataCikanlar(context),
              BarcodeRow(
                barcodeTextFieldController: _bobinBarkodNoTextField,
                getTextFieldText: getBarcodeInfos,
                errorOnBarcodeControl: () {},
                barcodeFocusNode: barcodeFocusNode,
              ),
              SizedBox(height: 5,),
              Text("STOKLAR : ", style: TextStyle(fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.fromLTRB(5,0,5,0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      height: 0,
                      thickness: 2,
                      color: Colors.blueGrey,
                    ),
                    itemCount: stockInfo.length,
                    itemBuilder: (context, index) => Container(
                        color: stockIndex == index ? Colors.green : Colors.white10,
                        child: ListTile(
                            title: Text(
                              '${stockInfo[index]["StokIsmi"]}',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              setState(() {
                                stockIndex = index;
                              });
                            })),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5,5,5,0),
                child: buildDepoAndMakina(),
              ),
              ButtonsRow(
                onKapatPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MenuButtons()),
                    ModalRoute.withName('/'),
                  );
                },
                onYeniPressed: () {
                  yeniButtonClicked(0);
                },
                onKaydetPressed: () {
                  isSaveButtonActive();
                },
              ),
            ],
          ),
        ));
  }
  Row buildDepoAndMakina() {
    return Row(
      children: [

        Text("MAKİNA : "),
        Expanded(
          child: RaisedButton(
            color: Colors.black45,
            onPressed: () {},
            child: Text(
              makinaTextSelected
                  ? makinaText!
                  : "",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          "İSTASYON : ",
        ),
        Expanded(
            child: RaisedButton(
              color: Colors.black45,
              onPressed: () => {},
              child: Text(
                olukluDepoTextSelected ? olukluDepoText! : "",
                style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )),
      ],
    );
  }

  Widget imalataCikanlar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
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
                                flex: 0,
                                child: Text("MAKİNA : ", style: textStyle)),
                            Expanded(
                              flex: 11,
                              child: RaisedButton(
                                color: Colors.black45,
                                onPressed: buttonEnabled
                                    ? () => getAllMakinalar()
                                    : null,
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
                                flex: 0,
                                child: Text("DEPO : ", style: textStyle)),
                            Expanded(
                              flex: 11,
                              child: RaisedButton(
                                color: Colors.black45,
                                onPressed: buttonEnabled ? () => {} : null,
                                child: Text(
                                  depoNameSelected ? depoName! : "",
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
                        height: MediaQuery.of(context).size.height * 0.2,
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
                                                      '${_imalatCikanlarList[index]["StokIsmi"]}'),
                                            ]),
                                      )),
                                  onTap: () {
                                    setState(() {
                                      // tappedIndex == index ? tappedIndex = null : tappedIndex = index;
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

  //regionBARCODE
  getBarcodeInfos(value) async {
    stockInfo = List.from(await stockCountControl(_bobinBarkodNoTextField.text));
    print(stockInfo);
    if(stockInfo.length == 0){
      EasyLoading.showInfo("Bu Barkodun Üretime Çıkışı Yok.");
      return;
    }
    stockIndex = 0;
    makinaText = stockInfo.first["MakinaAdi"];
    makinaTextSelected = true;
    olukluDepoText = stockInfo.first["IstasyonAd"];
    olukluDepoTextSelected = true;
  }

  stockCountControl(value) async {
    var query =
        '''select Birim1Miktari as Miktar,sk.RefAd as StokIsmi,skb.Id as BarkodId,sk.Id as StokId,ub.Durum,ub.BobinSyncStatus,mk.RefAd as MakinaAdi,od.IstasyonBolumlerAd as IstasyonAd from Depo_Hareketleri as dh
                    inner join Stok_Karti_Barkod as skb on dh.BarkodId = skb.Id
                    inner join Stok_Karti as sk on dh.StokId = sk.Id
					left join UretimBarkodHavuz as ub on dh.StokId = ub.StokUrunMasterId And skb.Id = ub.BarkodId
					inner join Makinalar as mk on mk.Id = ub.IstasyonId
					inner join OlukluDepolar as od on od.IstasyonBolumlerId = ub.IstasyonBolumlerId
                    where skb.Barkod = $value and  ub.Durum = 1 order by dh.Id desc  LIMIT 1''';
    var dbClient = await db;
    var result = await (await dbClient).rawQuery(query);
    setState(() {});
    return result;
  }

  // getBarcodeInfos(value) async {
  //   var result = await CheckBarkodDb.getLastMove(value);
  //   var stockCount = await CheckBarkodDb.getStockCount(value);
  //   if (result[1] == 18) {
  //     cikisMiktar = double.parse(result[2].toString())*-1;
  //     if(stockCount == 0){
  //       var result = await CheckBarkodDb.getBarcodeInfo(value);
  //       olukluDepoID = result[0]["KarsiDepoId"] as int?;
  //       depoID = result[0]["DepoId"] as int?;
  //       _makinaIDText = result[0]["MakinaId"].toString();
  //       _stokIsmiTextFieldController.text = result[0]["RefAd"] as String;
  //       buttonEnabled = false;
  //     }
  //     else{
  //       EasyLoading.showError("${LocaleKeys.bobbinFinish_text.tr()}");
  //     }
  //   }
  //   else {
  //     showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", result[0]);
  //   }
  //
  // }

  getImalattanCikanlar() async {
    // EasyLoading.show(dismissOnTap: true, maskType: EasyLoadingMaskType.black);
    var dbClient = await db;
    var query = " select ub.Id,ub.BarkodId,ub.Barkod,sk.RefAd from UretimBarkodHavuz as ub inner join Stok_Karti as sk on sk.Id = ub.StokUrunMasterId  where ub.Durum = 1 And ub.IstasyonId = $makinaID order by ub.Id desc";
    var result = await dbClient.rawQuery(query);
    if (result.isEmpty) {
      return;
    }
    for (var i = 0; i < result.length; i++) {
        _imalatCikanlarList.add({
          'LotNo': result[i]['BarkodId'],
          'BobinNo': result[i]['Barkod'],
          'StokIsmi': result[i]['RefAd'],
        });

    }
    print('_imalatCikanlarList $_imalatCikanlarList');
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
  if (_bobinBarkodNoTextField.text.isNotEmpty) {
      await checkForSavingToDB();
      return true;
    }

  else {
      EasyLoading.showInfo("${LocaleKeys.fillAllFields_text.tr()}");
      return false;
    }
  }
  checkForSavingToDB() async {
    try{
      var dbClient = await db;
      var query='';
      if(stockInfo[stockIndex!]["BobinSyncStatus"] == 1){
         query = '''UPDATE UretimBarkodHavuz SET Durum = 0
      WHERE BarkodId =${stockInfo[stockIndex!]["BarkodId"]} AND StokUrunMasterId = ${stockInfo[stockIndex!]["StokId"]} ''';
      }
      else{
         query = '''UPDATE UretimBarkodHavuz SET Durum = 0,BobinSyncStatus=2
      WHERE BarkodId =${stockInfo[stockIndex!]["BarkodId"]} AND StokUrunMasterId = ${stockInfo[stockIndex!]["StokId"]} ''';
      }
      print(query);
      await dbClient.rawQuery(query);
      setState(() {
        stockInfo.removeAt(stockIndex!);
      });
      onSuccess();
    }
    catch(ex){
      EasyLoading.showError("Hata : $ex");
    }


  }


  onSuccess() async {
    yeniButtonClicked(1);
    EasyLoading.dismiss();
    if (globals.updatePeriod == 1) {
      await generalUpdateFunction(false);
    }
    EasyLoading.showSuccess("${LocaleKeys.saved_text.tr()}.");
  }

  //endregion

  //region FUNCTİONS
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
    _bobinBarkodNoTextField.text = "${_imalatCikanlarList[index]["BobinNo"]}";
    getBarcodeInfos(_imalatCikanlarList[index]["BobinNo"]);
    depoID = _imalatCikanlarList[index]["DepoID"];
    var depo =
        tumDepolar.where((element) => element.AmbarID == depoID).toList();
    depoName = depo.length > 0 ? depo[0].AmbarIsmi : "";
    depoNameSelected = true;
    barcodeFocusNode!.unfocus();
  }

  getAllHoller() async {
    EasyLoading.show();
    if (_holList.isEmpty) {
      var categories = await _hollerService.readHoller();
      categories.forEach((depo) {
        setState(() {
          var depoModel = Holler();
          depoModel.HolID = depo['HolID'];
          depoModel.HolAdi = depo['HolAdi'];
          _holList.add(depoModel);
          EasyLoading.dismiss();
        });
      });
    }
    EasyLoading.dismiss();
    displayHolBottomSheet(context);
  }

  yeniButtonClicked(int type) {
    print(type);
    if(stockInfo.length == 0 || type == 0){
    _bobinBarkodNoTextField.clear();
    barkodAfterOlukluSelectedItems.clear();
    makinaTextSelected = false;
    makinaID = 0;
    _imalatCikanlarList = [];
    setState(() {
      barkodAfterOlukluSelected = false;
      olukluDepoTextSelected = false;
      holTextSelected = false;
      buttonEnabled = true;
      stockInfo = [];

    });
    barcodeFocusNode!.requestFocus();
    }
  }

  //endregion

  // region WİDGETS
  displayHolBottomSheet(BuildContext context) {
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
                          child: Text(
                            '${_holList[index].HolAdi}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            holTextSelected = true;
                            holText = _holList[index].HolAdi;
                            holID = _holList[index].HolID;
                            Navigator.pop(context);
                          });
                        })),
              ),
            ),
          );
        });
  }

  getAllBarkods() async {
    displayBarkodBottomSheet(context);
  }

  displayBarkodBottomSheet(BuildContext context) {
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
                itemCount: barkodAfterOlukluSelectedItems.length,
                itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                        title: Center(
                          child: Text(
                              '${barkodAfterOlukluSelectedItems[index]["BarkodID"]}'),
                        ),
                        onTap: () {
                          EasyLoading.show();
                          getBarcodeInfos(index);
                          EasyLoading.dismiss();
                        })),
              ),
            ),
          );
        });
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
                itemCount: _olukluDepolarList.length,
                itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                        title: Center(
                          child: Text('${_olukluDepolarList[index].AmbarIsmi}'),
                        ),
                        onTap: () {
                          setState(() {
                            olukluDepoTextSelected = true;
                            olukluDepoText =
                                _olukluDepolarList[index].AmbarIsmi;
                            olukluDepoID = _olukluDepolarList[index].AmbarID;
                            //getBarkodsForSecondButton();
                            Navigator.pop(context);
                          });
                        })),
              ),
            ),
          );
        });
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

  //endregion

  //regionTAKVİM
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

  buildMaterialDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      locale: Locale("tr"),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
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
      });
  }
//endregion

}
