import '../../db_helper_class/repository.dart';
import '../depo_hareketleri.dart';

class DepoHareketleriService {
  late Repository _repository;

  DepoHareketleriService() {
    _repository = Repository();
  }

  // Create data
  // saveDepoHareketleri(Depo_Hareketleri depoHareketleri) async {
  //   return await _repository.insertData('Depo_Hareketleri', depoHareketleri.toMap());
  // }

  // Read data from table
  readDepoHareketleri() async {
    return await _repository.readData('Depo_Hareketleri');
  }

  // Read data from table by Id
  readDepoHareketleriById(depoId) async {
    return await _repository.readDataById('Depo_Hareketleri', depoId);
  }

  // // Update data from table
  // updateDepoHareketleri(Depo_Hareketleri depoHareketleri) async {
  //   return await _repository.updateData('Depo_Hareketleri', depoHareketleri.toMap());
  // }

  // Delete data from table
  deleteDepoHareketleri(hareketID) async{
    return await _repository.deleteDepoHareketID('Depo_Hareketleri', hareketID);
  }
  
  getUpdates(lastUpdateDate)async{
    return await _repository.getBeforeUpdateDate('Depo_Hareketleri');
  }
  getInsertsOnly(lastUpdateDate)async{
    return await _repository.getOnlyInserts('Depo_Hareketleri');
  }

  getCountInfo(depoHareketId) async{
    return await _repository.getCount('Depo_Hareketleri', depoHareketId);
  }


}
