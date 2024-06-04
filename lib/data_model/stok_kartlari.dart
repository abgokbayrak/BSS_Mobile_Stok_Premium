class Stok_Karti {
  final int? StokID;
  final String? StokIsmi;
  final int? Gramaj;
  final int? En;
  final int? KalipID;
  final int? KliseID;
  final int? StokCinsID;


  Stok_Karti({this.StokID, this.StokIsmi, this.Gramaj, this.En, this.KalipID, this.KliseID, this.StokCinsID});
  
  // Convert a Depo into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'StokID': StokID,
      'StokIsmi': StokIsmi,
      'Gramaj': Gramaj,
      'En': En,
      'KalipID': KalipID,
      'KliseID': KliseID,
      'StokCinsID': StokCinsID,
    };
  }
}

// {AmbarID: 6, AmbarIsmi: OBDEPO}