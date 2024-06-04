class SatisSearchModel {
  int? sevkID;
  String? tarih;
  String? sevkNo;
  int? miktar;
  int? musteriID;
  String? musteri;
  int? sipRef;

  SatisSearchModel(
      {this.sevkID, this.tarih, this.sevkNo, this.miktar, this.musteri,this.musteriID, this.sipRef});

  SatisSearchModel.fromJson(Map<String, dynamic> json) {
    sevkID = json['SevkID'];
    tarih = json['Tarih'];
    sevkNo = json['SevkNo'];
    miktar = json['Miktar'];
    musteri = json['Musteri'];
    musteriID = json['MusteriID'];
    sipRef = json['SipRef'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SevkID'] = this.sevkID;
    data['Tarih'] = this.tarih;
    data['SevkNo'] = this.sevkNo;
    data['Miktar'] = this.miktar;
    data['Musteri'] = this.musteri;
    data['MusteriID'] = this.musteriID;
    data['sipRef'] = this.sipRef;
    return data;
  }
}