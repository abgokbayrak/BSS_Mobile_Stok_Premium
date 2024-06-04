import 'package:sqflite/sqflite.dart';


class SaveBarkodDb{

 static getDepoHareketleriInfo(barcode,dbSave) async {

    var query =
        "SELECT Depo_Hareketleri.MasrafYeriId,StokId,Depo_Hareketleri.DepoId FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod ON Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id WHERE Barkod = ${barcode} limit 1";
    var result = await dbSave.rawQuery(query);
    print(query);
    return result[0];
  }
  static getStokKartiInfo(barcode,dbSave) async {
    var query = '''SELECT Stok_Karti.Id
            FROM Stok_Karti
             inner join Depo_Hareketleri on Stok_Karti.Id = Depo_Hareketleri.StokID
             inner join Stok_Karti_Barkod on Stok_Karti_Barkod.Id = Depo_Hareketleri.BarkodId 
             WHERE Barkod = $barcode;''';
    var result = await dbSave.rawQuery(query);
    return result[0]["Id"];

  }

 static updateAndInsertData(List<UpdateAndInsertDataModel> dataModelList,dbSave) async {
   try {
     await dbSave.transaction((txn) async {
       Batch batch = txn.batch();

       if(dataModelList.first.depoHareketTipId == 14){
       var updateQuery =
           "UPDATE Stok_Karti_Barkod SET BobinSyncStatus=2,ModifiedDate='${DateTime.now().toIso8601String()}',TedarikciBarkodNo = ${dataModelList.first.firmaBobinController!.isEmpty ? 0 : dataModelList.first.firmaBobinController} WHERE Barkod = ${dataModelList.first.barcode}";
       batch.rawQuery(updateQuery);}
       if(dataModelList.first.depoHareketTipId == 18 && dataModelList.first.holId != null){
         var updateQuery =
             "UPDATE Stok_Karti_Barkod SET HolID = ${dataModelList.first.holId} , IsSend = 1 WHERE Barkod = ${dataModelList.first.barcode}";
         batch.rawQuery(updateQuery);}
       dataModelList.forEach((dataModel) {
         var insertQuery =
             "INSERT INTO Depo_Hareketleri (Tarih,DepoHareketYonuId, DepoHareketTipiId,StokId, Birim1Miktari, Birim2Miktari, DepoId,KarsiDepoId,MasrafYeriId, BarkodId, BobinSyncStatus, CreatedDate, IsSend, GonderimKontrol) VALUES ('${dataModel.selectedDate}',${dataModel.depoHareketYonuId}, ${dataModel.depoHareketTipId}, ${dataModel.stokId}, ${dataModel.kgController},${dataModel.kgController}, ${dataModel.depoID},${dataModel.karsiDepoID},${dataModel.makinaId}, (SELECT Id FROM Stok_Karti_Barkod WHERE  Barkod = '${dataModel.barcode}'),  1, '${DateTime.now().toIso8601String()}', 1, 0)";
         print(insertQuery);
         batch.rawQuery(insertQuery);
       });


       await batch.commit();
       print("11");
     });
     return null;
   } catch (error) {
     return error.toString();
   }

 }

}

  class UpdateAndInsertDataModel {
  String barcode;
  String? firmaBobinController;
  String kgController;
  String selectedDate;
  int depoID;
  int? karsiDepoID;
  int? fabrikaId;
  int? holId;
  int stokId;
  int makinaId;
  int depoHareketYonuId;
  int depoHareketTipId;

  UpdateAndInsertDataModel({
    required this.barcode,
    this.firmaBobinController,
    required this.kgController,
    required this.selectedDate,
    required this.depoID,
    this.karsiDepoID,
    this.fabrikaId,
    this.holId,
    required this.stokId,
    required this.makinaId,
    required this.depoHareketTipId,
    required this.depoHareketYonuId,
  });
}