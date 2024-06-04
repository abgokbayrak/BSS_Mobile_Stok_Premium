class Musteriler {
  int? HesapID;
  int? MusteriID;
  String? MusteriAdi;

  Musteriler({this.HesapID, this.MusteriAdi,this.MusteriID});
  
  Map<String, dynamic> toMap() {
    return {
      'HesapID': HesapID,
      'MusteriAdi': MusteriAdi,
      'MusteriID':MusteriID,
    };
  }
}

