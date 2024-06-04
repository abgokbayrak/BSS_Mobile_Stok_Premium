import 'package:flutter/material.dart';
import '../Screens/Login/login.dart';
import '../Screens/Splash/splash.dart';
import '../Screens/settings/settings.dart';
import '../screens/Home/home.dart';

class BSSRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => MenuButtons());
      case settingsPage:
        return MaterialPageRoute(builder: (_) => SettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Ters giden birşeyler oldu'),
            ),
          ),
        );
    }
  }
}

const String settingsPage = '/settings';
const String bobinEkraniRoute = '/bobinEkraniRoute';
const String depoSecRoute = '/depoSec';
const String home = '/home';
const String splash = '/splash';
const String login = '/login';
