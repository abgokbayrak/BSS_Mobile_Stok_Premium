class StokKabulModel {
  final int? id;
  final String? barcodeCode;
  final String? kg;
  final String? firmaBobinNo;

  StokKabulModel({this.barcodeCode, this.kg, this.firmaBobinNo, this.id, });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcodeCode': barcodeCode,
      'kg': kg,
      'firmaBobinNo': firmaBobinNo
    };
  }
}