import 'dart:io';

import 'package:bss_mobile_premium/screens/Home/home.dart';
import 'package:bss_mobile_premium/screens/Irsaliye_Kabul/selection_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';

import '../../data_model/services/update_function.dart';
import '../../db_helper_class/db_save_helper.dart';
import '../../helper/languages/locale_keys.g.dart';
import '../../helper/widgetHelper.dart';
import 'barkod_etiket.dart';

class IrsaliyeKabul extends StatefulWidget {
  String pageChoose = "";
   IrsaliyeKabul({Key? key,required this.pageChoose}) : super(key: key);
  @override
  State<IrsaliyeKabul> createState() => _IrsaliyeKabulState(this.pageChoose);
}

class _IrsaliyeKabulState extends State<IrsaliyeKabul> {
  var db = openDatabase('BSSBobinDB.db');
  var dbLog = openDatabase('BSSBobinDBLog.db');
  var _enTextFieldController = new TextEditingController();
  var _gramajTextFieldController = new TextEditingController();

  bool irsaliyeSelected = false;
  int irsaliyeId = 0;
  String irsaliyeText = "";

  bool stokSelected = false;
  int stokId = 0;
  String stokText = "";

  bool irsaliyeDetaySelected = false;
  int irsaliyeDetayId = 0;
  String irsaliyeDetayText = "";
  final _miktarTextFieldController = TextEditingController();
  final _musteriTextFieldController = TextEditingController();
  List<String> acceptQueries = <String>[];
  List<String> acceptLogQueries = <String>[];
  double toplamMiktar = 0;
  double kalanMiktar = 0;

  //////////DataTable///////
  int _currentPage = 1;
  bool _isSearch = false;
  List<Map<String, dynamic>> _sourceOriginal = [];
  List<Map<String, dynamic>> _sourceFiltered = [];
  List<Map<String, dynamic>> _source = [];
  List<Map<String, dynamic>> _selecteds = [];
  List<int> _perPages = [10, 20, 50, 100];
  int _total = 100;
  int? _currentPerPage = 10;
  List<bool>? _expanded;
  String? _searchKey = "BobinNo";
  bool showAll = false;
  Color color = Colors.white;
  late final List<DatatableHeader> _headers = [
    DatatableHeader(
      flex: 2,
      text: "Barkod No",
      value: "Barkod",
      show: true,
      sortable: true,
      textAlign: TextAlign.center,
    ),
    DatatableHeader(
        flex: 2,
        editable: false,
        text: "Miktar",
        value: "Miktar",
        show: true,
        sortable: false,
        textAlign: TextAlign.center),
    DatatableHeader(
        flex: 2,
        text: "Stok Adı",
        value: "RefAd",
        show: true,
        sortable: false,
        textAlign: TextAlign.center),
  ];
  String? _sortColumn;
  bool _sortAscending = true;
  bool _isLoading = false;
  bool _showSelect = true;
  late String page = widget.pageChoose;
  // String page = "İrsaliye";

  _IrsaliyeKabulState(String pageChoose);

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("BARKOD KABUL"),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.print_outlined),
      //       onPressed: () {
      //         showAlertWithYesNoButton(context, "YAZDIR",
      //             "Barkod Yazdırmak İster misiniz?",-1);
      //       },
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Padding(
            //   padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
            //   child: Container(
            //     width: MediaQuery.of(context).size.width*0.6,
            //     height: 20,
            //     child: RadioGroup<String?>.builder(
            //       direction: Axis.horizontal,
            //       groupValue: page,
            //       activeColor: Colors.green,
            //       textStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 17,color: Colors.red),
            //       onChanged: (value) => setState(() {
            //         page = value!;
            //         refreshPage();
            //       }),
            //       items: ["İrsaliye", "Devir"],
            //       itemBuilder: (item) => RadioButtonBuilder(
            //         item!,
            //       ),
            //     ),
            //   ),
            // ),
            Divider(height: 3,color: Colors.black,thickness: 1,),
            page == "İrsaliye" ? irsaliyeButtons(context) : stokButtons(context),
            // page == "İrsaliye" ? irsaliyeButtons(context) : stokButtons(context),
            searchbutton(),
            buildDataTable(),
            buildPageButtons(context)
          ],
        ),
      ),
    );
  }

  Padding searchbutton()  {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      Text("Tümünü Göster :"),
                      Checkbox(
                          value: showAll,
                          onChanged: (value) {
                            setState(() {
                              showAll = value!;
                              _selecteds.forEach((element) {
                                showAll
                                    ? _sourceOriginal.add(element)
                                    : _sourceOriginal.remove(element);
                              });
                              _refreshData();
                            });
                          }),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      page == "İrsaliye" ? await getIrsaliyeTableData() : await getDevirTableData();
                      await _refreshData();
                    },
                    icon: Icon(Icons.search, color: Colors.white),
                    label: Text(
                      LocaleKeys.search_text.tr(),
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Color(0xFF264348)),
                        overlayColor: MaterialStateProperty.all(Colors.red)),
                  ),
                ),
              ],
            ),
    );
  }

  Padding buildPageButtons(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MenuButtons()),
                    ModalRoute.withName('/'),
                  );
                },
                icon: Icon(Icons.close, color: Colors.white),
                label: Text(
                  "Kapat",
                  style: TextStyle(color: Colors.white,fontSize: 17),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  overlayColor: MaterialStateProperty.all(Colors.red),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  refreshPage();
                  showAlertWithYesNoButton(context, "YAZDIR",
                      "Barkod Yazdırmak İster misiniz?",-1);
                },
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  "Yeni",
                  style: TextStyle(color: Colors.white,fontSize: 17),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey),
                  overlayColor: MaterialStateProperty.all(Colors.red),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  // await acceptStokSave();
                  await generalUpdateFunction(false);
                  showAlertWithYesNoButton(context, "YAZDIR",
                      "Veriler Güncellendi. Barkodları Yazdırmak İster misiniz?",irsaliyeDetayId);
                },
                icon: Icon(Icons.print, color: Colors.white),
                label: Text(
                  "Güncelle&Yazdır",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  overlayColor: MaterialStateProperty.all(Colors.red),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ]));
  }


  Padding irsaliyeButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text("İRSALİYE : ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              Expanded(
                flex: 3,
                child: SelectionButton(
                  irsaliyeSelected,
                  irsaliyeText,
                  () => NavigateAndDisplaySelection(context, "İrsaliye", 0),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text("İRSALİYE KALEM : ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              Expanded(
                flex: 3,
                child: SelectionButton(
                  irsaliyeDetaySelected,
                  irsaliyeDetayText,
                  () => NavigateAndDisplaySelection(
                      context, "İrsaliye Kalem", irsaliyeId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Padding stokButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 3, 10, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text("STOK  : ",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              Expanded(
                flex: 3,
                child: SelectionButton(
                  stokSelected,
                  stokText,
                      () => NavigateAndDisplaySelection(context, "Stok", 0),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                flex: 0,
                child: Text("GRAMAJ  : ",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _gramajTextFieldController,
                  style: textFieldStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(5),
                    enabledBorder: textFieldBorder,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Expanded(
                flex: 0,
                child: SizedBox(width: 20,),
              ),
              Expanded(
                flex: 0,
                child: Text("EN  : ",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _enTextFieldController,
                  style: textFieldStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(5),
                    enabledBorder: textFieldBorder,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  acceptStockModal(context, item) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              insetPadding: EdgeInsets.all(8.0),
              title: Text(
                "Barkod Kabul",
                textAlign: TextAlign.center,
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(child: Text("BARKOD : ")),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller:
                                TextEditingController(text: item["Barkod"].toString()),
                            enabled: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true, // Added this
                              contentPadding: EdgeInsets.all(8), // Added this
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(flex: 12, child: Text("Miktar : ")),
                        Expanded(
                          flex: 12,
                          child: TextField(
                            controller: _miktarTextFieldController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true, // Added this
                              contentPadding: EdgeInsets.all(8), // Added this
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 0,
                            child: SizedBox(
                              width: 10,
                            )),
                        Expanded(flex: 19, child: Text("Müşteri No : ")),
                        Expanded(
                          flex: 23,
                          child: TextField(
                            controller: _musteriTextFieldController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true, // Added this
                              contentPadding: EdgeInsets.all(8), // Added this
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          textColor: Colors.white,
                          color: Colors.red,
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            padding: const EdgeInsets.all(0.0),
                            child:
                                Text("İPTAL", style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        RaisedButton(
                          onPressed: () async {
                            await acceptStockQuery(
                                item, _miktarTextFieldController.text);
                            // EasyLoading.showSuccess("Eklendi");
                          },
                          color: Colors.green,
                          textColor: Colors.white,
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            padding: const EdgeInsets.all(0.0),
                            child:
                                Text("KAYDET", style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ));
        });
  }
  acceptStockQuery(item, miktar) async {
    if(irsaliyeId != 0 && int.parse(miktar.toString())>kalanMiktar){
      EasyLoading.showInfo("Girişlerin miktarı İrsaliyedeki miktardan büyük olamaz");
    }
    else{
      var dbClient = await db;
      var dataModelList = <UpdateAndInsertDataModel>[];
      dataModelList.add(UpdateAndInsertDataModel(
          barcode: item["Barkod"].toString(),
          firmaBobinController: _musteriTextFieldController.text,
          kgController: _miktarTextFieldController.text,
          selectedDate: DateTime.now().toIso8601String(),
          depoID: item["DepoId"] ?? 0,
          stokId: item["StokId"] ?? 0,
          makinaId: item["MakinaId"] ?? 0,
          depoHareketTipId: 14,
          depoHareketYonuId: 1

      ));
      var res = await SaveBarkodDb.updateAndInsertData(dataModelList,dbClient);
      page == "İrsaliye" ?
      await getIrsaliyeTableData() : await getDevirTableData();
      page == "İrsaliye" ? await getIrsaliyeRemainingAmount() : await getDevirRemainingAmount();
      Navigator.pop(context);
      _miktarTextFieldController.clear();
      _musteriTextFieldController.clear();
    }
  }

  acceptStokSave(queries) async {
    var dbClient = await db;
    if (queries.length > 0) {
      queries.forEach((element) async {
        await dbClient.rawQuery(element);
      });
      EasyLoading.showSuccess("Kaydedildi");
      acceptQueries.clear();
    }
  }
  acceptLogStokSave(queries) async {
    var dbClientLog = await dbLog;
    if (queries.length > 0) {
      queries.forEach((element) async {
        await dbClientLog.rawQuery(element);
      });
      EasyLoading.showSuccess("Kaydedildi");
      acceptLogQueries.clear();
    }
  }

  Widget SelectionButton(bool selected, String text, Function method) {
    return ButtonTheme(
      height: 40.0,
      buttonColor: Colors.black45,
      child: RaisedButton(
        onLongPress: () => {},
        onPressed: () => method(),
        child: SizedBox(
          child: Center(
            child: Text(
              selected ? text : "Seçiniz",
              softWrap: false,
              maxLines: 2,
              style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  NavigateAndDisplaySelection(BuildContext context, String key, int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectionScreen(key, id)),
    );
    print(result);
    if (result != null) {
      setState(() {
        switch (key) {
          case "İrsaliye":
            irsaliyeText = result["IrsaliyeNo"];
            irsaliyeId = result["Id"];
            irsaliyeSelected = true;
            irsaliyeDetayId = 0;
            irsaliyeDetaySelected = false;
            break;
          case "İrsaliye Kalem":
            irsaliyeDetayText = result["StokAdi"];
            irsaliyeDetayId = result["Id"];
            irsaliyeDetaySelected = true;
            toplamMiktar = result["Miktar"];
            getIrsaliyeRemainingAmount();
            getIrsaliyeTableData();
            break;
          case "Stok":
            stokId = result["Id"];
            stokText = result["RefAd"];
            stokSelected = true;
            getDevirTableData();
            getDevirRemainingAmount();
            break;
          default:
            break;
        }
      });
    }
  }

  getIrsaliyeTableData() async {
    var dbClient = await db;
    _sourceOriginal = [];
    _selecteds = [];
    _expanded = List.generate(_currentPerPage!, (index) => false);
    _isLoading = true;

 var query =
       '''select skb.Id,dh.DepoId as DepoId,skb.Barkod,0 as Miktar,sk.RefAd,sk.Id as StokId,dh.MasrafyeriId as MakinaId,skb.TedarikciBarkodNo,0 as kabulMu
        from Stok_Karti_Barkod as skb
          INNER JOIN Depo_Hareketleri as dh ON
           CASE
              WHEN skb.RefDbTableId = 169 THEN dh.Id = skb.RefDetayId AND dh.RefDetayId = 0 AND dh.RefDbTableId = null
              WHEN skb.RefDbTableId = 31  THEN dh.RefDetayId = skb.RefDetayId AND dh.RefDbTableId = skb.RefDbTableId
           END
        LEFT JOIN Stok_Karti as sk on dh.StokId = sk.Id	
         Where skb.Id NOT IN (SELECT DISTINCT BarkodId FROM Depo_Hareketleri WHERE BarkodId IS NOT NULL) and skb.RefdetayId <> 0 ''';

    if (irsaliyeDetayId != 0) query += "And skb.RefdetayId = $irsaliyeDetayId";
    if (showAll == true) {
      var queryAll =
         '''select Stok_Karti_Barkod.Id,Stok_Karti_Barkod.Barkod,Stok_Karti.RefAd,Depo_Hareketleri.Birim1Miktari as Miktar,Stok_Karti_Barkod.TedarikciBarkodNo,1 as kabulMu
           from Stok_Karti_Barkod 
           Inner Join Depo_Hareketleri on Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id
            Inner Join Stok_Karti on Stok_Karti.Id = Depo_Hareketleri.StokID
           Where DepoHareketTipiId = 14 and Stok_Karti_Barkod.RefDetayId <> 0  ''';

      if (irsaliyeDetayId != 0) queryAll += "And Stok_Karti_Barkod.RefdetayId = $irsaliyeDetayId";
      _sourceOriginal.addAll(await dbClient.rawQuery(queryAll));
      _sourceOriginal.forEach((element) {
        setState(() {
          _selecteds.add(element);
        });
      });
    }
    print("data que $query");

    _sourceOriginal.addAll(await dbClient.rawQuery(query));
    await _refreshData();
    _isLoading = false;
    print("length ${_sourceOriginal.length}");

  }
  getDevirTableData() async {
    var dbClient = await db;
    _sourceOriginal = [];
    _selecteds = [];
    _expanded = List.generate(_currentPerPage!, (index) => false);
    _isLoading = true;

    var query =
         '''select skb.Id,skb.Barkod,dh.Birim1Miktari as miktar,sk.RefAd,skb.TedarikciBarkodNo,0 as kabulMu
            from Stok_Karti_Barkod as skb
            INNER JOIN Depo_Hareketleri as dh ON
           CASE
              WHEN skb.RefDbTableId = 169 THEN dh.Id = skb.RefDetayId AND dh.RefDetayId = 0 AND dh.RefDbTableId = null
              WHEN skb.RefDbTableId = 31  THEN dh.RefDetayId = skb.RefDetayId AND dh.RefDbTableId = skb.RefDbTableId
           END
            LEFT JOIN Stok_Karti as sk on dh.StokId = sk.Id	
            Where skb.Id NOT IN (SELECT DISTINCT BarkodId FROM Depo_Hareketleri WHERE BarkodId IS NOT NULL) And skb.RefDetayId = 0''';

    if (stokId != 0) query += " And sk.Id = $stokId";
    if (_gramajTextFieldController.text.isNotEmpty) query += " And sk.TeknikDeger LIKE '%${_gramajTextFieldController.text}%' ";
    if (_enTextFieldController.text.isNotEmpty) query += " And sk.En LIKE '%${_enTextFieldController.text}%' ";
  print(query);
    if (showAll == true) {
      var queryAll =
          '''select Stok_Karti_Barkod.Id,Stok_Karti_Barkod.Barkod,Stok_Karti.RefAd,Depo_Hareketleri.Birim1Miktari as Miktar,Stok_Karti_Barkod.TedarikciBarkodNo,1 as kabulMu
             from Stok_Karti_Barkod 
              Inner Join Depo_Hareketleri on Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id
             Inner Join Stok_Karti on Stok_Karti.Id = Depo_Hareketleri.StokID
             Where Depo_Hareketleri.DepoHareketTipiId = 14 And Depo_Hareketleri.RefDetayId = 0''';
      if (stokId != 0) queryAll += " And Stok_Karti.Id = $stokId";
      await dbClient.rawQuery(query);
      _sourceOriginal.addAll(await dbClient.rawQuery(queryAll));
      _sourceOriginal.forEach((element) {
        setState(() {
          _selecteds.add(element);
        });
      });
    }

    _sourceOriginal.addAll(await dbClient.rawQuery(query));
    await _refreshData();
    _isLoading = false;
    print(_sourceOriginal);
  }

  getIrsaliyeRemainingAmount() async {
    var dbClient = await db;
    var queryAll =
        '''select  SUM(Depo_Hareketleri.Birim1Miktari) as Miktar
         from Stok_Karti_Barkod
         Inner Join Depo_Hareketleri on Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id
         Where DepoHareketTipiId = 14 And Stok_Karti_Barkod.RefDetayId = $irsaliyeDetayId''';
  print(queryAll);
    var remainingAmount = await dbClient.rawQuery(queryAll);
    print(remainingAmount);
    print(toplamMiktar);
    setState(() {
      if (remainingAmount.first["Miktar"] != null) {
        kalanMiktar =
            toplamMiktar - double.parse(remainingAmount.first["Miktar"].toString());
        print(kalanMiktar);
        print(toplamMiktar);

        return;
      }
      kalanMiktar = toplamMiktar;
    });
  }
  getDevirRemainingAmount() async {
    var dbClient = await db;
    var queryAll ='''
    select SUM(Depo_Hareketleri.Birim1Miktari) as Miktar 
    from Stok_Karti_Barkod 
    Inner Join Depo_Hareketleri on Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id
    Where DepoHareketTipiId = 14 And Stok_Karti_Barkod.RefDetayId = 0 and Depo_Hareketleri.StokID = $stokId''';
    var remainingAmount = await dbClient.rawQuery(queryAll);
    var queryToplam = '''select sum(dh.Birim1Miktari) as Miktar
             from Stok_Karti
             inner join Depo_Hareketleri as dh on dh.StokId = Stok_Karti.Id and DepoHareketTipiId = 0 and Stok_Karti.Id = $stokId''';
    var toplamAmount = await dbClient.rawQuery(queryToplam);

    print("rema $queryToplam");
    print("rema $toplamAmount");
    setState(() {
      toplamMiktar = double.parse(toplamAmount.first["Miktar"].toString());
      if (remainingAmount.first["Miktar"] != null) {
        kalanMiktar =
            toplamMiktar - (remainingAmount.first["Miktar"] as double);
        return;
      }
      kalanMiktar = toplamMiktar;
    });
  }

  refreshPage() {
    setState(() {
      _sourceOriginal = [];
      _source = [];
      _selecteds = [];
      showAll = false;
      irsaliyeSelected = false;
      irsaliyeDetaySelected = false;
      irsaliyeId = 0;
      irsaliyeDetayId = 0;
      stokId = 0;
      stokSelected = false;
    });
  }

  showAlertWithYesNoButton(context, title, message,irsaliyeId) {
    Alert(
      context: context,
      type: AlertType.success,
      title: title,
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            LocaleKeys.yes_text.tr(),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => {
                Navigator.pop(context),
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BarkodEtiket(irsaliyeId)),
                ),
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            LocaleKeys.no_text.tr(),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.red,
        )
      ],
    ).show();
  }

  /////////Resp-Table////////
  SingleChildScrollView buildDataTable() {
    return SingleChildScrollView(
        child: Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.52,
              ),
              child: ResponsiveDatatable(
                reponseScreenSizes: [ScreenSize.xl],
                hideUnderline: true,
                actions: [
                  if (_isSearch)
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Barkod No Giriniz',
                          prefixIcon: IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                _isSearch = false;
                                _filterData("");
                              });
                            },
                          ),
                          // suffixIcon: IconButton(
                          //   icon: Icon(Icons.search),
                          //   onPressed: () {},
                          // ),
                        ),
                        onSubmitted: (value) {
                          _filterData(value);
                        },
                      ),
                    ),
                  if (!_isSearch)
                    Container(
                      height: 30,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search,
                                color: Colors.blue, size: 20),
                            onPressed: () {
                              setState(() {
                                _isSearch = true;
                              });
                            },
                          ),
                          TextButton(
                            child: const Text(
                              "Barkod Ara",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isSearch = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
                onTabRow: (item) {
                  print(item);
                  _miktarTextFieldController.clear();
                  _musteriTextFieldController.clear();
                  if (_selecteds.contains(item)) {
                    setState(() {
                      _miktarTextFieldController.text =
                          item["Miktar"].toString();
                      _musteriTextFieldController.text =
                          item["TedarikciBobinNo"].toString();
                      print(item);
                      acceptStockModal(context, item);
                    });
                    return;
                  }
                  acceptStockModal(context, item);
                },
                title: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Toplam Miktar : $toplamMiktar",
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Kalan Miktar : $kalanMiktar",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
                headers: _headers,
                source: _source,
                selecteds: _selecteds,
                showSelect: false,
                autoHeight: false,
                expanded: _expanded,
                sortAscending: _sortAscending,
                sortColumn: _sortColumn,
                isLoading: _isLoading,
                onSelect: (value, item) {
                  print(value);
                  responsiveTblSelected(value, item);
                },
                onSelectAll: (bool? value) {
                  onSelectAll(value);
                },
                footers: _source.length > 0
                    ? [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Text("Sayfadaki satır :  "),
                        ),
                        if (_perPages.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: DropdownButton<int>(
                              value: _currentPerPage,
                              items: _perPages
                                  .map(
                                    (e) => DropdownMenuItem<int>(
                                      child: Text("$e"),
                                      value: e,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (dynamic value) {
                                setState(() {
                                  _currentPerPage = value;
                                  _currentPage = 1;
                                  _resetData();
                                });
                              },
                              isExpanded: false,
                            ),
                          ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                              "$_currentPage - ${(_currentPerPage! + _currentPage)}"),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                          ),
                          onPressed: _currentPage == 1
                              ? null
                              : () {
                                  var _nextSet =
                                      _currentPage - _currentPerPage!;
                                  setState(() {
                                    _currentPage = _nextSet > 1 ? _nextSet : 1;
                                    _resetData(start: _currentPage - 1);
                                  });
                                },
                          padding: EdgeInsets.symmetric(horizontal: 15),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed:
                              _currentPage + _currentPerPage! - 1 > _total
                                  ? null
                                  : () {
                                      var _nextSet =
                                          _currentPage + _currentPerPage!;
                                      setState(() {
                                        _currentPage = _nextSet < _total
                                            ? _nextSet
                                            : _total - _currentPerPage!;
                                        _resetData(start: _nextSet - 1);
                                      });
                                    },
                          padding: EdgeInsets.symmetric(horizontal: 15),
                        )
                      ]
                    : [],

                headerDecoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.black38),
                ),
                selectedDecoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.black, width: 1)),
                  color: Colors.green,
                ),
                headerTextStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                rowTextStyle: TextStyle(color: Colors.black),
                // selectedTextStyle: TextStyle(color: Colors.white),
              ),
            ),
          ]),
    ));
  }

  void onSelectAll(bool? value) {
    if (value!) {
      setState(() => {
            _selecteds = _source.map((entry) => entry).toList().cast(),
          });
    } else {
      setState(() => {_selecteds.clear()});
    }
  }

  void responsiveTblSelected(bool? value, Map<String, dynamic> item) {
    if (value!) {
      setState(() => {
            _selecteds.add(item),
          });
    } else {
      setState(() => {
            _selecteds.removeAt(_selecteds.indexOf(item)),
          });
    }
  }

  _resetData({start: 0}) async {
    print("sss");
    setState(() => _isLoading = true);
    var _expandedLen =
        _total - start < _currentPerPage! ? _total - start : _currentPerPage;
    print(_expandedLen);
    Future.delayed(Duration(seconds: 0)).then((value) {
      _expanded = List.generate(_expandedLen as int, (index) => false);
      _source.clear();
      _source = _sourceFiltered.getRange(start, start + _expandedLen).toList();
      setState(() => _isLoading = false);
    });
  }

  _filterData(value) {
    setState(() => _isLoading = true);

    try {
      if (value == "" || value == null) {
        _sourceFiltered = _sourceOriginal;
      } else {
        _sourceFiltered = _sourceOriginal
            .where((data) => data[_searchKey!]
                .toString()
                .toLowerCase()
                .contains(value.toString().toLowerCase()))
            .toList();
      }

      _total = _sourceFiltered.length;
      var _rangeTop = _total < _currentPerPage! ? _total : _currentPerPage!;
      _expanded = List.generate(_rangeTop, (index) => false);
      _source = _sourceFiltered.getRange(0, _rangeTop).toList();
    } catch (e) {
      print(e);
    }
    setState(() => _isLoading = false);
  }

  _refreshData() async {
    setState(() => _isLoading = true);
    print(_sourceOriginal);
    if(_sourceOriginal.length > 0){
    _sourceOriginal.sort((a, b) => b['Barkod'].compareTo(a['Barkod']));}
    _sourceFiltered = _sourceOriginal;
    _total = _sourceFiltered.length;
    if (_sourceFiltered.length <= _currentPerPage!) {
      _source = _sourceFiltered;
      setState(() => _isLoading = false);
      return;
    }
    _source = _sourceFiltered.getRange(0, _currentPerPage!).toList();
    setState(() => _isLoading = false);
    // });
  }
}