import 'package:sqflite/sqflite.dart';

class CheckBarkodGirisDb {
  static final dbCheck = openDatabase('BSSBobinDB.db');

  static getBarkodDepoHareket(value) async {
    var query = ''' SELECT dh.DepoId,dh.Birim1Miktari as Miktar,dh.Id,StokId,MasrafYeriId as MakinaId,sk.RefAd
                    FROM Stok_Karti_Barkod as skb
                    LEFT JOIN Depo_Hareketleri as dh ON
                        CASE
                            WHEN dh.RefDetayId = 0 AND (skb.RefDbTableId != 31 AND skb.RefDbTableId != 17) THEN dh.Id = skb.RefDetayId
                            WHEN skb.RefDbTableId = 31 OR skb.RefDbTableId = 17  THEN dh.RefDetayId = skb.RefDetayId AND dh.RefDbTableId = skb.RefDbTableId
                        END
                    LEFT JOIN Stok_Karti as sk on dh.StokId = sk.Id	
                    WHERE skb.Barkod = $value;''';
    var result = await (await dbCheck).rawQuery(query);
    return result;
  }
  static getBarkodGirislerMiktar(value) async {
    var query = '''select  SUM(Depo_Hareketleri.Birim1Miktari) as Miktar
         from Stok_Karti_Barkod
         Inner Join Depo_Hareketleri on Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id
         Where DepoHareketTipiId = 14 And Stok_Karti_Barkod.RefDetayId = (select RefDetayId from Stok_Karti_Barkod where Barkod = $value)''';
    var result = await (await dbCheck).rawQuery(query);
    return result;
  }
}
