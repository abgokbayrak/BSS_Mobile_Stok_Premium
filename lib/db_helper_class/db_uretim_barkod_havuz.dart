import 'package:sqflite/sqflite.dart';

class UretimBarkodHavuzDb {
  static final dbCheck = openDatabase('BSSBobinDB.db');

  static getBarkodDepoHareket(value) async {
    print(value);
    var query = ''' SELECT dh.DepoId,dh.Birim1Miktari as Miktar,dh.Id,StokId,MasrafYeriId as MakinaId,sk.RefAd
                    FROM Stok_Karti_Barkod as skb
                    LEFT JOIN Depo_Hareketleri as dh ON
                        CASE
                            WHEN dh.RefDetayId = 0 THEN dh.Id = skb.RefDetayId
                            WHEN skb.RefDbTableId = 31 OR skb.RefDbTableId = 17  THEN dh.RefDetayId = skb.RefDetayId AND dh.RefDbTableId = skb.RefDbTableId
                        END
                    LEFT JOIN Stok_Karti as sk on dh.StokId = sk.Id	
                    WHERE skb.Barkod = $value;''';
    var result = await (await dbCheck).rawQuery(query);
    return result;
  }
  static getBarkodGirislerMiktar(value) async {
    var query = '''SELECT sum(Depo_Hareketleri.Birim1Miktari) as Miktar FROM Depo_Hareketleri INNER JOIN Stok_Karti_Barkod ON Depo_Hareketleri.BarkodId = Stok_Karti_Barkod.Id 
      WHERE Stok_Karti_Barkod.Id in (select Id from Stok_Karti_Barkod where Barkod = $value and DepoHareketTipiId = 14)''';
    print(query);
    var result = await (await dbCheck).rawQuery(query);
    return result;
  }


}
