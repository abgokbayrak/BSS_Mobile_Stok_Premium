import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bss_mobile_premium/Screens/Login/login.dart';
import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var db = openDatabase('BSSBobinDB.db');
  var dbLog = openDatabase('BSSBobinDBLog.db');
  void initState() {
    super.initState();
    firstInitFunction();
  }
  firstInitFunction() async {
    await getDataFromSPtoGlobals();
  }
  getDataFromSPtoGlobals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globals.isStokKabulOpen = prefs.getBool("isStokKabulOpen") ?? false;
    globals.isImalattanIadeOpen = prefs.getBool("isImalattanIadeOpen") ?? false;
    globals.isImalattanCikisOpen = prefs.getBool("isImalattanCikisOpen") ?? false;
    globals.isBobinKesimlOpen = prefs.getBool("isBobinKesimlOpen") ?? false;
    globals.isBobinBitirOpen = prefs.getBool("isBobinBitirOpen") ?? false;
    globals.isTedarikciyeIadeOpen = prefs.getBool("isTedarikciyeIadeOpen") ?? false;
    globals.isBobinHolOpen = prefs.getBool("isBobinHolOpen") ?? false;
    globals.isSayimOpen = prefs.getBool("isSayimOpen") ?? false;
    globals.isBobinSatisOpen = prefs.getBool("isBobinSatisOpen") ?? false;
    globals.isIrsaliyeKabulOpen = prefs.getBool("isIrsaliyeKabulOpen") ?? false;
    globals.isTransferOpen = prefs.getBool("isTransferOpen") ?? false;

    globals.nightShiftFinishTime = prefs.getInt("nightShiftFinishTime") ?? 0;
    globals.nightShiftStartTime = prefs.getInt("nightShiftStartTime") ?? 0;

    globals.updatePeriod = prefs.getInt("updatePeriod") ?? 0;
    globals.openModulesCount = prefs.getInt("openModulesCount") ?? 0;
    globals.factoryId = prefs.getInt("factoryId") ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: 'assets/images/MobuyLogo.png',
      nextScreen: LoginScreen(),
      splashTransition: SplashTransition.sizeTransition,
      backgroundColor: Theme.of(context).backgroundColor,
      // curve: Curves.fastOutSlowIn,
      pageTransitionType: PageTransitionType.rightToLeft,
      splashIconSize: 300,
    );
  }
}
