import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';

class UpdateAppServices{
  static Future<dynamic> updateDepoApp(url) async {
    Response res = await get(Uri.parse(url));
    if (res.statusCode == 200) {
      EasyLoading.show(status: "Uygulama başarıyla güncellendi.");
      return res.statusCode;
    } else {
      EasyLoading.show(status: "Uygulama güncellenirken bir hata oluştu.");
      return res.statusCode;
    }
  }
  static Future<dynamic> updateServer(url) async {
    Response res = await get(Uri.parse(url));
    if (res.statusCode == 200) {
      EasyLoading.show(status: "Uygulama başarıyla güncellendi.");
      return [res.statusCode, jsonDecode(res.body)];
    } else {
      EasyLoading.show(status: "Uygulama güncellenirken bir hata oluştu.");
      return [res.statusCode, jsonDecode(res.body)];
    }
  }}
