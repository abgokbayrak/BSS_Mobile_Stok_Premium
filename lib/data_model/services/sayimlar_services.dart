import 'dart:convert';
import 'package:http/http.dart';

import '../../db_helper_class/repository.dart';
import '../sayimlar.dart';

class SayimlarService {
  late Repository _repository;

  SayimlarService() {
    _repository = Repository();
  }

  // Create data
  saveSayimlar(Sayimlar sayimlar) async {
    return await _repository.insertData('Sayimlar', sayimlar.toMap());
  }

  // Read data from table
  readSayimlar() async {
    return await _repository.readData('Sayimlar');
  }

  // Read data from table by Id
  readSayimlarById(depoId) async {
    return await _repository.readSayimlarByDepoId('Sayimlar', depoId);
  }

  // Update data from table
  updateSayimlar(Sayimlar sayimlar) async {
    return await _repository.updateData('Sayimlar', sayimlar.toMap());
  }

  // Delete data from table
  deleteSayimlar(sayimId) async{
    return await _repository.deleteSayimID('Sayimlar', sayimId);
  }
  getUpdates(lastUpdateDate)async{
    return await _repository.getBeforeUpdateDate('Sayimlar');
  }

  getInsertsOnly(lastUpdateDate)async{
    return await _repository.getOnlyInserts('Sayimlar' );
  }

  static Future<dynamic> getData(url) async {
    Response res = await get(Uri.parse(url));
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return body;
    } else {
      throw "Unable to retrieve posts.";
    }
  }
}
