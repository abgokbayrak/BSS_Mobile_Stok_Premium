import 'package:bss_mobile_premium/Screens/Login/login.dart';
import 'package:bss_mobile_premium/data_model/services/update_function.dart';
import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:bss_mobile_premium/screens/Bobin_Bitir/bobin_bitir.dart';
import 'package:bss_mobile_premium/screens/Imalata_Cikis/imalata_cikis.dart';
import 'package:bss_mobile_premium/screens/Imalattan_Iade/imalattan_iade.dart';
import 'package:bss_mobile_premium/screens/Irsaliye_Kabul/irsaliye_kabul.dart';
import 'package:bss_mobile_premium/screens/Sayim/sayim.dart';
import 'package:bss_mobile_premium/screens/Stok_Kabul/stok_kabul.dart';
import 'package:bss_mobile_premium/screens/Transfer/transfer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../helper/languages/locale_keys.g.dart';
import '../Barkod_Giris/barkod_giris.dart';



class MenuButtons extends StatelessWidget {
  final renkDizisi = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.yellow,
    Colors.brown,
    Colors.cyan,
  ];
  List<Widget> gridChildren = [];

  GetMenuButtons(BuildContext context){
    if (globals.isIrsaliyeKabulOpen!) {
      gridChildren.add(
        MenuButton(
          title: 'BARKOD\nKABUL',
          onPressed: () => _handleButtonClick(context, 1),
          color: [renkDizisi[9], renkDizisi[9]],
        ),
      );
    }
    if (globals.isImalattanCikisOpen!) {
      gridChildren.add(
        MenuButton(
          title: 'İMALATA\nÇIKIŞ',
          onPressed: () => _handleButtonClick(context, 3),
          color: [renkDizisi[3], renkDizisi[3]],
        ),
      );
    }
    if (globals.isImalattanIadeOpen!) {
      gridChildren.add(
        MenuButton(
          title: 'İMALATTAN\nİADE',
          onPressed: () => _handleButtonClick(context, 4),
          color: [renkDizisi[0], renkDizisi[0]],
        ),
      );
    }
    if (globals.isBobinBitirOpen!) {
      gridChildren.add(
        MenuButton(
          title: 'BOBİN\nBİTİR',
          onPressed: () => _handleButtonClick(context, 5),
          color: [renkDizisi[4], renkDizisi[4]],
        ),
      );
    }
    if (globals.isSayimOpen!) {
      gridChildren.add(
        MenuButton(
          title: 'SAYIM',
          onPressed: () => _handleButtonClick(context, 6),
          color: [renkDizisi[8], renkDizisi[8]],
        ),
      );
    }
    if (globals.isTransferOpen!) {
      gridChildren.add(
        MenuButton(
          title: 'TRANSFER',
          onPressed: () => _handleButtonClick(context, 7),
          color: [renkDizisi[1], renkDizisi[1]],
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    GetMenuButtons(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("ANA MENÜ"),
automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 0.0),
              child: FlatButton(
                onPressed: () => logoutButtonPressed(context),
                child: Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 35.0,
                ),
              )),
        ],),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: globals.openModulesCount > 6 ? 1.45:1.07 ,
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              children: gridChildren
            ),

          ),
          UpdateButton(title: 'GÜNCELLE', onPressed: () => _handleButtonClick(context, 8),color: [
            Color(0xFF800000),
            Color(0xFF800000),
          ]),
        ],
      ),
    );
  }
  logoutButtonPressed(context) async {
    Alert(
      context: context,
      type: AlertType.warning,
      title: LocaleKeys.exit_text.tr().toUpperCase(),
      desc: LocaleKeys.wantToExit_text.tr(),
      buttons: [
        DialogButton(
          child: Text(
            LocaleKeys.no_text.tr(),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.red,
        ),
        DialogButton(
          child: Text(
            LocaleKeys.yes_text.tr(),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () =>Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            ModalRoute.withName('/'),
          ),
          color:Colors.green,
        ),
      ],
    ).show();
  }

  void _handleButtonClick(BuildContext context, int buttonIndex) async {
    switch (buttonIndex){
      case 1 :
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>  BarkoGiris()),
        );
        break;
      case 2 :
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StokKabul()),
        );
        break;
      case 3 :
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImalataCikis()),
        );
        break;
      case 4 :
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImalattanIade()),
        );
        break;
      case 5 :
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BobinBitir()),
        );
        break;
      case 6 :
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Sayim()),
        );
        break;
      case 7 :
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const Transfer()),
        );
        break;
      case 8 :
        await generalUpdateFunction(false);
        break;
    }
    }
}

class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final List<Color> color;

  const MenuButton({required this.title, required this.onPressed,required this.color});

  @override
  Widget build(BuildContext context) {
    final parts = title.split(" "); // Metni boşluk karakterlerine göre böler
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(6.0),
        primary: Colors.white10,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        shadowColor: Colors.black,
        elevation: 4,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: color,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: parts.map((part) => Center(
            child: Text(
              part,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),
            ),
          )).toList(),
        ),
      ),
    );
  }
}
class UpdateButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final List<Color> color;

  const UpdateButton({required this.title, required this.onPressed,required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(7.0),
        primary: Colors.white10,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        shadowColor: Colors.redAccent,
        elevation: 1,
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: color,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
