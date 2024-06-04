import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bss_mobile_premium/globals/globals.dart';

import '../../helper/widgetHelper.dart';

class BarkodEtiket extends StatefulWidget {
  int irsaliyeId = 0;
   BarkodEtiket(this.irsaliyeId,{Key? key}) : super(key: key);

  @override
  State<BarkodEtiket> createState() => _BarkodEtiketState(irsaliyeId);
}

class _BarkodEtiketState extends State<BarkodEtiket> {
  late TextEditingController _barcodeTextFieldController = new TextEditingController();
  List<String> toPrintList = <String>[];
  late var dropDownlist = <String>[""];
  String dropdownValue = "";
  TextEditingController copyCountController = new TextEditingController();
   var db = openDatabase('BSSBobinDB.db');
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
   String pageChoose = "";
   int irsaliyeId = 0;
   String networkURL = "";
   List<dynamic> raporlar = <dynamic>[];
   bool raporSelected = false;
   int raporId = 0;
   String raporText = "";
   _BarkodEtiketState(irsaliyeId);
   @override
   void initState() {
     super.initState();
     getFirstData();
     irsaliyeId = widget.irsaliyeId;
     print(widget.irsaliyeId);
     copyCountController.text = "1";
   }
    getFirstData () async {
     // EasyLoading.show();
      networkURL = await getSaveDPortAndIPToSayim();
      await getPrint();
     await getIrsaliyeTableData();
     raporSelected = true;
     raporText = raporlar.first["Ad"];
     raporId = raporlar.first["Id"];
     EasyLoading.dismiss();
    }
   getSaveDPortAndIPToSayim() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     String? getPortAndIP = prefs.getString('port_and_ip');
     return getPortAndIP;
   }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Barkod Etiket"),
      // ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  color: Colors.grey,
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(0),
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Center(
                      child: DropdownButton<String>(
                        itemHeight: 50,
                        menuMaxHeight: MediaQuery.of(context).size.height*0.5,
                        dropdownColor: Colors.grey,
                        value: dropdownValue,
                        icon: const Icon(Icons.print,color: Colors.white),
                        elevation: 20,
                        style: const TextStyle(color: Colors.white),
                        underline: Container(
                          height: 0,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                        isExpanded: true,
                        items: dropDownlist.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: Text(value,style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold,fontSize: 15,overflow: TextOverflow.ellipsis),maxLines: 2,)),
                                Divider(
                                  color: Colors.white,
                                  height: 1,
                                  thickness: 2,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 0,
                            child: Text(
                              "RAPOR :  ",
                              textAlign: TextAlign.center,
                              style: textStyle,
                            ),
                          ),

                          Expanded(
                            child: ButtonTheme(
                              height: 40.0,
                              buttonColor: Colors.black45,
                              child: RaisedButton(
                                onPressed: () => {
                                  chooseRapor(context),
                                },
                                child: SizedBox(
                                  child: Center(
                                    child: Text(
                                      raporSelected ? raporText : "Seçiniz",
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(flex: 0, child: SizedBox()),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              "KOPYA SAYISI :",
                              textAlign: TextAlign.center,
                              style: textStyle,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: copyCountController,
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
                    )

                  ],
                ),
                SizedBox(height: 5,),
                irsaliyeId == -1 ?
                Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child : BarcodeRow(
                    barcodeTextFieldController: _barcodeTextFieldController,
                    getTextFieldText: getTextFieldText,
                    errorOnBarcodeControl: ()=>{},
                  ),
                ) : buildDataTable(),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close, color: Colors.white),
                          label: Text(
                            "Kapat",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.red),
                            overlayColor: MaterialStateProperty.all(Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await postPrint();
                         },
                          icon: Icon(Icons.print_outlined, color: Colors.white),
                          label: Text(
                            "Yazdır",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue),
                            overlayColor: MaterialStateProperty.all(Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  getTextFieldText(value) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var programRadio = _prefs.getString("programRadio");
    print("pr : $programRadio");

    if(programRadio == 'Win Project'){
      _barcodeTextFieldController.text = int.parse(_barcodeTextFieldController.text.toString())
          .toString()
          .replaceAll(RegExp(r'.$'), "");
    }
    await checkBarcodeFromDB(_barcodeTextFieldController.text);
  }
  checkBarcodeFromDB(value) async {
    var query = "Select * From Stok_Karti_Barkod where Barkod = $value";
    var dbClient = await db;
    var result = await dbClient.rawQuery(query);
    toPrintList.add(_barcodeTextFieldController.text);
    if (result.length > 0) {
      toPrintList.add(_barcodeTextFieldController.text);
    }
    else {
    EasyLoading.showInfo("Bobin Sistemde Tanımlı Değil.");
    }
  }

  chooseRapor(BuildContext context) async {
     showModalBottomSheet(
       context: context,
       builder: (ctx) {
         return Container(
           height: MediaQuery.of(context).size.height * 0.5,
           child: ListView.separated(
               separatorBuilder: (context, index) => Divider(
                 color: Colors.black,
               ),
               itemCount: raporlar.length,
               itemBuilder: (context, index) {
                 return Container(
                   height: 40,
                     margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                     child: ListTile(
                         title: Center(
                           child: Text(
                             '${raporlar[index]["Ad"]}',
                             style: TextStyle(fontSize: 20),
                           ),
                         ),
                         onTap: () {
                           setState(() {
                             raporSelected = true;
                             raporText = raporlar[index]["Ad"];
                             raporId = raporlar[index]["Id"];

                             Navigator.pop(context);
                           });
                         }));
               }),
         );
       },
     );
   }

   postPrint() async {
     EasyLoading.show(status: "Yazdırılıyor...");
     try{
       toPrintList.insert(0,raporId.toString());
       toPrintList.insert(1,dropdownValue);
       toPrintList.insert(2,copyCountController.text);
       print(toPrintList);
       if(_selecteds.length > 0)
       _selecteds.forEach((element) {toPrintList.add(element["Barkod"].toString());});
       if(toPrintList.length <= 3){
         EasyLoading.showInfo("Barkod Seçiniz.");
         toPrintList.clear();
         return;
       }
       print(toPrintList);
       print(_selecteds);
       var url = Uri.parse( networkURL + "/api/Irsaliye/EtiketYazdir");
       print(url);
       print(toPrintList);
       var response = await post(url,
         headers: <String, String>{
           'Content-Type': 'application/json; charset=UTF-8',
         },
         body: jsonEncode(toPrintList),
       );
       toPrintList.clear();
       setState(() {
         _selecteds.clear();
       });
       EasyLoading.dismiss();
        print(toPrintList);
        print(_selecteds);
       if (response.statusCode == 200) {
         EasyLoading.showSuccess("Yazdırma işlemi başarılı");
       } else {
         EasyLoading.showSuccess("Yazdırma işlemi başarısız. Hata : ${response.body}--${response.statusCode}");
         print(response.body);
       }
     }
     catch(exception){
       toPrintList.clear();
       EasyLoading.showError("Hata : $exception");
     }

   }
    getPrint() async {
     try{
       var url = Uri.parse( networkURL + "/api/Irsaliye/EtiketBilgiler");
       var response = await get(url).timeout(Duration(seconds: 10));

       if (response.statusCode == 200) {
         setState(() {
           dropDownlist.clear();
           dropDownlist = jsonDecode(response.body)["Yazicilar"].cast<String>();
           dropdownValue = dropDownlist.first;
           raporlar = jsonDecode(response.body)["Raporlar"];
           print(raporlar);

         });
       } else {
         print('Request failed with status: ${response.statusCode}.');
       }
     }
     catch(ex){
       EasyLoading.showError("Hata : $ex");
     }

   }
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
                 BoxDecoration(border: Border.all(color: Colors.black)),
                 constraints: BoxConstraints(
                   maxHeight: MediaQuery.of(context).size.height * 0.60,
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
                   title: SizedBox(),
                   headers: _headers,
                   source: _source,
                   selecteds: _selecteds,
                   showSelect: true,
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
     _sourceOriginal.sort((a, b) => b['Barkod'].compareTo(a['Barkod']));
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
   getIrsaliyeTableData() async {
     var dbClient = await db;
     _sourceOriginal = [];
     _selecteds = [];
     _expanded = List.generate(_currentPerPage!, (index) => false);
     _isLoading = true;

       // var queryAll =
       //     "select Stok_Karti_Barkod.Id,Stok_Karti_Barkod.Barkod,Stok_Karti_Barkod.Miktar,Stok_Karti.RefAd,Depo_Hareketleri.Miktar,"
       //     "Stok_Karti_Barkod.TedarikciBarkodNo,1 as kabulMu from Stok_Karti_Barkod  Inner Join Stok_Karti on "
       //     "Stok_Karti.Id = Stok_Karti_Barkod.StokID Inner Join Depo_Hareketleri on Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id"
       //     " Where DepoHareketTipId = 14 And RefDetayId = $irsaliyeId";
     var queryAll =
     ''' select Stok_Karti_Barkod.Id,Stok_Karti_Barkod.Barkod,Stok_Karti.RefAd,Depo_Hareketleri.Birim1Miktari as Miktar,Stok_Karti_Barkod.TedarikciBarkodNo,1 as kabulMu
           from Stok_Karti_Barkod 
           Inner Join Depo_Hareketleri on Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id
            Inner Join Stok_Karti on Stok_Karti.Id = Depo_Hareketleri.StokID
           Where DepoHareketTipiId = 14 and Stok_Karti_Barkod.RefDetayId = $irsaliyeId  ''';
       if(irsaliyeId == 0){
         var queryAll =
         ''' select Stok_Karti_Barkod.Id,Stok_Karti_Barkod.Barkod,Stok_Karti.RefAd,Depo_Hareketleri.Birim1Miktari as Miktar,Stok_Karti_Barkod.TedarikciBarkodNo,1 as kabulMu
           from Stok_Karti_Barkod 
           Inner Join Depo_Hareketleri on Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id
            Inner Join Stok_Karti on Stok_Karti.Id = Depo_Hareketleri.StokID
           Where DepoHareketTipiId = 14 ''';
       }
       _sourceOriginal.addAll(await dbClient.rawQuery(queryAll));
       await _refreshData();
     _isLoading = false;
   }

}
