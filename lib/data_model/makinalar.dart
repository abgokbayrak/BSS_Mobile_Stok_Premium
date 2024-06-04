class Makinalar {
  int? Id;
  int? DepoId;
  String? MakinaIsmi;

  Makinalar({this.Id, this.MakinaIsmi,this.DepoId});
  
  Map<String, dynamic> toMap() {
    return {
      'Id': Id,
      'DepoId': DepoId,
      'RefAd': MakinaIsmi,
    };
  }
}

