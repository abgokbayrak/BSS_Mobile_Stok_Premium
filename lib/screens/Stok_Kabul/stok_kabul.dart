import 'dart:io';
import 'package:bss_mobile_premium/db_helper_class/db_barcode_control_helper.dart';
import 'package:bss_mobile_premium/db_helper_class/db_save_helper.dart';
import 'package:bss_mobile_premium/screens/Home/home.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:solar_datepicker/solar_datepicker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../data_model/holler.dart';
import '../../data_model/services/get_all_depolar_services.dart';
import '../../data_model/services/holler_services.dart';
import '../../data_model/services/update_function.dart';
import '../../db_helper_class/db_barkod_giris.dart';
import '../../helper/alert.dart';
import '../../helper/languages/locale_keys.g.dart';
import 'package:bss_mobile_premium/globals/globals.dart';

import '../../helper/widgetHelper.dart';

class StokKabul extends StatefulWidget {
  StokKabul({Key? key}) : super(key: key);

  @override
  _StokKabulState createState() => _StokKabulState();
}

class _StokKabulState extends State<StokKabul> {
  //region DEĞİŞKENLER
  var db = openDatabase('BSSBobinDB.db');
  var dbLog = openDatabase('BSSBobinDBLog.db');
  DateTime selectedDate = DateTime.now();
  String dropdownValue = '';
  String? holText = '';
  int? holID;
  bool holTextSelected = false;
  var _hollerService = HollerService();
  List<Holler> _holList = <Holler>[];
  late TextEditingController _kgTextFieldController;
  late TextEditingController _firmaBobinTextFieldController;
  late TextEditingController _stokIsmiTextFieldController;
  late TextEditingController _barcodeTextFieldController;
  String? depoName;
  int? depoID;
  FocusNode? barcodeFocusNode;
  var pDateNow;
  String? pselectedDate;
  double irsaliyeMiktar = 0;
  late dynamic barkodDepoHareket;

  //endregion

  //region INIT
  @override
  void initState() {
    super.initState();
    pDateNow = Jalali.fromDateTime(DateTime.now()).formatter;
    pselectedDate = '${pDateNow.yyyy}/${pDateNow.mm}/${pDateNow.dd}';
    barcodeFocusNode = FocusNode();
    depoName = "";
    depoID = 0;
    _kgTextFieldController = TextEditingController();
    _firmaBobinTextFieldController = TextEditingController();
    _stokIsmiTextFieldController = TextEditingController();
    _barcodeTextFieldController = TextEditingController();
    Init();
  }

  @override
  Init() async {
    var query = "SELECT Count(*) FROM  Depo_Hareketleri";
    var dbClient = await db;
    var result = await dbClient.rawQuery(query);
    print('tablodaki elemanlar : ${result}');

    if (globals.updatePeriod == 1) {
      await generalUpdateFunction(false);
    }
    var depoData = (await getAllDepolar())[0];
    setState(() {
      depoID = depoData["Id"];
      depoName = depoData["DepoAdi"].toString();
    });
    barcodeFocusNode!.requestFocus();
  }

  //endregion
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('tr');
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(LocaleKeys.stockAccept_text.tr().toUpperCase()),
      //   actions: <Widget>[
      //     Padding(
      //         padding: EdgeInsets.only(right: 5.0),
      //         child: FloatingActionButton(
      //           // backgroundColor: Color.fromRGBO(113, 6, 39, 1),
      //           onPressed: () async {
      //             await generalUpdateFunction(false);
      //           },
      //           child: Center(child: Icon(Icons.download)),
      //           // child: Center(child: Text("Güncelle")),
      //         )),
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: BarcodeRow(
                        barcodeTextFieldController: _barcodeTextFieldController,
                        getTextFieldText: getBarcodeInfos,
                        errorOnBarcodeControl: refreshPage,
                        barcodeFocusNode: barcodeFocusNode,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: KgAndDateRow(
                        kgTextFieldController: _kgTextFieldController,
                        selectedDate: selectedDate,
                        selectDate: _selectDate,
                        buildMaterialDatePicker: buildMaterialPDatePicker,
                        textStyle: textStyle,
                        textFieldStyle: textFieldStyle,
                        textFieldBorder: textFieldBorder,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: buildDepoAndHol(),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: TedarikciBobinNoWidget(
                        controller: _firmaBobinTextFieldController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: StokAdiWidget(
                        controller: _stokIsmiTextFieldController,
                      ),
                    ),
                  ],
                ),
              ),
            )),
            ButtonsRow(
              onKapatPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MenuButtons()),
                  ModalRoute.withName('/'),
                );
              },
              onYeniPressed: () {
                refreshPage();
              },
              onKaydetPressed: () {
                print(irsaliyeMiktar);
                isSaveButtonActive();
              },
            )
          ],
        ),
      ),
    );
  }

  //region BARKOD İŞLEMLER
  getBarcodeInfos(value) async {
    await checkBarcodeFromDB();
  }

  checkBarcodeFromDB() async {
    barkodDepoHareket = await CheckBarkodGirisDb.getBarkodDepoHareket(
        _barcodeTextFieldController.text);
    print("barkodDepoHareket $barkodDepoHareket");

    if (barkodDepoHareket.length == 0) {
      EasyLoading.showInfo("Barkod Sistemde Tanımlı Değil");
      return;
    }
    var resultGirilen = await CheckBarkodGirisDb.getBarkodGirislerMiktar(_barcodeTextFieldController.text);
    irsaliyeMiktar = double.parse(barkodDepoHareket[0]["Miktar"].toString());
    print("resultGirilen $resultGirilen");
    print("irsaliyeMiktar $irsaliyeMiktar");
    if (resultGirilen[0]["Miktar"] != null) {
      irsaliyeMiktar -= double.parse(resultGirilen[0]["Miktar"].toString());
    }
    print(irsaliyeMiktar);
    if (barkodDepoHareket.length > 0) {
      checkDepoId(barkodDepoHareket[0]["DepoId"]);
    } else {
      var result = await CheckBarkodDb.controlBarkodDefined(
          _barcodeTextFieldController.text);
      showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", result);
    }
    EasyLoading.dismiss();
  }

  checkDepoId(depoIDValue) async {
    if (depoID == depoIDValue) {
      checkSonHareket(depoIDValue);
    } else {
      showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}",
          LocaleKeys.bobbinDifferentWareHouse_text.tr());
    }
  }

  checkSonHareket(depoId) async {
    var result =
        await CheckBarkodDb.getLastMove(_barcodeTextFieldController.text);
    print(result);
    if (result[1] == 14) {
      fillTheTextFields();
    } else {
      showAlertWithOKButton(
          context, "${LocaleKeys.error_text.tr()}", result[0]);
    }
  }

  fillTheTextFields() async {

    var result =
        await CheckBarkodDb.getBarcodeInfo(_barcodeTextFieldController.text);
    print(result);
    // _stokIsmiTextFieldController.text = result.length > 0 ? result[0]["RefAd"] as String : "";
    _stokIsmiTextFieldController.text = barkodDepoHareket[0]["RefAd"];
  }

  //endregion

  //region KAYDETME İŞLEMLERİ
  isSaveButtonActive() async {
    if (irsaliyeMiktar < double.parse(_kgTextFieldController.text)) {
      EasyLoading.showInfo("Girişlerin miktarı İrsaliyedeki miktardan büyük olamaz");
    } else if (_kgTextFieldController.text.isNotEmpty &&
        _stokIsmiTextFieldController.text.isNotEmpty &&
        _barcodeTextFieldController.text.isNotEmpty &&
        int.parse(_kgTextFieldController.text.toString()) > 0) {
      await checkForSavingToDB();
      barcodeFocusNode!.requestFocus();
    } else {
      EasyLoading.showInfo("${LocaleKeys.fillAllFields_text.tr()}");
    }
  }

  checkForSavingToDB() async {
    // EasyLoading.show();
    var dbClient = await db;
    // var MakinaId = await SaveBarkodDb.getDepoHareketleriInfo(_barcodeTextFieldController.text,dbClient);
    // var StokId =await SaveBarkodDb.getStokKartiInfo(_barcodeTextFieldController.text,dbClient);
    print(barkodDepoHareket);
    var dataModelList = <UpdateAndInsertDataModel>[];
    dataModelList.add(UpdateAndInsertDataModel(
        barcode: _barcodeTextFieldController.text,
        firmaBobinController: _firmaBobinTextFieldController.text,
        kgController: _kgTextFieldController.text,
        selectedDate: '${selectedDate.toIso8601String()}',
        depoID: depoID!,
        stokId: barkodDepoHareket[0]["StokId"] ?? 0,
        makinaId: barkodDepoHareket[0]["MakinaId"] ?? 0,
        depoHareketTipId: 14,
    depoHareketYonuId: 1));
    var res = await SaveBarkodDb.updateAndInsertData(dataModelList, dbClient);
    res == null
        ? onSuccess()
        : EasyLoading.showError("${LocaleKeys.error_text.tr()}");
    print("updateAndInsertData res $res");
  }

  onSuccess() async {
    if (globals.updatePeriod == 1) {
      await generalUpdateFunction(false);
    }
    refreshPage();
    EasyLoading.showSuccess("${LocaleKeys.saved_text.tr()}.");
  }

  //endregion

  //region WİDGETS
  Row buildDepoAndHol() {
    return Row(
      children: [
        Text(
          "DEPO : ",
          style: textStyle,
        ),
        Expanded(
            child: RaisedButton(
          color: Colors.black45,
          onPressed: () => onTapDepoRightBarButton(),
          child: Text(
            depoName!,
            style: TextStyle(
                fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )),
        SizedBox(
          width: 10,
        ),
        Text("HOL : ", style: textStyle),
        Expanded(
          child: RaisedButton(
            color: Colors.black45,
            onPressed: () => {getAllHoller()},
            child: Text(
              holTextSelected ? holText! : LocaleKeys.chooseHall_text.tr(),
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

  onTapDepoRightBarButton() async {
    var depolar = await getAllDepolar();
    print(depolar);
    if (depolar.length == 1) {
      showAlertWithOKButton(context, "${LocaleKeys.wareHouseCount_text.tr()}",
          "${LocaleKeys.thereIsOne_text.tr()}");
    } else {
      displayDepoBottomSheet(context, depolar);
    }
  }

  displayDepoBottomSheet(BuildContext context, _depoList) {
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
                            '${_depoList[index]["DepoAdi"]}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            depoName = _depoList[index]["DepoAdi"];
                            depoID = _depoList[index]["Id"];
                            Navigator.pop(context);
                          });
                        })),
              ),
            ),
          );
        });
  }

  //endregion

  //region FONKSİYONLAR
  refreshPage() {
    _kgTextFieldController.clear();
    _firmaBobinTextFieldController.clear();
    _stokIsmiTextFieldController.clear();
    _barcodeTextFieldController.clear();
    setState(() {
      holTextSelected = false;
    });
    selectedDate = DateTime.now();
    barcodeFocusNode!.requestFocus();
  }

  getAllHoller() async {
    _holList = <Holler>[];
    var categories = await _hollerService.readHoller();
    categories.forEach((depo) {
      setState(() {
        var depoModel = Holler();
        depoModel.HolID = depo['Id'];
        depoModel.HolAdi = depo['KoridorAdi'];
        _holList.add(depoModel);
      });
    });
    displayBottomSheet(context);
  }

//endregion

  //region TAKVİM
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
        print(pselectedDate);
        print(selectedDate);
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
      fieldHintText: 'dd/mm/yyyy',
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
//endregion

}
