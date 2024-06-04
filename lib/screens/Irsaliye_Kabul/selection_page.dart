import 'package:date_format/date_format.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../helper/languages/locale_keys.g.dart';


class SelectionScreen extends StatefulWidget {
  String name = "";
  int id = 0;


  SelectionScreen( this.name,this.id, {Key? key}) : super(key: key);

  @override
  _SelectionScreenState createState() => _SelectionScreenState(name,id);
}

class _SelectionScreenState extends State<SelectionScreen> {
  var irsaliyeTextStyle = TextStyle(
      fontSize: 17.0, color: Colors.black, fontWeight: FontWeight.normal);
  var textStyle = TextStyle(fontSize: 25.0, color: Colors.black);
  var textStyle2 = TextStyle(fontSize: 10.0, color: Colors.black);
  String secilenAramaBaslangicTarihStr = "";
  String secilenAramaBitisTarihStr = "";
  DateTime today = new DateTime.now();
  DateTime lastDate = new DateTime.now();
  DateTime aramaBaslangicTarihi = new DateTime.now();

  List<dynamic> _list = <dynamic>[];
  List<dynamic> _listHelper = <dynamic>[];
  String name = "";
  int id = 0;
  var db = openDatabase('BSSBobinDB.db');

  _SelectionScreenState(this.name,this.id);

  @override
  void initState() {
    lastDate = today.add(new Duration(days: 1000));
    aramaBaslangicTarihi = today.add(new Duration(days: -1000));
    print(today);
    secilenAramaBaslangicTarihStr = formatDate(today, [yyyy,'-', mm,'-',dd]);
    secilenAramaBitisTarihStr = formatDate(today, [yyyy,'-', mm,'-',dd]);
    prepareList();
    // getSavedSearchState();

    super.initState();
  }
  prepareList() async {
    var dbClient = await db;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var searchState = [
      secilenAramaBaslangicTarihStr.toString(),
      secilenAramaBitisTarihStr,
    ];
    _prefs.setStringList("saved_search_state", searchState);
    switch (name) {
      case "İrsaliye" :
        var queryIrsaliye = "select * from Irsaliyeler where CreatedDate >= '${secilenAramaBaslangicTarihStr} 00:00:00' AND CreatedDate <= '${secilenAramaBitisTarihStr} 23:59:59'";
        print(queryIrsaliye);
        _list = await dbClient.rawQuery(queryIrsaliye);
       setState(() =>_listHelper = _list);
        break;
      case "İrsaliye Kalem":
        var queryIrsaliye = "select * from IrsaliyeDetaylar where IrsaliyeId = $id";
        print(queryIrsaliye);
        _list = await dbClient.rawQuery(queryIrsaliye);
        setState(() =>_listHelper = _list);
        break;
      case "Stok":
        var queryStok = "select * from Stok_Karti";
        _list = await dbClient.rawQuery(queryStok);
        setState(() =>_listHelper = _list);
        print(_listHelper);
        break;
      default:
        break;
    }
  }
  getSavedSearchState() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var variables = _prefs.getStringList("saved_search_state")!;
    print("variables $variables");
    if (variables.isNotEmpty) {
      secilenAramaBaslangicTarihStr = variables[0];
      secilenAramaBitisTarihStr = variables[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            _runFilter(value);
          },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintText: "$name Ara",
              hintStyle: TextStyle(color: Colors.white)),
        ),
      ),
      body: Container(
          padding: EdgeInsets.all(5),
          child:Column(children : [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "${LocaleKeys.startDate_text.tr()}: ",
                            style:
                            TextStyle(color: Colors.black54, fontSize: 18),
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
                  SizedBox(
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
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await prepareList();
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
            Divider(thickness: 1,color: Colors.black54,height: 4,),
            _list.length > 0 ? Text("${_list.length} Adet $name Bulundu",style: TextStyle(fontWeight: FontWeight.w500),) :
                Text("$name Bulunamadı"),
            Divider(thickness: 1,color: Colors.black54,height: 2,),
            Expanded(
              child: ListView.builder(
                  itemCount: _listHelper.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context, _listHelper[index]);

                      },
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 2),
                          child: textGenerator(index),
                        ),
                      ),
                    );
                  }),
            )
          ])),
    );
  }

  Row textGenerator(int index) {
    switch (name) {
      case "İrsaliye":
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 0,
              child:Text("İRSALİYE : ",
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.red),
            ), ),

            Expanded(
              flex: 0,
              child: Text("${_listHelper[index]["IrsaliyeNo"]}  -  ",
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text("${_listHelper[index]["CariAdi"]}",maxLines: 3,
                style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        );
        break;
      case "İrsaliye Kalem":
        return Row(
          children: [
            Expanded(flex: 0,
              child: Text("STOK ADI :  ",
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red),
              ),
            ),
            Expanded(flex:3,child: Text("${_listHelper[index]["StokAdi"]}",
              style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w500),
            )),
            Expanded(flex : 0,child: Text("MİKTAR :  ",
              style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red),
            ))
            ,
            Expanded(child: Text("${_listHelper[index]["Miktar"]}",
              style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w500),
            ))
            ,
          ],
        );
      case "Stok":
        return Row(
          children: [
            const Expanded(flex: 0,
              child: Text("STOK ADI :  ",
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red),
              ),
            ),
            Expanded(flex:3,child: Text("${_listHelper[index]["RefAd"]}",
              style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w500),
            )),
            const Expanded(flex : 0,child: Text("GRAMAJ - EN :  ",
              style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red),
            )),
            Expanded(child: Text("${_listHelper[index]["TeknikDeger"]} - ${_listHelper[index]["En"]}",
              style: const TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w500),
            )),
          ],
        );
        default:
          return Row(
            children: [
              Text("",style: TextStyle(fontSize: 18),
              ),
            ],
          );
    }

  }
  Future<DateTime?> buildShowDatePicker(BuildContext context) {
    return showDatePicker(
        context: context,
        initialDate: today,
        firstDate: aramaBaslangicTarihi,
        lastDate: lastDate);
  }

  
  _runFilter(value) {
    switch(name){
      case "İrsaliye":
        setState(() {
          _listHelper = _list
              .where((elem) => elem["IrsaliyeNo"].toLowerCase().contains(value.toLowerCase()) || elem["CariAdi"].toLowerCase().contains(value.toLowerCase()))
              .toList();
        });
        break;
      case "İrsaliye Kalem":
        setState(() {
          _listHelper = _list
              .where((elem) => elem["StokAdi"].toLowerCase().contains(value.toLowerCase()))
              .toList();
        });
        break;
      case "Stok":
        setState(() {
          _listHelper = _list
              .where((elem) => elem["RefAd"].toLowerCase().contains(value.toLowerCase()))
              .toList();
        });
        break;

    }

  }

}
