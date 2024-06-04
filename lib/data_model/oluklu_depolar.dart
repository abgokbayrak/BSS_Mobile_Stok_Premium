class OlukluDepolar {
  int? AmbarID;
  int? MakineId;
  String? AmbarIsmi;

  OlukluDepolar({this.AmbarID, this.AmbarIsmi,this.MakineId});
  
  // Convert a Depo into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'AmbarID': AmbarID,
      'MakineId': MakineId,
      'AmbarIsmi': AmbarIsmi,
    };
  }
}

// {AmbarID: 6, AmbarIsmi: OBDEPO}