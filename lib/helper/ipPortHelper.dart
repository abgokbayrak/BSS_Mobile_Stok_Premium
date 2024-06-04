import 'package:shared_preferences/shared_preferences.dart';

class IpPort{
  static get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('port_and_ip') != null){
      var ipPort = prefs.getString('port_and_ip')!;
      return ipPort;
    }
    throw Exception("Ip ve Port Giriniz");
  }
}
