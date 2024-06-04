import 'package:flutter/material.dart';
import '../depolar.dart';
import 'depo_services.dart';

var _depo = Depolar();
var _depoService = DepolarService();

List<Depolar> _depoList = <Depolar>[];
var depo;

getAllDepolar() async {
  _depoList = <Depolar>[];
  var categories = await _depoService.readDepolar();
  print(categories);
  categories.forEach((depo) {
    var depoModel = Depolar();
    depoModel.AmbarID = depo['Id'];
    depoModel.AmbarIsmi = depo['DepoAdi'];
    _depoList.add(depoModel);
  });
  return categories;
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
              itemCount: _depoList.length,
              itemBuilder: (context, index) => Container(
                  margin: EdgeInsets.all(5),
                  child: ListTile(
                      title: Center(
                        child: Text(
                          '${_depoList[index].AmbarIsmi}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      onTap: () {
                        // setState(() {
                        //   holTextSelected = true;
                        //   holText = _holList[index].HolAdi;
                        //   holID = _holList[index].HolID;
                        //   Navigator.pop(context);
                        // });
                      })),
            ),
          ),
        );
      });
}
