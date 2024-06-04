import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:bss_mobile_premium/services/first_load_service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import '../../helper/alert.dart';
import '../../helper/checkbox_list_tile.dart';
import '../../helper/languages/languages_model.dart';
import '../../helper/languages/locale_keys.g.dart';
import '../../services/update_app.dart';
import '../../theme/manager/theme_manager.dart';
import '../Login/login.dart';
import 'log.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //region VARIABLES
  var db = openDatabase('BSSBobinDB.db');
  var _ipTextFieldController = new TextEditingController();
  var _portTextFieldController = new TextEditingController();
  late LanguageModel language;
  late List<Map<String, dynamic>> updateInfo = <Map<String, dynamic>>[];
  late List<Map<String, dynamic>> factories = <Map<String, dynamic>>[];
  String? secilenLog = "Hata";
  String? log;
  String? dropdownValue = '${LocaleKeys.onlyUpdateButton_text.tr()}';
  String sayimRadio = "Tümü";
  bool firstUpdate = true;
  List<CheckBoxListTileModel> checkBoxListTileModel =
      CheckBoxListTileModel.getUsers();
  List<String> dropDownList = <String>[
    '${LocaleKeys.onlyUpdateButton_text.tr()}',
    '${LocaleKeys.everyProcessEnd_text.tr()}',
    '${LocaleKeys.onlyHomepage_text.tr()}'
  ];

  //endregion
  _SettingsPageState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPasswordAndIP();
    print(globals.factoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildIpPort(),
                      buildUpdateFreq(context),
                      buildDivider(),
                      buildChooseSayim(context),
                      buildDivider(),
                      mainMenu(context),
                      followUpdate(context),
                    ],
                  ),
                ),
              ),
              pageButtonsa(),
            ],
          ),
        ));
  }

  //region INIT_METHODS
  initPasswordAndIP() async {
    var ipPort = await getSavedPortAndIPSeperately();
    sayimRadio = ipPort[2] ?? "Tümü";
    if (ipPort[0] != null && ipPort[1] != null) {
      _ipTextFieldController.text = ipPort[0];
      _portTextFieldController.text = ipPort[1].toString();
    } else {
      setState(() {
        _ipTextFieldController.text = "http://";
        _portTextFieldController.text = "";
      });
    }
    if (globals.updatePeriod == 0) {
      setState(() {
        dropdownValue = '${LocaleKeys.onlyUpdateButton_text.tr()}';
      });
    } else if (globals.updatePeriod == 1) {
      setState(() {
        dropdownValue = '${LocaleKeys.everyProcessEnd_text.tr()}';
      });
    } else if (globals.updatePeriod == 2) {
      setState(() {
        dropdownValue = '${LocaleKeys.onlyHomepage_text.tr()}';
      });
    }
    await getUpdateInfo();
    await getFactories();
  }

  getSavedPortAndIPSeperately() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var ip = _prefs.getString("ip");
    var port = _prefs.getInt("port");
    var sayimRadio = _prefs.getString("sayimHol");
    return [ip, port, sayimRadio];
  }

  //endregion
  //region PAGE WİDGET
  Row pageButtonsa() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              askToDelete();
            },
            icon: Icon(Icons.restore, color: Colors.white),
            label: Text(
              "${LocaleKeys.factorySettings_text.tr()}",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              overlayColor: MaterialStateProperty.all(Colors.red),
            ),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              checkApiConnection();
            },
            icon: Icon(Icons.network_check, color: Colors.white),
            label: Text(
              "${LocaleKeys.connection_text.tr()}",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
              overlayColor: MaterialStateProperty.all(Colors.red),
            ),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              savePortAndIP();
            },
            icon: Icon(Icons.save, color: Colors.white),
            label: Text(
              "Kaydet",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
              overlayColor: MaterialStateProperty.all(Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget mainMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpandableNotifier(
        child: Card(
          color: Colors.white24,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: false,
                  ),
                  header: Padding(
                      padding: EdgeInsets.all(0),
                      child: Text(
                        "ANA MENÜ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  collapsed: SizedBox(),
                  expanded: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (var _ in Iterable.generate(1))
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: GridView.count(
                              crossAxisCount: 2,
                              physics: NeverScrollableScrollPhysics(),
                              childAspectRatio: 3,
                              children: List.generate(
                                  checkBoxListTileModel.length, (index) {
                                return new Card(
                                  child: Container(
                                    padding: new EdgeInsets.all(0),
                                    child: SizedBox(
                                        height: 40,
                                        child: new CheckboxListTile(
                                            activeColor: Colors.blue[300],
                                            dense: true,
                                            title: new Text(
                                              checkBoxListTileModel[index]
                                                  .title!,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            value: checkBoxListTileModel[index]
                                                .isCheck,
                                            onChanged: (bool? val) {
                                              itemChange(val, index);
                                            })),
                                  ),
                                );
                              }),
                            )),
                    ],
                  ),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 0),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget followUpdate(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: ExpandableNotifier(
        child: Card(
          color: Colors.white24,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: false,
                  ),
                  header: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Padding(
                          padding: EdgeInsets.all(0),
                          child: Text(
                            "GÜNCELLEME TAKİBİ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                      SizedBox(
                        width: 20,
                      ),
                      Padding(
                          padding: EdgeInsets.only(right: 0.0),
                          child: SizedBox(
                            height: 35,
                            child: FloatingActionButton(
                              backgroundColor: Colors.blueGrey,
                              onPressed: () {
                                showAlertWithYesNoButton(
                                    context,
                                    "Uygulamayı Güncellemek İstediğinize Emin misiniz?",
                                    "");
                              },
                              child: const Center(
                                  child: Icon(
                                Icons.download,
                                size: 25,
                              )),
                            ),
                          ))
                    ],
                  ),
                  collapsed: SizedBox(),
                  expanded: ListView.builder(
                      shrinkWrap: true,
                      itemCount: updateInfo.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${updateInfo[index]["IstekAdi"].replaceAll('T', 'é')}  :  ",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    "${updateInfo[index]["IstekTarihi"].toString().replaceAll("T", " ")}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      }),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 3, right: 3, bottom: 3),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildChooseSayim(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Sayım :", style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 35,
          child: RadioGroup<String?>.builder(
            direction: Axis.horizontal,
            groupValue: sayimRadio,
            onChanged: (value) => setState(() {
              sayimRadio = value!;
            }),
            items: ["Tümü", "Hol Bazlı"],
            itemBuilder: (item) => RadioButtonBuilder(
              item!,
            ),
          ),
        ),
      ],
    );
  }

  Padding buildUpdateFreq(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Column(
        children: [
          Text(
            "${LocaleKeys.updateFrequency_text.tr()}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            height: 30,
            width: MediaQuery.of(context).size.width,
            child: DropdownButton<String>(
              value: dropdownValue,
              iconSize: 20,
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue;
                  print("dropdownValue $dropdownValue");
                });
              },
              items: dropDownList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Column buildIpPort() {
    return Column(
      children: [
        TextField(
          controller: _ipTextFieldController,
          decoration: const InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
            icon: Icon(Icons.settings_input_antenna_rounded),
            labelText: 'IP',
            isDense: true,
            // Added this
            contentPadding: EdgeInsets.all(3), // Added this
          ),
        ),
        SizedBox(
          height: 5,
        ),
        TextField(
          controller: _portTextFieldController,
          decoration: const InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
            icon: Icon(Icons.lock),
            labelText: 'Port',
            isDense: true,
            // Added this
            contentPadding: EdgeInsets.all(3),
          ),
        ),
      ],
    );
  }

  Divider buildDivider() {
    return Divider(
      height: 0,
      thickness: 1,
      color: Colors.black,
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        LocaleKeys.settings_text.tr(),
        style: TextStyle(fontSize: 20),
      ),
      actions: <Widget>[
        // languageSelect(),
        viewLog(),
        viewFactories(),
        themeChange(),
      ],
    );
  }

  IconButton themeChange() {
    return IconButton(
      onPressed: () async => await Future.delayed(
        const Duration(milliseconds: 200),
        () => ThemeManager.instance.changeTheme(
            ThemeManager.instance.currentThemeEnum == ThemeEnum.LIGHT
                ? ThemeEnum.DARK
                : ThemeEnum.LIGHT),
      ),
      icon: Icon(
        ThemeManager.instance.currentThemeEnum == ThemeEnum.LIGHT
            ? Icons.wb_sunny
            : Icons.lightbulb_outline,
        color: Colors.white,
      ),
    );
  }

  //endregion
  //region ALERT
  showAlertWithYesNoButton(context, title, message) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: title,
      desc: message,
      content: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            decoration: myBoxDecoration(),
            //             <--- BoxDecoration here
            child: Column(
              children: [
                Text("Uygulama Güncelle"),
                Row(
                  children: [
                    Expanded(
                      child: DialogButton(
                        child: Text(
                          LocaleKeys.yes_text.tr(),
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        onPressed: () => {
                          updateApk(),
                          // Navigator.pop(context),
                        },
                        color: Color.fromRGBO(0, 179, 134, 1.0),
                      ),
                    ),
                    Expanded(
                        child: DialogButton(
                      child: Text(
                        LocaleKeys.no_text.tr(),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.red,
                    )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            decoration: myBoxDecoration(),
            child: Column(
              children: [
                Text("Server Güncelle"),
                Row(
                  children: [
                    Expanded(
                      child: DialogButton(
                        child: Text(
                          LocaleKeys.yes_text.tr(),
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        onPressed: () => {
                          updateServer(), // Navigator.pop(context),
                        },
                        color: Color.fromRGBO(0, 179, 134, 1.0),
                      ),
                    ),
                    Expanded(
                        child: DialogButton(
                      child: Text(
                        LocaleKeys.no_text.tr(),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.red,
                    ))
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            decoration: myBoxDecoration(),
            //             <--- BoxDecoration here
            child: Column(
              children: [
                Text("Tümünü Güncelle"),
                Row(
                  children: [
                    Expanded(
                      child: DialogButton(
                        child: Text(
                          LocaleKeys.yes_text.tr(),
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        onPressed: () async => {
                          await updateServer(), // Navigator.pop(context),
                          await updateApk(), // Navigator.pop(context),
                        },
                        color: Color.fromRGBO(0, 179, 134, 1.0),
                      ),
                    ),
                    Expanded(
                        child: DialogButton(
                      child: Text(
                        LocaleKeys.no_text.tr(),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.red,
                    ))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      buttons: [],
    ).show();
  }

  askToDelete() async {
    Alert(
      context: context,
      type: AlertType.error,
      title: "${LocaleKeys.factorySettings_text.tr()}",
      desc: "${LocaleKeys.deleteAllData_text.tr()}",
      buttons: [
        DialogButton(
          child: Text(
            "${LocaleKeys.delete_text.tr()}",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async =>
              {Navigator.pop(context), await deleteEverything()},
          color: Colors.red,
        ),
        DialogButton(
          child: Text(
            "${LocaleKeys.no_text.tr()}",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
      ],
    ).show();
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }

  //endregion
  //region UPDATEAPP
  updateServer() async {
    EasyLoading.show(status: "Server Güncelleniyor");
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var programRadio = _prefs.getString("programRadio");
    var ip = _ipTextFieldController.text;
    if (ip.length < 8) {
      EasyLoading.showInfo("Ip Giriniz.");
      return;
    } else if (programRadio == null) {
      EasyLoading.showInfo("Program Seçiniz.");
      return;
    }
    var projectType = programRadio == "Win Project" ? 0 : 1;
    var url =
        "$ip:5150/BobinGuncelle?firstLoad=$firstUpdate&projectType=$projectType";
    print(url);
    try {
      UpdateAppServices.updateServer(url).then((value) async => {
            print("val $value"),
            if (value[0] == 200)
              {
                if (value[1]["isSuccess"] == true)
                  {
                    EasyLoading.showSuccess(value[1]["message"]),
                  }
                else
                  {
                    EasyLoading.showError("Hata : ${value[1]["message"]}"),
                  }
              }
            else
              {
                EasyLoading.showError("Server Güncellenmedi"),
              }
          });
    } catch (e) {
      EasyLoading.showError("Uygulama Güncellenmedi");
    }
  }

  updateApi() async {
    EasyLoading.show(status: "Güncelleniyor");
    var ip = _ipTextFieldController.text;
    if (ip.length < 8) {
      EasyLoading.showInfo("Ip Giriniz.");
      return;
    }
    var url = "$ip:5150/ApiGuncelle?type=bobin";
    print(url);
    try {
      UpdateAppServices.updateDepoApp(url).then((value) async => {
            if (value == 200)
              {
                EasyLoading.showSuccess("Api Güncellendi"),
              }
            else
              {
                EasyLoading.showError("Api Güncellenmedi"),
              }
          });
    } catch (e) {
      EasyLoading.showError("Api Güncellenmedi");
    }
  }

  updateApk() async {
    try {
      EasyLoading.show(status: "Yükleniyor...");
      String url = "http://www.mobuy.com.tr/bobinpremium.apk";
      var dir = await getApplicationDocumentsDirectory();
      String fileName = 'bobinpremium.apk';
      Dio dio = Dio();
      await dio.download(url, "${dir.path}/$fileName");
      await OpenFile.open("${dir.path}/$fileName");
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError("Uygulama Yüklenemedi ${e.toString()}");
    }
  }

  //endregion
  //region LOG
  final items = ['Hareketler', 'Gonderilen Hareketler', 'Hatalar'];
  var data = [
    {'id': 1, 'name': "Hareketler"},
    {'id': 2, 'name': "Gonderilen Hareketler"},
    {'id': 3, 'name': "Hatalar"}
  ];

  Padding viewLog() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        children: [
          Center(
            child: DropdownButton(
              underline: SizedBox(),
              icon: Icon(
                Icons.file_copy_outlined,
                color: Colors.white,
              ),
              items: data
                  .map<DropdownMenuItem<dynamic>>((lang) => DropdownMenuItem(
                        value: lang,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              lang["name"].toString(),
                              style: TextStyle(fontSize: 13),
                            )),
                      ))
                  .toList(),
              onChanged: (dynamic lang) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LogScreen(lang["id"])));
              },
            ),
          ),
        ],
      ),
    );
  }

  //endregion
  //region APPBAR-WİDGETS
  Padding viewFactories() {
    return Padding(
      padding: EdgeInsets.fromLTRB(7, 0, 0, 2),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.factory,
            ),
            iconSize: 25,
            splashColor: Colors.purple,
            onPressed: () async {
              displayBottomSheetFactory(context);
            },
          ),
        ],
      ),
    );
  }

  displayBottomSheetFactory(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                ),
                itemCount: factories.length,
                itemBuilder: (context, index) => Container(
                    color: factories[index]["Id"] == globals.factoryId
                        ? Colors.green
                        : Colors.white,
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                        title: Center(
                          child: Text('${factories[index]["FabrikaAdi"]}'),
                        ),
                        onTap: () {
                          setState(() {
                            globals.factoryId =
                                int.parse(factories[index]["Id"].toString());
                            print(globals.factoryId);

                            Navigator.pop(context);
                          });
                        })),
              ),
            ),
          );
        });
  }

  //endregion
  //region SAVESETTİNGS
  savePortAndIP() async {
    if (_ipTextFieldController.text.isEmpty ||
        _portTextFieldController.text.isEmpty) {
      showAlertWithOKButton(context, "${LocaleKeys.error_text.tr()}",
          "${LocaleKeys.fillIpPort_text.tr()}");
    }
    else if (globals.factoryId == 0){
      EasyLoading.showInfo("Fabrika Seçiniz");
    }
    else {
      var portIP = _ipTextFieldController.text.toString() +
          ":" +
          _portTextFieldController.text.toString();
      await savePortAndIPToSharedPref(portIP);
      await saveSettings();
      if (globals.openModulesCount == 0) {
        EasyLoading.showInfo("Menü Seçiniz");
        return;
      }
      EasyLoading.showToast("${LocaleKeys.saved_text.tr()}",
          duration: Duration(milliseconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isStokKabulOpen", globals.isStokKabulOpen!);
    await prefs.setBool("isImalattanIadeOpen", globals.isImalattanIadeOpen!);
    await prefs.setBool("isImalattanCikisOpen", globals.isImalattanCikisOpen!);
    await prefs.setBool("isBobinKesimlOpen", globals.isBobinKesimlOpen!);
    await prefs.setBool("isBobinBitirOpen", globals.isBobinBitirOpen!);
    await prefs.setBool(
        "isTedarikciyeIadeOpen", globals.isTedarikciyeIadeOpen!);
    await prefs.setBool("isBobinHolOpen", globals.isBobinHolOpen!);
    await prefs.setBool("isSayimOpen", globals.isSayimOpen!);
    await prefs.setBool("isBobinSatisOpen", globals.isBobinSatisOpen!);
    await prefs.setBool("isIrsaliyeKabulOpen", globals.isIrsaliyeKabulOpen!);
    await prefs.setBool("isTransferOpen", globals.isTransferOpen!);
    await prefs.setInt("openModulesCount", globals.openModulesCount);
    await prefs.setInt("factoryId", globals.factoryId);
    if (dropdownValue == '${LocaleKeys.onlyUpdateButton_text.tr()}') {
      print("dropdownValue $dropdownValue");
      await prefs.setInt("updatePeriod", 0);
      globals.updatePeriod = 0;
    } else if (dropdownValue == '${LocaleKeys.everyProcessEnd_text.tr()}') {
      print("dropdownValue $dropdownValue");
      await prefs.setInt("updatePeriod", 1);
      globals.updatePeriod = 1;
    } else if (dropdownValue == '${LocaleKeys.onlyHomepage_text.tr()}') {
      print("dropdownValue $dropdownValue");
      await prefs.setInt("updatePeriod", 2);
      globals.updatePeriod = 2;
    }
    globals.openModulesCount = 0;
    if (globals.isStokKabulOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isBobinBitirOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isBobinHolOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isImalattanIadeOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isImalattanCikisOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isSayimOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isTedarikciyeIadeOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isBobinKesimlOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isBobinSatisOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isIrsaliyeKabulOpen!) {
      globals.openModulesCount += 1;
    }
    if (globals.isTransferOpen!) {
      globals.openModulesCount += 1;
    }
    print(globals.openModulesCount);
  }

  savePortAndIPToSharedPref(portIP) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('port_and_ip', portIP);
    await prefs.setString("ip", _ipTextFieldController.text.trim());
    await prefs.setInt("port", int.parse(_portTextFieldController.text.trim()));
    await prefs.setString("sayimHol", sayimRadio);
    await prefs.setString(
        "networkUrl",
        _ipTextFieldController.text.trim() +
            ":" +
            _portTextFieldController.text.trim());
  }

  //endregion
  //region FUNCTIONS
  checkApiConnection() async {
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show();
    if (_ipTextFieldController.text.isEmpty ||
        _portTextFieldController.text.isEmpty) {
      EasyLoading.showError("${LocaleKeys.fillIpPort_text.tr()}");
    } else {
      var url = _ipTextFieldController.text +
          ":" +
          _portTextFieldController.text +
          "/api/Ping";
      print("url $url");
      final response = await http.get(Uri.parse(url)).catchError((onError) {
        print(onError);
        EasyLoading.showToast("${LocaleKeys.connectedFailed_text.tr()}");
      });
      print(response.body);
      if (response.statusCode == 200) {
        EasyLoading.showToast("${LocaleKeys.connected_text.tr()}");
      } else {
        EasyLoading.showToast("${LocaleKeys.connectedFailed_text.tr()}");
      }
    }
    EasyLoading.dismiss();
  }

  deleteEverything() async {
    EasyLoading.show();
    var dbClient = await db;
    var tableNames = [
      "Depo_Hareketleri",
      "Kullanicilar",
      "Stok_Karti_Barkod",
      "Depolar",
      "Holler",
      "Makinalar",
      "MerkezHesaplar",
      "Musteriler",
      "OlukluDepolar",
      "Sayimlar",
      "Stok_Karti",
      "Loglar",
      "Irsaliyeler",
      "IrsaliyeDetaylar",
      "IstekTakip",
      "DevirFisleri",
      "Fabrikalar",
      "UretimBarkodHavuz",
    ];
    for (int i = 0; i < tableNames.length; i++) {
      var tableQuery = "DROP TABLE IF EXISTS ${tableNames[i]}";
      await dbClient.execute(tableQuery);
    }
    var portIP = _ipTextFieldController.text.toString() +
        ":" +
        _portTextFieldController.text.toString();
    var firstBool = await FirstLoad.startLoad(portIP);
    print("yüklendi");
    EasyLoading.dismiss();
    if (firstBool == true) {
      await getUpdateInfo();
    }
    await getFactories();
  }

  void itemChange(bool? val, int index) {
    print(index);
    print("globals.openModulesCount ${globals.openModulesCount}");
    if (index == 0) {
      globals.isIrsaliyeKabulOpen = val;
    } else if (index == 1) {
      globals.isImalattanIadeOpen = val;
    } else if (index == 2) {
      globals.isImalattanCikisOpen = val;
    } else if (index == 3) {
      globals.isBobinBitirOpen = val;
    } else if (index == 4) {
      globals.isSayimOpen = val;
    } else if (index == 5) {
      globals.isTransferOpen = val;
    }
    setState(() {
      checkBoxListTileModel[index].isCheck = val;
    });
    print(globals.isTransferOpen);
  }

  getUpdateInfo() async {
    try {
      var db = openDatabase('BSSBobinDB.db');
      var dbClient = await db;
      var res = (await dbClient.rawQuery("select * from IstekTakip"));
      setState(() {
        updateInfo = res;
      });
      print(updateInfo);
    } catch (e) {
      EasyLoading.showError("Güncelleme Verileri Alınamadı");
      throw Exception(e.toString());
    }
  }

  getFactories() async {
    try {
      var db = openDatabase('BSSBobinDB.db');
      var dbClient = await db;
      var res = (await dbClient
          .rawQuery("select Id,FabrikaAdi,Chosen from Fabrikalar"));
      setState(() {
        factories = res;
      });
      print(factories);
    } catch (e) {
      EasyLoading.showError("Fabrika Verileri Alınamadı");
      throw Exception(e.toString());
    }
  }

//endregion
}
