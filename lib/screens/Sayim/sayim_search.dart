import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import '../../data_model/sayimlar.dart';
import '../../data_model/services/sayimlar_services.dart';
import '../../helper/languages/locale_keys.g.dart';


class SayimSearchModal extends StatefulWidget {
  final depoId;
  SayimSearchModal({Key? key, required this.depoId}) : super(key: key);

  @override
  _SayimSearchModalState createState() => _SayimSearchModalState();
}

class _SayimSearchModalState extends State<SayimSearchModal> {
  DateFormat dateFormat = DateFormat("MM-dd-yyyy");
  var db = openDatabase('BSSBobinDB.db');
  //Sayımlar
  String sayimText = "";
  bool sayimTextSelected = false;
  var _sayim = Sayimlar();
  var _sayimService = SayimlarService();
  List<Sayimlar> _sayimlarList = <Sayimlar>[];
  List<Sayimlar> _sayimlarSearchList = <Sayimlar>[];
  List<Sayimlar> _sayimlarEmptyList= <Sayimlar>[];

  bool isSearching = false;

  getMusterilerInit() async{
    _sayimlarList = <Sayimlar>[];
    var dbClient = await db;
    var stokKartiUpdateQuery = "SELECT Tarih,Miktar,BarkodID,StokID,EvrakID,count(*) as EvrakSayisi From Sayimlar where DepoID=${widget.depoId} GROUP BY EvrakID";
    var categories = await dbClient.rawQuery(stokKartiUpdateQuery);


    //_sayimService.readSayimlarById(widget.depoId);
    print("categories $categories");
    categories.forEach((depo) {
      setState(() {
        var depoModel = Sayimlar();
        depoModel.Tarih = depo['Tarih'] as String?;
        depoModel.EvrakID = depo['EvrakID'] as int?;
        depoModel.Miktar = double.parse(depo['Miktar'].toString());
        depoModel.BarkodID = depo['BarkodID'] as int?;
        depoModel.StokID = depo['StokID'] as int?;
        depoModel.BobinChangeType = depo["EvrakSayisi"] as int?;
        _sayimlarList.add(depoModel);
        _sayimlarSearchList.add(depoModel);
      });
    });
    // print("Categories");
    // print(categories);
  }

  @override
  void initState() {
    super.initState();
    getMusterilerInit();
  }

  void _filterCountries(value) {
    setState(() {
      _sayimlarSearchList = _sayimlarList
          .where((country) =>
          country.Tarih!.contains(value.toLowerCase()))
          .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xFF6200EE),

        // title: Text('Full-screen Dialog'),
        title: TextField(
          onChanged: (value) {
            _filterCountries(value);
          },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintText: LocaleKeys.search_text.tr(),
              hintStyle: TextStyle(color: Colors.white)),
        ),
        actions: <Widget>[
          isSearching
              ? IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                this.isSearching = false;
                _sayimlarSearchList = _sayimlarList;
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
          child: Column(children: <Widget>[
            SizedBox(
              height: 20,
              child:
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:<Widget>[
                    Text(
                      LocaleKeys.documentId_text.tr(),
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      LocaleKeys.documentCount_text.tr(),
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      LocaleKeys.date_text.tr(),
                      style: TextStyle(fontSize: 18),
                    ),
                  ]
              ),

            ),


            Container(height: 500,
              child: _sayimlarSearchList.length > 0
                  ? ListView.builder(
                  itemCount: _sayimlarSearchList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, [_sayimlarSearchList[index].EvrakID,_sayimlarSearchList[index].BarkodID,_sayimlarSearchList[index].Miktar,_sayimlarSearchList[index].StokID,_sayimlarSearchList[index].Tarih] );
                      },
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:<Widget>[

                                Text(
                                  _sayimlarSearchList[index].EvrakID.toString(),
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  _sayimlarSearchList[index].BobinChangeType.toString(),
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(showDate(_sayimlarSearchList[index].Tarih.toString()),
                                  style: TextStyle(fontSize: 18),
                                ),
                              ]
                          ),
                        ),
                      ),
                    );
                  })
                  : Center(
                child: Text(LocaleKeys.countFound_text.tr()),
              ),
            ),
          ],)
      ),

    );
  }
  showDate(date){
    return DateFormat("dd-MM-yyyy").format(DateTime.parse(date));
  }
}
