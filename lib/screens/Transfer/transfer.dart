import 'dart:convert';

import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import '../../data_model/services/get_all_depolar_services.dart';
import '../../data_model/services/update_function.dart';
import '../../db_helper_class/db_barcode_control_helper.dart';
import '../../db_helper_class/db_save_helper.dart';
import '../../helper/alert.dart';
import '../../helper/languages/locale_keys.g.dart';
import '../../helper/widgetHelper.dart';

class Transfer extends StatefulWidget {
  const Transfer({Key? key}) : super(key: key);

  @override
  State<Transfer> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  var db = openDatabase('BSSBobinDB.db');
  dynamic selectedTip;
  List<Map<String, dynamic>> tipList = [
    {'id': 7, 'name': ""},
    {'id': 8, 'name': "Transfer Giriş"},
    {'id': 9, 'name': "Transfer Çıkış"},
  ];
  bool girisCikismi = false;
  TextEditingController _barcodeTextController = new TextEditingController();
  TextEditingController _miktarTextController = new TextEditingController();
  TextStyle baslik = TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold,letterSpacing: 1);
  String? malzemeDepoName = "";
  int? malzemeDepoID = 0;
  int? malzemeFabrikaID = 0;
  String? karsiDepoName = "";
  int? karsiDepoID = 0;
  int? karsiFabrikaId = 0;
  int kontrolDepoID = 0;
  FocusNode? barcodeFocusNode;
  var depolar = [];

  @override
  void initState() {
    selectedTip = tipList[0];
    barcodeFocusNode = FocusNode();
    print(globals.factoryId);
    Init();
  }
  Init() async {
    depolar = await getAllDepolar();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TRANSFER"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildDropDown(),
              SizedBox(height: 5,),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Row(
                  children: [

                    Expanded(
                      flex: 4,
                      child: Text("BARKOD : ",style: baslik,),
                    ),
                    Expanded(
                      flex: 10,
                      child: TextFormField(
                        controller: _barcodeTextController,
                        keyboardType: TextInputType.number,
                        style: textFieldStyle,
                        focusNode: barcodeFocusNode,
                        onFieldSubmitted: (_) async {
                          if (_barcodeTextController.text.isNotEmpty &&
                              _barcodeTextController.text.length != 1) {
                            await getBarcodeInfos(_barcodeTextController.text);
                          } else {
                            refreshPage();
                          }
                        },
                        decoration: InputDecoration(
                          isDense: true,                      // Added this
                          contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder(),
                          enabledBorder: textFieldBorder,

                        ),

                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Text("MALZEME DEPOSU  :  ",style: baslik,)),
                  Expanded(
                    flex: 10,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.6,
                      child: RaisedButton(
                        color: Colors.black45,
                        onPressed: () =>{},
                        child: Text(malzemeDepoName!,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Text("KARŞI DEPO :  ",style: baslik,)),
                  Expanded(
                    flex: 10,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.6,
                      child: RaisedButton(
                        color: Colors.black45,
                        onPressed: () async =>selectedTip["id"] == 8 ? null : {await onTapDepoButton()},
                        child: Text(karsiDepoName!,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5,),

              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      "MİKTAR  :  ",
                      style: baslik,
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: TextField(
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      controller: _miktarTextController,
                      style: textFieldStyle,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: textFieldBorder,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

               kontrolDepoID == 9 ?
               Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                  ),
                  child: Center(
                    child: Text(
                        "Bu Barkodla Yalnızca Transfer Giriş Yapabilirsiniz",
                        style: TextStyle(color: Colors.white)),
                  )) : SizedBox(),
              SizedBox(height: 10,),

              SizedBox(
                width: MediaQuery.of(context).size.width*0.9,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: ()async{await isSaveButtonActive();},
                  icon: Icon(Icons.save, color: Colors.white),
                  label: Text(
                    "KAYDET",
                    style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    overlayColor: MaterialStateProperty.all(Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildDropDown() {
    return Row(
              children: [
                Text("TİP  :  ",style:baslik),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black),
                  ),
                  elevation: 5,
                  child: SizedBox(
                    height: 50,
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
                      child: DropdownButton<dynamic>(
                        underline: SizedBox(),
                        value: selectedTip,
                        onChanged: girisCikismi ? null : (dynamic newValue) {
                          setState(() {
                            selectedTip = newValue;
                          });
                        },
                        items: tipList.map((dynamic tip) {
                          return DropdownMenuItem<dynamic>(
                            value: tip,
                            child: Text(
                              tip["name"],
                              style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  children: [
                    SizedBox(
                      height: 35,
                      child: Checkbox(
                        value: girisCikismi,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedTip = tipList[0];
                            girisCikismi = value!;
                          });
                        },
                      ),
                    ),
                    Text("GİRİŞ-ÇIKIŞ",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15)),
                  ],
                ),
              ],
            );
  }

  //region BARKOD İŞLEMLER
  getBarcodeInfos(value) async {
    await checkBarcodeFromDB();
  }

  checkBarcodeFromDB() async {
    var barcodeCount = await CheckBarkodDb.getStockCount(_barcodeTextController.text);

    if (barcodeCount == null) {
      EasyLoading.showInfo("Barkodun Girişi Yapılmamış.");
    }
    else if (barcodeCount <= 0) {
      EasyLoading.showInfo("Barkod Miktarı 0 Olduğundan Transfer Yapılamaz.");
    }
    else {
      await fillTheTextFields(barcodeCount);
    }
  }

  fillTheTextFields(barcodeCount) async {
    var result = await CheckBarkodDb.getBarcodeInfo(_barcodeTextController.text);

    print("res $result");
    print("res $depolar");
    await getTransferInfo();
    setState(() {
      _miktarTextController.text = barcodeCount.toString();
      var malzemeDepo = depolar.where((element) => element["Id"] == (result[0]["DepoHareketTipiId"] == 18 ? result[0]["KarsiDepoId"] : result[0]["DepoId"])).first;
      malzemeDepoID = malzemeDepo["Id"];
      malzemeDepoName = malzemeDepo["DepoAdi"];
      malzemeFabrikaID = malzemeDepo["FabrikaId"];
      if(malzemeFabrikaID != globals.factoryId){
        EasyLoading.showInfo("Barkodun Malzeme Deposu Farklı Fabrikada.");
        refreshPage();
      }
      if(result[0]["KarsiDepoId"] != null && result[0]["DepoHareketTipiId"] == 9){
        var karsiDepo = depolar.where((element) => element["Id"] == result[0]["KarsiDepoId"]).first;
        karsiDepoID = karsiDepo["Id"];
        karsiDepoName = karsiDepo["DepoAdi"];
        karsiFabrikaId = karsiDepo["FabrikaId"];
      }
    });

  }

   getTransferInfo() async {
    var dbCheck = openDatabase('BSSBobinDB.db');
    var query = ''' select Depo_Hareketleri.DepoHareketTipiId
                 from Stok_Karti_Barkod 
                 left join Depo_Hareketleri on Stok_Karti_Barkod.Id=Depo_Hareketleri.BarkodId
                 where Stok_Karti_Barkod.Barkod='${_barcodeTextController.text}' and Depo_Hareketleri.DepoHareketTipiId in (8,9) ORDER by Depo_Hareketleri.Id desc limit 1''';
    var result = await (await dbCheck).rawQuery(query);
    print("getTransferInfo ${result}");
    if(result.length == 0){
      kontrolDepoID = 8;
      print("getTransferInfo $kontrolDepoID");
      return;
    }
    kontrolDepoID = int.parse(result.first["DepoHareketTipiId"].toString());
    if(girisCikismi == false){
      kontrolDepoID == 8 ? selectedTip = tipList[2] : selectedTip = tipList[1];

    }
  }
//endregion

  refreshPage() {
    setState((){
      malzemeDepoName = "";
      malzemeDepoID = 0;
      karsiDepoName = "";
      karsiDepoID = 0;
      _miktarTextController.clear();
      _barcodeTextController.clear();
      kontrolDepoID = 0;
    });

  }
  onTapDepoButton() async {
    if (depolar.length == 1) {
      showAlertWithOKButton(context, "${LocaleKeys.wareHouseCount_text.tr()}", "${LocaleKeys.thereIsOne_text.tr()}");
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
                            karsiDepoName = _depoList[index]["DepoAdi"];
                            karsiDepoID = _depoList[index]["Id"];
                            karsiFabrikaId = _depoList[index]["FabrikaId"];
                            print(karsiFabrikaId);
                            Navigator.pop(context);
                          });
                        })),
              ),
            ),
          );
        });
  }
  //region KAYDETME İŞLEMLERİ
  isSaveButtonActive() async {
    print(karsiFabrikaId);
    print(globals.factoryId);
    if(karsiDepoID == 0){
      EasyLoading.showInfo("Karşı Depo Seçiniz");
      return;
    }
    else if(malzemeDepoID == 0){
      EasyLoading.showInfo("Malzeme Depo Boş Olamaz.");
      return;
    }
    else if(selectedTip["id"] == 7 && girisCikismi == false){
      EasyLoading.showInfo("Transfer Tipi Seçiniz.");
      return;
    }
    else if(kontrolDepoID == int.parse(selectedTip["id"].toString())){
      EasyLoading.showInfo("Bu Barkodla ${selectedTip["name"]} Yapamazsınız.Bir Önceki Hareketi İptal Etmelisiniz.");
      return;
    }
    else if(kontrolDepoID == 9 && girisCikismi == true){
      EasyLoading.showInfo("Bu Barkodla Transfer Giriş-Çıkış Yapamazsınız.Önce Giriş Yapmalısınız.");
      return;
    }
    else if(karsiFabrikaId != globals.factoryId && (girisCikismi == true || selectedTip["id"] == 8)){
      EasyLoading.showInfo("Farklı Fabrikaya Transfer Giriş-Çıkış Yapamazsınız.");
      return;
    }
    else if(malzemeFabrikaID != globals.factoryId && (girisCikismi == true || selectedTip["id"] == 9)){
      EasyLoading.showInfo("Farklı Fabrikaya Transfer Giriş-Çıkış Yapamazsınız.");
      return;
    }
      await checkForSavingToDB();
      barcodeFocusNode!.requestFocus();

  }

  checkForSavingToDB() async {
    // EasyLoading.show();
    var dbClient = await db;
    var MakinaId = await SaveBarkodDb.getDepoHareketleriInfo(_barcodeTextController.text,dbClient);
    var StokId =await SaveBarkodDb.getStokKartiInfo(_barcodeTextController.text,dbClient);
    var dataModelList = <UpdateAndInsertDataModel>[];
    transferHareket(dataModelList,StokId,MakinaId,malzemeDepoID,karsiDepoID);
    print("updateAndInsertData res $dataModelList");
    var res = await SaveBarkodDb.updateAndInsertData(dataModelList,dbClient);
    res == null ?onSuccess() :EasyLoading.showError("${LocaleKeys.error_text.tr()}");
    print("updateAndInsertData res $res");
  }
  onSuccess() async {
    if (globals.updatePeriod == 1) {
      await generalUpdateFunction(false);
    }
    refreshPage();
    EasyLoading.showSuccess("${LocaleKeys.saved_text.tr()}.");
  }
  transferHareket(dataModelList,StokId,MakinaId,malzemeDepo,karsiDepo){
    print(selectedTip);
    print(girisCikismi);
    if(girisCikismi == true || selectedTip["id"] == 9){
    dataModelList.add(UpdateAndInsertDataModel(
        barcode: _barcodeTextController.text,
        kgController: "-"+_miktarTextController.text,
        selectedDate: '${DateTime.now().toIso8601String()}',
        depoID: malzemeDepo!,
        karsiDepoID: karsiDepo,
        stokId: StokId ?? 0,
        fabrikaId: globals.factoryId,
        makinaId: MakinaId["MakinaId"] ?? 0,
        depoHareketTipId: 9,
      depoHareketYonuId: girisCikismi == true ? 3 : 2
    ));}
    if(girisCikismi == true || selectedTip["id"] == 8){
      dataModelList.add(UpdateAndInsertDataModel(
        barcode: _barcodeTextController.text,
        kgController: _miktarTextController.text,
        selectedDate: '${DateTime.now().toIso8601String()}',
        depoID: karsiDepo,
          fabrikaId: globals.factoryId,
          stokId: StokId ?? 0,
        makinaId: MakinaId["MakinaId"] ?? 0,
        depoHareketTipId: 8,
          depoHareketYonuId: girisCikismi == true ? 3 : 1
      ));}
  }
//endregion
}
