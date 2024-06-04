class Holler {
  int? HolID;
  String? HolAdi;

  Holler({this.HolID, this.HolAdi});
  
  Map<String, dynamic> toMap() {
    return {
      'Id': HolID,
      'KoridoAdi': HolAdi,
    };
  }
}