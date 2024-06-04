import '../../db_helper_class/repository.dart';
import '../depolar.dart';

class DepolarService {
  late Repository _repository;

  DepolarService() {
    _repository = Repository();
  }

  // Create data
  saveDepolar(Depolar depolar) async {
    return await _repository.insertData('Depolar', depolar.toMap());
  }

  // Read data from table
  // readDepolar() async {
  //   return await _repository.readData('Depolar');
  // }
  readDepolar() async {
    var query = "select d.Id,FabrikaAdi || '-' || d.DepoAdi AS DepoAdi,FabrikaId from Depolar as d inner join Fabrikalar on d.FabrikaId == Fabrikalar.Id";
    // var query = "select Id,DepoAdi AS DepoAdi,DepoTipId,FabrikaId from Depolar ";
   print(query);
    return await _repository.readDataDepo(query);
  }
  // Read data from table by Id
  readDepolarById(depoId) async {
    return await _repository.readDataById('Depolar', depoId);
  }

  // Update data from table
  updateDepolar(Depolar depolar) async {
    return await _repository.updateData('Depolar', depolar.toMap());
  }

  // Delete data from table
  deleteDepolar(depoId) async{
    return await _repository.deleteData('Depolar', depoId);
  }
}
