import 'package:date_format/date_format.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:sqflite/sqflite.dart';

import '../../helper/languages/locale_keys.g.dart';

class LogScreen extends StatefulWidget {
  int logId = 0;
  LogScreen(this.logId,{Key? key}) : super(key: key);

  @override
  State<LogScreen> createState() => _LogScreenState(this.logId);
}

class _LogScreenState extends State<LogScreen> {
  var db = openDatabase('BSSBobinDBLog.db');
  int logId = 0;
  String logName = "";
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
  bool showAll = false;
  Color color = Colors.white;
  late List<DatatableHeader> _headers = [];
  String? _sortColumn;
  bool _sortAscending = true;
  bool _isLoading = false;
  _LogScreenState(this.logId);
//region Tarih
  String secilenAramaBaslangicTarihStr = "";
  String secilenAramaBitisTarihStr = "";
  DateTime today = new DateTime.now();
  DateTime lastDate = new DateTime.now();
  DateTime aramaBaslangicTarihi = new DateTime.now();
  //endregion
  @override
  void initState() {
    lastDate = today.add(new Duration(days: 1000));
    aramaBaslangicTarihi = today.add(new Duration(days: -1000));
    print(today);
    secilenAramaBaslangicTarihStr = formatDate(today, [yyyy,'-', mm,'-',dd]);
    secilenAramaBitisTarihStr = formatDate(today, [yyyy,'-', mm,'-',dd]);    prepareLog();
  }
  Future<void> prepareLog() async {
    String query = '';
    switch(logId){
      case 1 :
        query = "select LotNo,Miktar,HareketID,DepoHareketID,strftime('%d-%m-%Y %H:%M', BobinChangeTime) AS Tarih from LogDepoHareketleri where BobinChangeTime >= '${secilenAramaBaslangicTarihStr} 00:00:00' AND BobinChangeTime <= '${secilenAramaBitisTarihStr} 23:59:59'";
        logName = "Depo Hareketleri";
        _headers = [
          DatatableHeader(
            flex: 2,
            text: "Barkod",
            value: "LotNo",
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
              flex: 1,
              text: "H.Id",
              value: "HareketID",
              show: true,
              sortable: false,
              textAlign: TextAlign.center),
          DatatableHeader(
              flex: 1,
              text: "DH.Id",
              value: "DepoHareketID",
              show: true,
              sortable: false,
              textAlign: TextAlign.center),
          DatatableHeader(
              flex: 2,
              text: "Tarih",
              value: "Tarih",
              show: true,
              sortable: false,
              textAlign: TextAlign.center),
        ];
        break;
      case 2 :
        query = "select LotNo,Miktar,HareketID,DepoHareketID,strftime('%d-%m-%Y %H:%M', Tarih) AS Tarih from LogGonderilenDh where Tarih >= '${secilenAramaBaslangicTarihStr} 00:00:00' AND Tarih <= '${secilenAramaBitisTarihStr} 23:59:59'";
        logName = "Gönderilen Depo Hareketleri";

        _headers = [
          DatatableHeader(
            flex: 2,
            text: "LotNo",
            value: "LotNo",
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
              text: "H.Id",
              value: "HareketID",
              show: true,
              sortable: false,
              textAlign: TextAlign.center),
          DatatableHeader(
              flex: 2,
              text: "DH.Id",
              value: "DepoHareketID",
              show: true,
              sortable: false,
              textAlign: TextAlign.center),
          DatatableHeader(
              flex: 4,
              text: "Tarih",
              value: "Tarih",
              show: true,
              sortable: false,
              textAlign: TextAlign.center),
        ];
        break;
      case 3 :
        query = "select Hata,strftime('%d-%m-%Y %H:%M', Tarih) AS Tarih from LogHata where Tarih >= '${secilenAramaBaslangicTarihStr} 00:00:00' AND Tarih <= '${secilenAramaBitisTarihStr} 23:59:59'";
        logName = "Hatalar";
        _headers = [
          DatatableHeader(
            flex: 2,
            text: "Hata",
            value: "Hata",
            show: true,
            sortable: true,
            textAlign: TextAlign.center,
          ),
          DatatableHeader(
              flex: 1,
              editable: false,
              text: "Tarih",
              value: "Tarih",
              show: true,
              sortable: false,
              textAlign: TextAlign.center),
        ];
        break;
    }
    print("que $query");
    await getData(query);
  }
  getData(query) async {
    // String query = await prepareLog();
    var dbClient = await db;
    _sourceOriginal = [];
    _selecteds = [];
    _expanded = List.generate(_currentPerPage!, (index) => false);
    _isLoading = true;

    _sourceOriginal.addAll(await dbClient.rawQuery(query));
    await _refreshData();
    _isLoading = false;
    print(_sourceOriginal);
  }

  getDataDetay(item) async {
    var dbClient = await db;
    var query = "select * from LogDepoHareketleri where LotNo = ${item["LotNo"]} and HareketID = ${item["HareketID"]}";
    var res = await dbClient.rawQuery(query);
    print(res.first);
    String formattedProperties = res.first.toString().split(',').join('\n');
    _showTextDialog(context,formattedProperties);
  }
  Future<void> _showTextDialog(BuildContext context, String text) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detay'),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log $logName"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildDataTable(),
          ],
        ),
      ),

    );
  }
  SingleChildScrollView buildDataTable() {
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 5, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(
                              "${LocaleKeys.startDate_text.tr()}: ",
                              style:
                              TextStyle(color: Colors.black54, fontSize: 15),
                            ),
                            TextButton(
                              child: Text(
                                secilenAramaBaslangicTarihStr,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onPressed: () {
                                buildShowDatePicker(context).then((value) {
                                  setState(() {
                                    secilenAramaBaslangicTarihStr = formatDate(
                                        value!, [yyyy,'-', mm,'-',dd]);
                                  });
                                });
                              },
                            ),
                          ],
                        )),
                    Expanded(
                        child: Column(children: <Widget>[
                          Text(
                            "Bitiş Tarihi: ",
                            style: TextStyle(color: Colors.black54, fontSize: 18),
                          ),
                          TextButton(
                            child: Text(
                              secilenAramaBitisTarihStr,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,decoration: TextDecoration.underline,
                              ),
                            ),
                            onPressed: () {
                              buildShowDatePicker(context).then((value) {
                                setState(() {
                                  secilenAramaBitisTarihStr = formatDate(
                                      value!, [yyyy,'-', mm,'-',dd]);
                                });
                              });
                            },
                          ),
                        ])),
                    Expanded(
                      flex: 0,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await prepareLog();
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
              ),
              Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                decoration:
                BoxDecoration(border: Border.all(color: Colors.black)),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: ResponsiveDatatable(

                  reponseScreenSizes: [ScreenSize.xl],
                  hideUnderline: true,
                  actions: logId == 3 ? [] :[
                    if (_isSearch)
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Ara',
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
                              icon: Icon(Icons.search,
                                  color: Colors.blue, size: 20),
                              onPressed: () {
                                setState(() {
                                  _isSearch = true;
                                });
                              },
                            ),
                            TextButton(
                              child: Text(
                                "Ara",
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
                  onTabRow: (value) async {
                    if(logId == 1 || logId ==2){
                      await getDataDetay(value);
                    }
                  },
                  title: SizedBox(),
                  headers: _headers,
                  source: _source,
                  selecteds: _selecteds,
                  // showSelect: true,
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
            ]));
  }
  Future<DateTime?> buildShowDatePicker(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: today,
      firstDate: aramaBaslangicTarihi,
      lastDate: lastDate,


    );
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
            .where((data) => data['LotNo']
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
}
