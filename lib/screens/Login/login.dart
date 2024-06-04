import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:bss_mobile_premium/helper/ipPortHelper.dart';
import 'package:bss_mobile_premium/screens/Home/home.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../helper/languages/locale_keys.g.dart';
import '../../services/first_load_service.dart';
import '../../theme/manager/theme_manager.dart';
import '../Add_User/add_user.dart';
import '../settings/settings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static var db = openDatabase('BSSBobinDB.db');
  static var logDb = openDatabase('BSSBobinDBLog.db');
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _settingsTextFieldController = new TextEditingController();
  final _addUserTextFieldController = new TextEditingController();

  bool firstOpened = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/images/MobuyLogo.png',
                  alignment: Alignment.center,
                  color: Colors.white,
                ),
                 Text("PREMİUM",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic)),
              ],
            ),
            SizedBox(height: screenHeight*0.1,),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  controller: _usernameTextController,
                  style: Theme.of(context).textTheme.bodyText1,
                  enableSuggestions: false,
                  autocorrect: false,
                  cursorColor: Colors.blue,
                  decoration: InputDecoration(
                    hintText: "KULLANICI ADI",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    prefixIcon: const Icon(
                      Icons.account_box,
                    ),
                    filled: true,
                    fillColor: Colors.white.withAlpha(255),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white54, width: 0.0),
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                TextField(
                  controller: _passwordTextController,
                  style: Theme.of(context).textTheme.bodyText1,
                  expands: false,
                  enableSuggestions: false,
                  autocorrect: false,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "ŞİFRE",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    prefixIcon: const Icon(
                      Icons.vpn_key,
                    ),
                    filled: true,
                    fillColor: Colors.white.withAlpha(255),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white54, width: 0.0),
                    ),
                    // contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight*0.05,),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  minWidth: screenWidth,
                  height: screenHeight * 0.06,
                  color: Colors.white,
                  onPressed: () {
                    loginButtonClicked();
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: const Text(
                    "GİRİŞ",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10,),
                FlatButton(
                  minWidth: screenWidth,
                  height: screenHeight * 0.06,
                  color: Colors.white,
                  onPressed: () {
                    askPasswordBeforeSettings();
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: const Text(
                    "AYARLAR",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // TextButton(
                //   onPressed: () {
                //     askPasswordBeforeAddUser();
                //   },
                //   child: const Text(
                //     "KULLANICI EKLE",
                //     style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 15,
                //         fontWeight: FontWeight.bold),
                //   ),
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }

  loginButtonClicked() async {
    try {
      if (_usernameTextController.text.isEmpty == true ||
          _passwordTextController.text.isEmpty == true) {
        EasyLoading.showError("Kullanıcı adı ve şifre giriniz");
      } else {
        var dbClient = await db;
        var query =
            "SELECT COUNT(*) AS Result FROM Kullanicilar where KullaniciAdi='${_usernameTextController.text}' and Sifre='${_passwordTextController.text}'";
        var result = await dbClient.rawQuery(query);
        if (result[0]["Result"] == 1) {
          if (firstOpened == true) {
            globals.userName = _usernameTextController.text;
            EasyLoading.show(status: "Giriş Yapılıyor");
            navigateHome();
          } else {
            globals.userName = _usernameTextController.text;
            EasyLoading.show(status: "${LocaleKeys.loggingin_text.tr()}");
            navigateHome();
          }
        } else {
          Alert(
            context: context,
            title: "${LocaleKeys.error_text.tr().toUpperCase()}",
            desc: "${LocaleKeys.usernamePasswordControl_text.tr()}",
          ).show();
        }
      }
    } catch (ex) {
      EasyLoading.showError(
          "El Terminali veri tabanında sorun olabilir.Fabrika ayarı işlemini tekrar yapınız");
    }
  }

  navigateHome() async {
    EasyLoading.dismiss();
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString("userName", _usernameTextController.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MenuButtons()),
    );
  }

  askPasswordBeforeSettings() async {
    Alert(
        context: context,
        title: LocaleKeys.passwordSetting_text.tr().toUpperCase(),
        content: Column(
          children: <Widget>[
            TextField(
              controller: _settingsTextFieldController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: LocaleKeys.password_text.tr(),
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (_settingsTextFieldController.text == "2425") {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              } else {
                Alert(
                  context: context,
                  title: "${LocaleKeys.passwordMistake_text.tr()}",
                  desc: "${LocaleKeys.passwordFalse_text.tr()}",
                ).show();
              }
            },
            child: Text(
              "${LocaleKeys.save_text.tr().toUpperCase()}",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  askPasswordBeforeAddUser() async {
    Alert(
        context: context,
        title: LocaleKeys.adduser_text.tr().toUpperCase(),
        content: Column(
          children: <Widget>[
            TextField(
              controller: _addUserTextFieldController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: LocaleKeys.password_text.tr(),
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (_settingsTextFieldController.text == "2425") {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddUser()),
                );
              } else {
                Alert(
                  context: context,
                  title: "${LocaleKeys.passwordMistake_text.tr()}",
                  desc: "${LocaleKeys.passwordFalse_text.tr()}",
                ).show();
              }
            },
            child: Text(
              "${LocaleKeys.save_text.tr().toUpperCase()}",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  makeFirstLoad() async {
    try {
      var portAndIP = (await IpPort.get());
      if (portAndIP != null) {
        await FirstLoad.startLoad(null);
      } else {
        loginAlerts(context, "${LocaleKeys.error_text.tr().toUpperCase()}",
            "${LocaleKeys.fillIpPort_text.tr().toUpperCase()}");
      }
    } catch (ex) {
      loginAlerts(context, "${LocaleKeys.error_text.tr().toUpperCase()}",
          "Yükleme işlemi yapılırken hata oluştu. Verileriniz eksik olabilir fabrika ayarı yapınız!! $ex");
      return false;
    }
  }

  void loginAlerts(context, title, desc) {
    Alert(
      context: context,
      title: title,
      desc: desc,
    ).show();
  }
}
