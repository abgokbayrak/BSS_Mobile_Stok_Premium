import 'dart:convert';

class Sayimlar {
  int? ID;
  int? BarkodID;
  num? Miktar;
  int? StokID;
  String? Tarih;
  int? Modul;
  int? Durum;
  int? DepoID;
  int? EvrakID;
  String? Barkod;
  String? BobinChangeTime;
  int? BobinChangeType;
  int? BobinSyncStatus;
  Sayimlar({this.ID,this.BarkodID,this.Miktar,this.StokID,this.Tarih,this.Modul,this.Durum,this.DepoID,this.EvrakID,this.Barkod,this.BobinChangeTime,this.BobinChangeType,this.BobinSyncStatus});
  
  factory Sayimlar.fromMap(Map<String, dynamic> json) => new Sayimlar(
    ID: json["ID"],
    BarkodID: json["BarkodID"],
    Miktar: json["Miktar"],
    StokID: json["StokID"],
    Tarih: json["Tarih"],
    Modul: json["Modul"],
    Durum: json["Durum"],
    DepoID: json["DepoID"],
    EvrakID: json["EvrakID"],
    Barkod: json["Barkod"].toString(),
    BobinChangeTime: json["BobinChangeTime"],
    BobinChangeType: json["BobinChangeType"],
    BobinSyncStatus: json["BobinSyncStatus"],
  );

  Map<String, dynamic> toMap() {
    return {
      'ID': ID,
      'BarkodID': BarkodID,
      'Miktar': Miktar,
      'StokID': StokID,
      'Tarih': Tarih,
      'Modul': Modul,
      'Durum': Durum,
      'DepoID': DepoID,
      'EvrakID': EvrakID,
      'Barkod': Barkod,
      'BobinChangeTime': BobinChangeTime,
      'BobinChangeType': BobinChangeType,
      'BobinSyncStatus': BobinSyncStatus,
    };
  }
  List<Map<String, dynamic>> donustur(List<Sayimlar> list){

    return list.map((entry) => entry.toMap()).toList().cast();

  }
  List<Sayimlar> sayimFromJson(String str) =>
      List<Sayimlar>.from(json.decode(str).map((x) => Sayimlar.fromMap(x)));
}

//ID,BarkodID,Miktar,StokID,Tarih,Modul,Durum,DepoID,EvrakID,BobinChangeTime,BobinChangeType