import '../../db_helper_class/repository.dart';
import '../stok_karti_barkod.dart';

class StokKartiBarkodService {
  late Repository _repository;

  StokKartiBarkodService() {
    _repository = Repository();
  }

  // Create data
  saveStokKartiBarkod(StokKartiBarkod stokKartiBarkod) async {
    return await _repository.insertData('Stok_Karti_Barkod', stokKartiBarkod.toMap());
  }

  // Read data from table
  readStokKartiBarkod() async {
    return await _repository.readData('Stok_Karti_Barkod');
  }

  // Read data from table by Id
  readStokKartiBarkodById(depoId) async {
    return await _repository.readDataById('Stok_Karti_Barkod', depoId);
  }

  // Update data from table
  updateStokKartiBarkod(StokKartiBarkod stokKartiBarkod) async {
    return await _repository.updateData('Stok_Karti_Barkod', stokKartiBarkod.toMap());
  }

  // Delete data from table
  deleteStokKartiBarkod(barkodID) async{
    return await _repository.deleteStokKartiBarkodID('Stok_Karti_Barkod', barkodID);
  }

  getUpdates()async{
    return await _repository.getBeforeUpdateDate('Stok_Karti_Barkod');
  }

  getInsertsOnly(lastUpdateDate)async{
    return await _repository.getOnlyInserts('Stok_Karti_Barkod');
  }

}
