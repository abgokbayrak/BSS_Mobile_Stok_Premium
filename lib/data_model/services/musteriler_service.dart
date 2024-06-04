import '../../db_helper_class/repository.dart';
import '../musteriler.dart';
class MusterilerService {
  late Repository _repository;

  MusterilerService() {
    _repository = Repository();
  }

  // Create data
  saveMusteriler(Musteriler musteriler) async {
    return await _repository.insertData('Musteriler', musteriler.toMap());
  }

  // Read data from table
  readMusteriler() async {
    return await _repository.readData('Musteriler');
  }
  readMusterilerLimit(limit) async {
    return await _repository.readLimitData('Musteriler',limit);
  }
  searchMusteriler(searchText) async{
    return await _repository.searchData('Musteriler',searchText);
  }
  

  // Read data from table by Id
  readMusterilerById(holId) async {
    return await _repository.readDataById('Musteriler', holId);
  }

  // Update data from table
  updateMusteriler(Musteriler musteriler) async {
    return await _repository.updateData('Musteriler', musteriler.toMap());
  }

  // Delete data from table
  deleteMusteriler(holId) async{
    return await _repository.deleteData('Musteriler', holId);
  }
}
