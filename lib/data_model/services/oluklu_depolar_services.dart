import '../../db_helper_class/repository.dart';
import '../oluklu_depolar.dart';


class OlukluDepolarService {
  late Repository _repository;

  OlukluDepolarService() {
    _repository = Repository();
  }

  // Create data
  saveOlukluDepolar(OlukluDepolar olukluDepolar) async {
    return await _repository.insertData('OlukluDepolar', olukluDepolar.toMap());
  }

  // Read data from table
  readOlukluDepolar() async {
    return await _repository.readData('OlukluDepolar');
  }

  // Read data from table by Id
  readOlukluDepolarById(olukluDepoId) async {
    return await _repository.readDataById('OlukluDepolar', olukluDepoId);
  }

  // Update data from table
  updateOlukluDepolar(OlukluDepolar olukluDepolar) async {
    return await _repository.updateData('OlukluDepolar', olukluDepolar.toMap());
  }

  // Delete data from table
  deleteOlukluDepolar(olukluDepoId) async{
    return await _repository.deleteData('OlukluDepolar', olukluDepoId);
  }
}
