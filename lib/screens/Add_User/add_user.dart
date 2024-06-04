import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import '../../data_model/services/update_function.dart';
import '../../helper/alert.dart';
import '../../helper/ipPortHelper.dart';
import '../../helper/languages/locale_keys.g.dart';




class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  var _username = new TextEditingController();
  var _password = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("${LocaleKeys.adduser_text.tr().toUpperCase()}"),
      ),
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        padding: EdgeInsets.only(left: 30, right: 30, top: 50),
        margin: EdgeInsets.all(5),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 50,
              ),
              TextField(
                maxLines: 1,
                controller: _username,
                enableSuggestions: false,
                autocorrect: false,
                cursorColor: Colors.blue,
                decoration: InputDecoration(
                  hintText: "${LocaleKeys.userName_text.tr()}",
                  border: const OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white54, width: 0.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white54, width: 0.0),
                  ),
                  prefixIcon: Icon(
                    Icons.account_box,
                    size: 30,
                    color: Colors.black,
                  ),
                  filled: true,
                  fillColor: Colors.white.withAlpha(255),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white54, width: 0.0),
                  ),
                  // contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                maxLines: 1,
                controller: _password,
                expands: false,
                cursorColor: Colors.blue,
                enableSuggestions: false,
                autocorrect: false,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "${LocaleKeys.password_text.tr()}",
                  border: const OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white54, width: 0.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white54, width: 0.0),
                  ),
                  prefixIcon: Icon(
                    Icons.vpn_key,
                    size: 30,
                    color: Colors.black,
                  ),
                  filled: true,
                  fillColor: Colors.white.withAlpha(255),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white54, width: 0.0),
                  ),
                  // contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 50,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: FlatButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    // side: BorderSide(color: Colors.red)
                  ),
                  onPressed: () {
                    checkAddUser();
                  },
                  child: Text(
                    "${LocaleKeys.save_text.tr()}",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  checkAddUser() async {
    if (_username.text.isEmpty && _password.text.isEmpty) {
      EasyLoading.showError("${LocaleKeys.usernamePasswordEnter_text.tr()}");
    } else if (_username.text.isEmpty) {
      EasyLoading.showError("${LocaleKeys.usernameEnter_text.tr()}");
    } else if (_password.text.isEmpty) {
      EasyLoading.showError("${LocaleKeys.passwordEnter_text.tr()}");
    } else {
      EasyLoading.instance.userInteractions = false;
      EasyLoading.show();
      await postRequestToServer(_username.text, _password.text);
    }


  }

  Future<dynamic> postRequestToServer(userName, password) async {
    var networkURL = await IpPort.get();
    var url = networkURL +
        "/api/Kullanici/Kaydet?username=$userName&password=$password";
    print(url);
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    ).catchError((onError) {
      print("bağlandı");
      EasyLoading.showToast("Bağlantı Hatası Oluştu");
    }).timeout(Duration(seconds: 60), onTimeout: () => timeoutError());
    //.then((value) => print(value));
    if (response.statusCode == 200) {
      EasyLoading.showToast("${LocaleKeys.saved_text.tr()}");
      EasyLoading.dismiss();
      deleteAllVariables();
      // EasyLoading.show(status: "Kayıt Başarılı");
    } else {
      EasyLoading.showToast(response.body);
      EasyLoading.dismiss();
      print(response.body.toString());
      //throw Exception('Failed to load');
    }
  }
  deleteAllVariables() async {
    setState(() {
      _username.clear();
      _password.clear();

    });
  }
  timeoutError() async {
    EasyLoading.dismiss();
    showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}", "${LocaleKeys.timeoutError_text.tr()}");
  }

}
