
class StokKartiBarkod {
  int? BarkodID;
  int? StokID;
  int? Miktar;
  int? DepoHareketID;
  int? Kopya;
  int? Durum;
  String? Tarih;
  String? GuncellemeTarihi;
	int? IrsaliyeID;
  int? HolID;
  String? BobinNo;
  String? NetUser;
  String? UserName;
  String? Hostname;
  String? BobinChangeTime;
  int? BobinChangeType;
  int? UstBarkodID;
	


  StokKartiBarkod({
    this.BarkodID,
    this.StokID,
    this.Miktar,
    this.DepoHareketID,
    this.Kopya,
    this.Durum,
    this.Tarih,
    this.GuncellemeTarihi,
    this.IrsaliyeID,
    this.HolID,
    this.BobinNo,
    this.NetUser,
    this.UserName,
    this.Hostname,
    this.BobinChangeTime,
    this.BobinChangeType,
    this.UstBarkodID,

    });
  
  Map<String, dynamic> toMap() {
    return {
      'BarkodID': BarkodID,
      'StokID': StokID,
      'Miktar': Miktar,
      'DepoHareketID': DepoHareketID,
      'Kopya': Kopya,
      'Durum': Durum,
      'Tarih': Tarih,
      'GuncellemeTarihi': GuncellemeTarihi,
      'IrsaliyeID': IrsaliyeID,
      'HolID': HolID,
      'BobinNo': BobinNo,
      'NetUser': NetUser,
      'UserName': UserName,
      'Hostname': Hostname,
      'BobinChangeTime': BobinChangeTime,
      'BobinChangeType': BobinChangeType,
      'UstBarkodID':UstBarkodID,
    };
  }
}

