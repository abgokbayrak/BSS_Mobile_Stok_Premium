import '../../db_helper_class/repository.dart';
import '../holler.dart';


class HollerService {
  late Repository _repository;

  HollerService() {
    _repository = Repository();
  }

  // Create data
  saveHoller(Holler holler) async {
    return await _repository.insertData('Holler', holler.toMap());
  }

  // Read data from table
  readHoller() async {
    return await _repository.readData('Holler');
  }

  // Read data from table by Id
  readHollerById(holId) async {
    return await _repository.readDataById('Holler', holId);
  }

  // Update data from table
  updateHoller(Holler holler) async {
    return await _repository.updateData('Holler', holler.toMap());
  }

  // Delete data from table
  deleteHoller(holId) async{
    return await _repository.deleteData('Holler', holId);
  }
  ffffFunc()async{
    return await _repository.func();
  }
}
