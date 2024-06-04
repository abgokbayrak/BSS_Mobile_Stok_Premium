class Depolar {
  int? AmbarID;
  String? AmbarIsmi;

  Depolar({this.AmbarID, this.AmbarIsmi});
  
  factory Depolar.fromMap(Map<String, dynamic> json) => new Depolar(
    AmbarID: json["AmbarID"],
    AmbarIsmi: json["AmbarIsmi"],
  );

  Map<String, dynamic> toMap() {
    return {
      'AmbarID': AmbarID,
      'AmbarIsmi': AmbarIsmi,
    };
  }
}

// {AmbarID: 6, AmbarIsmi: OBDEPO}