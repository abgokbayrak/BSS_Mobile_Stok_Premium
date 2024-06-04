import '../../db_helper_class/repository.dart';
import '../makinalar.dart';

class MakinalarService {
  late Repository _repository;

  MakinalarService() {
    _repository = Repository();
  }

  // Create data
  saveMakinalar(Makinalar makinalar) async {
    return await _repository.insertData('Makinalar', makinalar.toMap());
  }

  // Read data from table
  readMakinalar() async {
    return await _repository.readData('Makinalar');
  }

  // Read data from table by Id
  readMakinalarById(holId) async {
    return await _repository.readDataById('Makinalar', holId);
  }

  // Update data from table
  updateMakinalar(Makinalar makinalar) async {
    return await _repository.updateData('Makinalar', makinalar.toMap());
  }

  // Delete data from table
  deleteMakinalar(holId) async{
    return await _repository.deleteData('Makinalar', holId);
  }
}
