import 'dart:convert';
import 'package:bss_mobile_premium/data_model/holler.dart';
import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:bss_mobile_premium/screens/Sayim/sayim_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../data_model/depolar.dart';
import '../../data_model/sayimlar.dart';
import '../../data_model/services/depo_services.dart';
import '../../data_model/services/get_all_depolar_services.dart';
import '../../data_model/services/holler_services.dart';
import '../../data_model/services/update_function.dart';
import '../../helper/alert.dart';
import '../../helper/languages/locale_keys.g.dart';

class Sayim extends StatefulWidget {

  Sayim({Key? key}) : super(key: key);
  @override
  _SayimState createState() => _SayimState();
}

class _SayimState extends State<Sayim> {
  //region DEGİSKENLER
  var greenButtonStyle = ElevatedButton.styleFrom(
      primary: Colors.green,fixedSize: Size(100, 60));
  var _holService = HollerService();
  var _depoService = DepolarService();

  DateTime selectedDate = DateTime.now();
  var db = openDatabase('BSSBobinDB.db');
  FocusNode? barcodeFocusNode;
  //TextField Controllers
  var _barcodeTextFieldController = new TextEditingController();
  var _kgTextFieldController = new TextEditingController();

  bool isDeleteButtonVisible = false;
  double iconSize = 40;
  //Styles
  var textStyle = TextStyle(fontSize: 25.0, color: Colors.black);
  static const int numItems = 100;
  List<bool?> selected = List<bool?>.generate(numItems, (index) => false);
  ScrollController _scrollController = ScrollController();

  bool araButtonSelected = false;
  bool updateButtonSelected = false;
  var finalArray = [];
  String? depoName;
  // int? depoID;
  String networkURL = "";
  String fisNo = "";
  bool ignore = false;

  //////////DataTable///////
  int _currentPage = 1;
  bool _isSearch = false;
  List<Map<String, dynamic>> _sourceOriginal = [];
  List<Map<String, dynamic>> _sourceFiltered = [];
  List<Map<String, dynamic>> _source = [];
  List<Map<String, dynamic>> _selecteds = [];
  List<int> _perPages = [10, 20, 50, 100];
  int _total = 100;
  int? _currentPerPage = 20;
  List<bool>? _expanded;
  String? _searchKey = "BarkodID";
  late List<DatatableHeader> _headers = [
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
        editable: true,
        text: "Miktar",
        value: "Miktar",
        show: true,
        sortable: false,
        textAlign: TextAlign.center),
    DatatableHeader(
        flex: 2,
        text: "StokID",
        value: "StokID",
        show: true,
        sortable: false,
        textAlign: TextAlign.center),
  ];
  String? _sortColumn;
  bool _sortAscending = true;
  bool _isLoading = true;
  bool _showSelect = true;
  bool outoAdd = false;
  String pageChoose = "";

  bool _depoSelected = false;
  int? _depoID;
  String _depoText = "";
  List<Depolar> _depoList = <Depolar>[];

  bool _holSelected = false;
  int? _holID;
  String _holText = "";
  List<Holler> _holList = <Holler>[];
  bool holTumu = false;
  //endregion

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    barcodeFocusNode = FocusNode();
    pageChange();
    getAllDepoHol();
  }
  //region INIT
  getAllDepoHol() async {
    var categories = await _holService.readHoller();
    categories.forEach((depo) {
      setState(() {
        var holModel = Holler();
        holModel.HolID = depo['HolID'];
        holModel.HolAdi = depo['HolAdi'];
        _holList.add(holModel);
      });
    });
    _depoList = <Depolar>[];
    var categoriesDepo = await _depoService.readDepolar();
    categoriesDepo.forEach((depo) {
      var depoModel = Depolar();
      depoModel.AmbarID = depo['AmbarID'];
      depoModel.AmbarIsmi = depo['AmbarIsmi'];
      _depoList.add(depoModel);
    });
  }
  dbControl() async {
    var shared = await getSaveDPortAndIPToSayim();
    networkURL = shared[0];
    var dbClient = await db;
    var _depoQ = _depoID == null ? "DepoID IS NULL" : "DepoID=${_depoID}";
    var _holQ = _holID == null ? "HolID IS NULL" : "HolID=${_holID}";
    print(_depoID);
    print(_holID);
    var query = "SELECT count (BarkodID) from Sayimlar Where ${_depoQ} and ${_holQ}";
    print(query);
    var result = await dbClient.rawQuery(query);
    print("result $result");
    if (int.parse(result[0]["count (BarkodID)"].toString()) > 0) {
      getSayimDb();
      print("if");
    } else {
      networkControl();
      print("else");
    }

  }
  Future<void> pageChange() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    pageChoose = prefs.getString('sayimHol')!;
    if(pageChoose == "Tümü"){
      print("burada");
      await dbControl();
    }
  }
  getSaveDPortAndIPToSayim() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? getPortAndIP = prefs.getString('port_and_ip');
    String? deviceMac = prefs.getString('deviceId');
    return [getPortAndIP,deviceMac];
  }
  getSayimDb()async{
    var dbClient = await db;
    var _depoQ = _depoID == null ? "sy.DepoID IS NULL" : "sy.DepoID=${_depoID}";
    var _holQ = _holID == null ? "sy.HolID IS NULL" : "sy.HolID=${_holID}";
    var query = "Select sy.ID,sy.BarkodID,sy.Miktar,sy.StokID,sy.FisNo,sy.Tarih,sy.Modul,sy.Durum,sy.DepoID,"
        "sy.HolID,sy.EvrakID,sy.CreatedDate,sy.BobinSyncStatus,skb.Barkod"
        " from Sayimlar as sy inner join Stok_Karti_Barkod as skb on sy.BarkodID = skb.Id  where"
        " sy.Durum = 0 and ${_depoQ} and ${_holQ}  order by sy.BarkodID desc";
    var result = await dbClient.rawQuery(query);
    var query2 = "SELECT * FROM Sayimlar as sy where ${_depoQ} and ${_holQ} LIMIT 1";
    var result2 = await dbClient.rawQuery(query2);
    print("res $result");
    if(result2.length > 0){
      setState((){
        fisNo = result2[0]["FisNo"].toString();
      });
    }

    // select top 1 FisNo from Sayim

    setState(() {
      _isLoading = true;
      var sayim = Sayimlar().sayimFromJson(jsonEncode(result));
      _sourceOriginal = [];
      _expanded = List.generate(_currentPerPage!, (index) => false);
      _sourceOriginal.addAll(Sayimlar().donustur(sayim));
      _refreshData();
      _isLoading = false;
    });

    EasyLoading.dismiss();
  }
  networkControl() async {
    print("net");
    EasyLoading.show();
    EasyLoading.dismiss();
    await getSayimlarAfterUpdate(networkURL);
    await getSayimDb();
    // try {
    //   print("net2");
    //   var result;
    //   await InternetAddress.lookup('google.com');
    //   print("net $result");
    //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //     await getSayimlarAfterUpdate(networkURL);
    //     await getSayimDb();
    //   }
    //   else{
    //     setState(() {
    //       ignore = true;
    //     });
    //   }
    // } on SocketException catch (_) {
    //   print("net3");
    //   setState(() {
    //     ignore = true;
    //   });
    //   EasyLoading.showError("${LocaleKeys.internetConnectionInfo_text.tr()}");
    //   EasyLoading.dismiss();
    // }
    // bool result = await InternetConnectionChecker().hasConnection;
    // if(result == true) {
    //   print('net var');
    // } else {
    //   print('No internet :( Reason:');
    //   print(InternetConnectionChecker());
    // }
  }
  getSayimlarAfterUpdate(networkUrl) async {
    var depoID = _depoID ?? "";
    var holID = _holID ?? "";

    var url = networkUrl + "/api/Sayim?&depoId=$depoID&holId=$holID";
    print("url $url");
    final response = await get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    print("response ${response.body}");

    if (response.statusCode == 200) {
      setState((){
        fisNo = jsonDecode(response.body)["SayimNo"] ?? "";
      });
      print("fis no $fisNo");
      await deleteOldSayimlar(_depoID,_depoID);
      await saveUpdatedDataToDB([jsonDecode(response.body)["Sorgu"]]);
    } else {
      throw Exception('Failed to load getSayimlarAfterUpdate');
    }
  }
  //endregion
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.counting_text.tr().toUpperCase()),
          leading: BackButton(
            onPressed: () async {
              var dbClient = await db;
              var _depoQ = _depoID == null ? "DepoID IS NULL" : "DepoID=${_depoID}";
              var _holQ = _holID == null ? "HolID IS NULL" : "HolID=${_holID}";
              var query = "SELECT count (BarkodID) from Sayimlar where Durum <> 2 and ${_depoQ} and ${_holQ}";
              var result = await dbClient.rawQuery(query);
              print(int.parse(result[0]["count (BarkodID)"].toString()));
              print(_sourceOriginal.length);
              if (int.parse(result[0]["count (BarkodID)"].toString()) < _sourceOriginal.length) {
                EasyLoading.showInfo("Kaydetmediğiniz veriler var. Sayfadan çıkmadan önce kaydet butonuna basınız.");
                return;
              }
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: FloatingActionButton(
                  // backgroundColor: Color.fromRGBO(113, 6, 39, 1),
                  onPressed: () async {
                    var dbClient = await db;
                    var _depoQ = _depoID == null ? "DepoID IS NULL" : "DepoID=${_depoID}";
                    var _holQ = _holID == null ? "HolID IS NULL" : "HolID=${_holID}";
                    var query = "SELECT count (BarkodID) from Sayimlar where Durum <> 2 and ${_depoQ} and ${_holQ}";
                    var result = await dbClient.rawQuery(query);
                    print(int.parse(result[0]["count (BarkodID)"].toString()));
                    print(_sourceOriginal.length);
                    if (int.parse(result[0]["count (BarkodID)"].toString()) < _sourceOriginal.length) {
                      EasyLoading.showInfo("Kaydetmediğiniz veriler var.Güncelleme yapmadan önce kaydet butonuna basınız.");
                      return;
                    }

                    await setSayimlarUpdates(networkURL,_depoID,_holID);

                    await yeniButtonClicked();
                    await dbControl();
                    EasyLoading.showSuccess("GÜNCELLENDİ",duration: Duration(seconds: 2));

                  },
                  child: Center(child: Icon(Icons.download)),
                  // child: Center(child: Text("Güncelle")),
                )),

          ],
        ),
        body: pageChoose == "Tümü" ? IgnorePointer(
          ignoring: ignore,
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: ListView(children: <Widget>[
              SizedBox(
                child: Center(
                  child: Text("Fiş No : $fisNo",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal,decoration: TextDecoration.underline,)),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text("BARKOD: ",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Focus(
                      child: TextFormField(
                        onFieldSubmitted: (_) async {

                          if (_barcodeTextFieldController.text.isNotEmpty && _barcodeTextFieldController.text.length != 1) {
                            await getTextFieldText(_barcodeTextFieldController.text);
                          } else {
                            print("asdas");
                            errorOnBarcodeControl();
                          }
                        },
                        controller: _barcodeTextFieldController,
                        keyboardType: TextInputType.number,
                        focusNode: barcodeFocusNode,
                        //autofocus: true,
                        style: textStyle,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(5),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text("${LocaleKeys.kg_text.tr().toUpperCase()} :  ",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),

                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _kgTextFieldController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                      maxLines: 1,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Visibility(
                          child: RaisedButton(
                            onPressed: () => deleteSelected(),
                            child: Text(LocaleKeys.delete_text.tr(), style: TextStyle(fontSize: 20)),
                          ),
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: _selecteds.length > 0,
                        ),
                        _selecteds.length != 1
                            ? RaisedButton(
                          onPressed: () => onPressedAddButton(),
                          child: Text(LocaleKeys.add_text.tr(),
                              style:
                              TextStyle(fontSize: 18, color: Colors.white)),
                        )
                            : Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: _selecteds.length == 1,
                          child: RaisedButton(
                            color: Colors.blueGrey,
                            onPressed: () => {updateButton()},
                            child: Text(LocaleKeys.update_text.tr(),
                                style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                          ),
                        ),
                        Visibility(
                          child: Text("Bobin Sayısı : ${_sourceOriginal.length}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green)),
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: true,
                        ),

                      ])),
              buildDataTable(),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          yeniButtonClicked();
                        },
                        icon: Icon(Icons.refresh, color: Colors.white),
                        label: Text(
                          "Yeni",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                          overlayColor: MaterialStateProperty.all(Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(width: 15,),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          isSaveButtonActive();
                        },
                        icon: Icon(Icons.save, color: Colors.white),
                        label: Text(
                          "Kaydet",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green),
                          overlayColor: MaterialStateProperty.all(Colors.red),
                        ),
                      ),
                    )
                  ])
            ]),
          ),
        ) : Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SizedBoxButton(_depoSelected, _depoText, chooseDepo, "Depo Seçiniz"),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SizedBoxButton(_holSelected, _holText,holTumu ? (){} : chooseHol, "Hol Seçiniz"),
                    Column(
                      children: [
                        Checkbox(value: holTumu,
                            onChanged: (value){
                              setState(() {
                                holTumu = value!;
                                if(holTumu == true){
                                  _holSelected = false;
                                  _holID = -1;
                                }
                                else{
                                  _holID = 0;
                                }
                              });
                            }),
                        Text("Tümü")
                      ],
                    ),

                  ],
                ),
                Center(
                  child: ElevatedButton(
                    style: greenButtonStyle,
                    onPressed: () {
                      setState(() {
                        if(_depoID == null){
                          EasyLoading.showInfo("Depo Seçiniz.");
                        }
                        else{
                          pageChoose = "Tümü";
                          dbControl();
                        }
                      });
                    },
                    child: Text(
                      "Giriş",
                      style: textStyle,
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
  //region WİDGETS
  Widget _SizedBoxButton(
      bool selected, String text, Function method ,String message) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Text("HOL"),
          // SizedBox(width: 5,),
          ButtonTheme(
            minWidth: MediaQuery.of(context).size.width * 0.7,
            height: 40.0,
            buttonColor: Colors.grey[300],
            child: RaisedButton(
              onPressed: () => method(),
              child: Text(
                selected ? text : message,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  chooseDepo() async {
    depoModal(context);
  }
  depoModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemCount: _depoList.length,
              itemBuilder: (context, index) {
                return Container(
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                        title: Center(
                          child: Text(
                            '${_depoList[index].AmbarIsmi}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _depoSelected = true;
                            _depoText = _depoList[index].AmbarIsmi.toString();
                            _depoID = _depoList[index].AmbarID!;
                            print(_depoID);
                            Navigator.pop(context);
                          });
                        }));
              }),
        );
      },
    );
  }
  chooseHol() async {
    holModal(context);
  }
  holModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemCount: _holList.length,
              itemBuilder: (context, index) {
                return Container(
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
                            _holSelected = true;
                            _holText = _holList[index].HolAdi.toString();
                            _holID = _holList[index].HolID!;
                            Navigator.pop(context);
                          });
                        }));
              }),
        );
      },
    );
  }
  //endregion

  //region DATATABLE
  SingleChildScrollView buildDataTable() {
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                decoration:
                BoxDecoration(border: Border.all(color: Colors.blueGrey)),
                constraints: BoxConstraints(
                  maxHeight: 350,
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
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {},
                            ),
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
                              icon: Icon(Icons.search, color: Colors.blue, size: 20),
                              onPressed: () {
                                setState(() {
                                  _isSearch = true;
                                });
                              },
                            ),
                            TextButton(
                              child: Text(
                                "Sayım Ara",
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
                  headers: _headers,
                  source: _source,
                  selecteds: _selecteds,
                  showSelect: _showSelect,
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
                      child: Text("$_currentPage - ${(_currentPerPage! + _currentPage)}"),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                      ),
                      onPressed: _currentPage == 1
                          ? null
                          : () {
                        var _nextSet = _currentPage - _currentPerPage!;
                        setState(() {
                          _currentPage = _nextSet > 1 ? _nextSet : 1;
                          _resetData(start: _currentPage - 1);
                        });
                      },
                      padding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: _currentPage + _currentPerPage! - 1 > _total
                          ? null
                          : () {
                        var _nextSet = _currentPage + _currentPerPage!;
                        setState(() {
                          _currentPage =
                          _nextSet < _total ? _nextSet : _total - _currentPerPage!;
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
                    border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
                    color: Colors.blue,
                  ),
                  headerTextStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  rowTextStyle: TextStyle(color: Colors.black),
                  selectedTextStyle: TextStyle(color: Colors.white),
                ),

              ),
            ]));
  }
  _resetData({start: 0}) async {
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
  void onSelectAll(bool? value) {
    if (value!) {
      setState(() => {
        _selecteds = _source.map((entry) => entry).toList().cast(),
        print(_selecteds),
        isDeleteButtonVisible = true
      });
    } else {
      setState(() => {_selecteds.clear(), isDeleteButtonVisible = false});
    }
  }
  void responsiveTblSelected(bool? value, Map<String, dynamic> item) {
    if (value!) {
      setState(() => {
        _selecteds.add(item),
        isDeleteButtonVisible = true,
        if (_selecteds.length == 1)
          {
            _barcodeTextFieldController.text = _selecteds[0]["BarkodID"].toString(),
            _kgTextFieldController.text =
                _selecteds[0]["Miktar"].toString(),

          }
        else
          {
            _barcodeTextFieldController.clear(),
            _kgTextFieldController.clear(),
          }
      });
    } else {
      setState(() => {
        _selecteds.removeAt(_selecteds.indexOf(item)),
        if(_selecteds.length == 1){
          _barcodeTextFieldController.text = _selecteds[0]["BarkodID"].toString(),
          _kgTextFieldController.text = _selecteds[0]["Miktar"].toString(),
        }
        else{
          _barcodeTextFieldController.clear(),
          _kgTextFieldController.clear(),
        }
      });
    }
  }
  showDate(date) {
    if (date.toString().isEmpty) {
      return "";
    } else {
      return DateFormat("dd-MM-yyyy").format(DateTime.parse(date));
    }
  }
  //endregion




  yeniButtonClicked() async {
    setState(() {
      updateButtonSelected = false;
      isDeleteButtonVisible = false;
      araButtonSelected = false;
      _barcodeTextFieldController.clear();
      _kgTextFieldController.clear();
    });
    barcodeFocusNode!.requestFocus();  }
  errorOnBarcodeControl() async {
    setState(() {
      _kgTextFieldController.clear();
    });
  }


  ///////////////////////////// SAVE FONKSİYONU /////////////////////////////

  isSaveButtonActive() async {
    EasyLoading.show(status: "Kaydediliyor...");
    if (_sourceOriginal.isEmpty == false) {
      if (updateButtonSelected) {
        updateButtonSaveDB();
        EasyLoading.dismiss();
      } else {
        await checkForSavingToDB();
        await onSuccess();
        await dbControl();
        EasyLoading.showSuccess("Kaydedldi.");
      }
      return true;
    } else {
      EasyLoading.showInfo("${LocaleKeys.fillAllFields_text.tr()}");
      return false;
    }
  }

  updateButtonSaveDB() async {
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show();
    var dbClient = await db;
    for (int i = 0; i < _sourceOriginal.length; i++) {
      var firstQuery =
          "INSERT INTO Sayimlar (ID, BarkodID, Miktar ,StokID ,Tarih,Modul  ,EvrakID     ,Durum    ,DepoID , BobinChangeTime,BobinSyncStatus,IsSend,Aktif,IsDeleted ) VALUES ((SELECT MAX(ID) + 1 as EvrakID from Sayimlar), ${_sourceOriginal[i]["BarkodID"]} ,${_sourceOriginal[i]["Miktar"]} ,${_sourceOriginal[i]["StokID"]}   ,''   ,1       ,0  ,0  ,${_depoID} ,'$selectedDate',1,True,False)";
      await dbClient.rawQuery(firstQuery).catchError((onError) {
        onError();
      }).whenComplete(() {
        onSuccess();
      });
    }



  }

  checkForSavingToDB() async {
    EasyLoading.instance.userInteractions = false;
    var dbClient = await db;
    for (int i = 0; i < _sourceOriginal.length; i++) {
      var firstQuery = "";
      print(_sourceOriginal);
      if(_sourceOriginal[i]["BobinSyncStatus"] == null){
        firstQuery =
        "INSERT INTO Sayimlar (ID,BarkodID,Miktar,StokID,FisNo,Tarih,Modul,Durum,DepoID,HolId,CreatedDate,BobinSyncStatus,IsSend,Aktif,IsDeleted) VALUES (0,  ${_sourceOriginal[i]["BarkodID"]} ,${_sourceOriginal[i]["Miktar"]} ,${_sourceOriginal[i]["StokID"]},'$fisNo','${DateTime.now().toIso8601String()}'    ,1   ,0      ,${_depoID},${_holID},'${DateTime.now()}',1,1,True,False)";
      }
      else if(_sourceOriginal[i]["BobinSyncStatus"] == 1){
        firstQuery =
        "UPDATE Sayimlar SET Miktar = ${_sourceOriginal[i]["Miktar"]} where BarkodID=${_sourceOriginal[i]["BarkodID"]}";
      }
      else {
        firstQuery =
        "UPDATE Sayimlar SET BobinSyncStatus = 2, Miktar = ${_sourceOriginal[i]["Miktar"]} where BarkodID=${_sourceOriginal[i]["BarkodID"]}";
      }


      // if(_sourceOriginal[i]["BobinSyncStatus"] == null){
      //   firstQuery =
      //   "INSERT INTO Sayimlar (ID,BarkodID,Miktar,StokID,FisNo,Tarih,Modul,Durum,DepoID,HolId,BobinChangeTime,BobinChangeType, BobinSyncStatus, IsSend) VALUES (0,  ${_sourceOriginal[i]["BarkodID"]} ,${_sourceOriginal[i]["Miktar"]} ,${_sourceOriginal[i]["StokID"]},'$fisNo','${DateTime.now()}'    ,1   ,0      ,${_depoID},${_holID},'${DateTime.now()}',1,0,1)";
      // }
      // else if(_sourceOriginal[i]["BobinSyncStatus"] == 0 && _sourceOriginal[i]["BobinChangeType"] == 1){
      //   firstQuery =
      //   "UPDATE Sayimlar SET Miktar = ${_sourceOriginal[i]["Miktar"]} where BarkodID=${_sourceOriginal[i]["BarkodID"]}";
      // }
      // else {
      //   firstQuery =
      //   "UPDATE Sayimlar SET BobinChangeType = 2, Miktar = ${_sourceOriginal[i]["Miktar"]} where BarkodID=${_sourceOriginal[i]["BarkodID"]}";
      // }
      await dbClient.rawQuery(firstQuery);
    }

  }

  onError() {
    EasyLoading.showError("${LocaleKeys.error_text.tr()}");
  }

  onSuccess() async {
    if (globals.updatePeriod == 1) {
      // await updateFunction();
    }
    EasyLoading.showSuccess("${LocaleKeys.saved_text.tr()}.");
    yeniButtonClicked();
  }
  deleteVariables(int i) async {
    if (i == 0) {
      setState(() {
        _barcodeTextFieldController.clear();
        _kgTextFieldController.clear();
        _selecteds.clear();
        isDeleteButtonVisible = false;
      });
    } else {
      setState(() {
        _barcodeTextFieldController.clear();
        _kgTextFieldController.clear();
        isDeleteButtonVisible = false;
      });
    }
  }
  updateButton() {
    setState(() {
      print(_source.length);
      _sourceOriginal[_sourceOriginal.indexWhere(
              (element) => element["BarkodID"] == _selecteds[0]["BarkodID"])]
      ["BarkodID"] = _barcodeTextFieldController.text;
      _sourceOriginal[_sourceOriginal.indexWhere(
              (element) => element["BarkodID"] == _selecteds[0]["BarkodID"])]
      ["Miktar"] = _kgTextFieldController.text;
      deleteVariables(0);
      EasyLoading.showSuccess("Güncellendi");
    });
  }

  ///////////////////////////// DELETE FONKSİYONU /////////////////////////////
  deleteSelected() async {
    var dbClient = await db;
    setState(() {
      for (var select in _selecteds) {
        var firstQuery =
            "UPDATE Sayimlar SET BobinSyncStatus = 3,Durum = 2 where BarkodID=${select["BarkodID"]}";
        // "delete from Sayimlar";
        dbClient.rawQuery(firstQuery);
        _isSearch = false;
        _filterData("");
        _sourceOriginal.remove(select);
      }
      _selecteds.clear();
    });
    EasyLoading.showSuccess("Sayımlar Silindi");
    _refreshData();
    print(_source.length);
    deleteVariables(0);
    // List<Sayim> temp = [];
    // for (int i = 0; i < sayimTableList.length; i++) {
    //   if (tableSelectedList.where((element) => element == i).isEmpty)
    //     neww.add(sayimTableList[i]);
    // }
    //
    // setState(() {
    //   sayimTableList = temp;
    //   tableSelectedList = [];
    //   isDeleteButtonVisible = false;
    // });
  }

  getBarkodAndStokID() async {
    var dbClient = await db;
    var query =
        "SELECT Id,Barkod, StokID FROM Stok_Karti_Barkod WHERE Barkod = ${_barcodeTextFieldController.text}";
    var result = await dbClient.rawQuery(query);
    print("result22 $result");
    setState(() {
      isDeleteButtonVisible = true;
      var added = new Sayimlar(
        BarkodID: int.parse(result[0]["Id"].toString()),
        Barkod: result[0]["Barkod"].toString(),
        Miktar: double.parse(_kgTextFieldController.text.toString()),
        StokID: int.parse(result[0]["StokId"].toString()),
        BobinChangeType: 1,
        BobinSyncStatus: null,
      );
      _sourceOriginal.insert(0,added.toMap());
      print(_sourceOriginal);
      _sourceFiltered = _sourceOriginal;
      _total = _sourceFiltered.length;
      if (_sourceFiltered.length < _currentPerPage!) {
        _source =
            _sourceFiltered.getRange(0, _sourceFiltered.length).toList();
        print(_source);

        return;
      }
      _source = _sourceFiltered.getRange(0, _currentPerPage!).toList();
      print(_source);
    });
  }

  /////////////// Ekle Butonu İşlevi ///////////////
  addIFNotSame(barcode, kg) async {

    for (int i = 0; i < _sourceOriginal.length; i++) {
      if (barcode.toString() == _sourceOriginal[i]["Barkod"].toString()) {
        print("Aynııııı");
        showAlertWithOKButton(
            context, "${LocaleKeys.error_text.tr()}", LocaleKeys.canAddOneSameBarcode_text.tr());
        return true;
      }
    }
    return false;
  }

  //Aynı barkodu 2 defa saymamak için
  didItemCountedTodayFunc(barcode) async {
    print("barcode $barcode");
    var dbClient = await db;
    var query =
        "SELECT count (skb.Barkod) from Sayimlar inner join Stok_Karti_Barkod as skb on skb.Id = Sayimlar.BarkodID where skb.Barkod = $barcode and date(Sayimlar.Tarih) = date('now')";
    var result = await dbClient.rawQuery(query);
    if (int.parse(result[0]["count (skb.Barkod)"].toString()) > 0) {
      showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", LocaleKeys.barcodeWasCountedToday_text.tr());
      return true;
    } else {
      return false;
    }
  }

  addToKgAndEnToListView(barcode, kg) async {
    var sameObject = await addIFNotSame(barcode, kg);
    var didItemCountedToday = await didItemCountedTodayFunc(barcode);
    if (sameObject == false && didItemCountedToday == false) {
      print("barcode $barcode kg ${kg.toString()}");
      var dbClient = await db;
      var query =
          "SELECT dh.Id FROM Depo_Hareketleri as dh "
          "INNER JOIN Stok_Karti_Barkod as sk ON sk.Id = dh.BarkodId"
          " WHERE sk.Barkod = $barcode LIMIT 1";
      // "SELECT DepoHareketID FROM Depo_Hareketleri  WHERE AmbarID = ${depoID} AND LotNo = $barcode AND Durum = 0 LIMIT 1";
      var result = await dbClient.rawQuery(query);
      print("result12 $result");
      print("que $query");
      if (result.length > 0) {
        await getBarkodAndStokID();
      } else {
        showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", "${LocaleKeys.bobbinNotDefined_text.tr()}.");
      }
    }
  }

  onPressedAddButton() async {
    if (_barcodeTextFieldController.text.isEmpty &&
        _kgTextFieldController.toString().isEmpty) {
      EasyLoading.showError(LocaleKeys.fillAllFields_text.tr());
    } else if (_barcodeTextFieldController.text.isEmpty ||
        int.parse(_barcodeTextFieldController.text) == 0) {
      EasyLoading.showError(LocaleKeys.fillAllFields_text.tr());
    } else if (_kgTextFieldController.toString().isEmpty ||
        double.parse(_kgTextFieldController.text) == 0) {
      EasyLoading.showError(LocaleKeys.fillAllFields_text.tr());
    } else {
      print("elsee");
      await addToKgAndEnToListView(
          _barcodeTextFieldController.text, _kgTextFieldController.text);
      _barcodeTextFieldController.clear();
      _kgTextFieldController.clear();
      barcodeFocusNode!.requestFocus();    }
  }

  //////////////////////////////// BARKOD VE DURUM KONTROLÜ ////////////////////////////////
  checkDurum(value, durum) async {
    if (durum == 0) {
      print("Aynı depodalar");
      await checkBarcodeFromDB(value);
    } else {
      errorOnBarcodeControl();
      if (durum == 1) {
        showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", LocaleKeys.bobbinCancel_text.tr());
      } else if (durum == 2) {
        showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", "${LocaleKeys.bobbinDelete_text.tr()}");
      } else if (durum == 3) {
        showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", "${LocaleKeys.bobbinFinish_text.tr()}.");
      }
    }
  }

  checkBarcodeFromDB(value) async {
    var dbClient = await db;
    var existQuery =
        "Select count(Id) as count from Stok_Karti_Barkod where Barkod = '$value' ";
    var checkIsExist = await dbClient.rawQuery(existQuery);
    print("checkIsExist ${checkIsExist[0]["count"]}");
    if (int.parse(checkIsExist[0]["count"].toString()) > 0) {
      var query =
          "SELECT SUM(dh.Miktar) as Miktar FROM Depo_Hareketleri as dh "
          "INNER JOIN Stok_Karti_Barkod as sk ON sk.Id = dh.BarkodId "
          "WHERE sk.Barkod = ${_barcodeTextFieldController.text}";
      // "SELECT SUM(Miktar) as Miktar FROM Depo_Hareketleri  WHERE AmbarID = ${depoID} AND LotNo = ${_barcodeTextFieldController.text} AND Durum = 0 ";
      print("que $query");
      var result = await dbClient.rawQuery(query);
      if (result.first["Miktar"] == null) {
        EasyLoading.showError("${LocaleKeys.bobbinNotDefined_text.tr()}.");
        await errorOnBarcodeControl();
      }
      // if (result.length >= 0) {
      else if (result[0]["Miktar"] != null) {
        _kgTextFieldController.text = double.parse(result[0]["Miktar"].toString()).toInt().toString();
        onPressedAddButton();
      }
    } else {
      print("aa0");
      EasyLoading.showError("${LocaleKeys.bobbinNotDefined_text.tr()}.");
      errorOnBarcodeControl();
    }
  }

  initialCheckBarcodeFromDB(value) async {
    var query =
        "SELECT Durum FROM Stok_Karti_Barkod	WHERE BarkodID = '$value' ";
    var dbClient = await db;
    var result = await dbClient.rawQuery(query);
    print("Durum kontrolü $result");
    if (result.length > 0) {
      print("Durum >0 $result");
      await checkDurum(value, result[0]["Durum"]);
    } else {
      errorOnBarcodeControl();
      EasyLoading.showError("${LocaleKeys.bobbinNotDefined_text.tr()}.");
      EasyLoading.dismiss();
    }
  }

  getTextFieldText(value) async {
    await checkBarcodeFromDB(_barcodeTextFieldController.text);
  }

  ////////////////////////// Tarih //////////////////////////
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

  onTapDepoRightBarButton() async {
    EasyLoading.show();
    var depolar = await getAllDepolar();
    print("depolar ${depolar}");
    EasyLoading.dismiss();
    if (depolar.length == 1) {
      showAlertWithOKButton(context, "${LocaleKeys.wareHouseCount_text.tr()}", "${LocaleKeys.thereIsOne_text.tr()}");
    } else {
      displayDepoBottomSheet(context, depolar);
    }
  }

  displayDepoBottomSheet(BuildContext context, _depoList) {
    print(
        "_depoList.length ${_depoList.length} _depoList $_depoList  ${_depoList[0]}");
    showModalBottomSheet(
        context: context,
        isDismissible: false,
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
                            _depoID = _depoList[index]["AmbarID"];
                            Navigator.pop(context);
                          });
                        })),
              ),
            ),
          );
        });
  }
  sayimBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                ElevatedButton(onPressed: (){}, child: Text("asd"))
              ],
            ),
          );
        });
  }

}
