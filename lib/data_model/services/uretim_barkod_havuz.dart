class UretimBarkodHavuz {
  int id;
  int barkodId;
  int istasyonId;
  int uretimSiparisId;
  int stokUrunMasterId;
  int durum;
  int aktif;
  int isDeleted;
  int createdById;
  DateTime createdDate;
  int modifiedById;
  DateTime modifiedDate;
  int recVersion;
  int dbTableId;
  int barkod;
  int otomasyonDurum;
  int istasyonBolumlerId;
  int ayakNumara;

  UretimBarkodHavuz({
    required this.id,
    required this.barkodId,
    required this.istasyonId,
    required this.uretimSiparisId,
    required this.stokUrunMasterId,
    required this.durum,
    required this.aktif,
    required this.isDeleted,
    required this.createdById,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedDate,
    required this.recVersion,
    required this.dbTableId,
    required this.barkod,
    required this.otomasyonDurum,
    required this.istasyonBolumlerId,
    required this.ayakNumara,
  });

  factory UretimBarkodHavuz.fromJson(Map<String, dynamic> json) => UretimBarkodHavuz(
    id: json['Id'],
    barkodId: json['BarkodId'],
    istasyonId: json['IstasyonId'],
    uretimSiparisId: json['UretimSiparisId'],
    stokUrunMasterId: json['StokUrunMasterId'],
    durum: json['Durum'],
    aktif: json['Aktif'],
    isDeleted: json['IsDeleted'],
    createdById: json['CreatedById'],
    createdDate: DateTime.parse(json['CreatedDate']),
    modifiedById: json['ModifiedById'],
    modifiedDate: DateTime.parse(json['ModifiedDate']),
    recVersion: json['RecVersion'],
    dbTableId: json['DbTableId'],
    barkod: json['Barkod'],
    otomasyonDurum: json['OtomasyonDurum'],
    istasyonBolumlerId: json['IstasyonBolumlerId'],
    ayakNumara: json['AyakNumara'],
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'BarkodId': barkodId,
    'IstasyonId': istasyonId,
    'UretimSiparisId': uretimSiparisId,
    'StokUrunMasterId': stokUrunMasterId,
    'Durum': durum,
    'Aktif': aktif,
    'IsDeleted': isDeleted,
    'CreatedById': createdById,
    'CreatedDate': createdDate.toIso8601String(),
    'ModifiedById': modifiedById,
    'ModifiedDate': modifiedDate.toIso8601String(),
    'RecVersion': recVersion,
    'DbTableId': dbTableId,
    'Barkod': barkod,
    'OtomasyonDurum': otomasyonDurum,
    'IstasyonBolumlerId': istasyonBolumlerId,
    'AyakNumara': ayakNumara,
  };
}
