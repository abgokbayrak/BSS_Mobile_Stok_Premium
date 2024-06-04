import 'package:bss_mobile_premium/Screens/Splash/splash.dart';
import 'package:bss_mobile_premium/theme/manager/theme_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'helper/languages/codegen_loader.g.dart';
import 'helper/languages/languages_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
      path: "assets/languages",
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('tr', 'TR'),
        Locale('fa', 'IR'),
      ],
      assetLoader: CodegenLoader(),
      startLocale: LanguageModel.trLocale,
      fallbackLocale: LanguageModel.trLocale,
      saveLocale: true,
      child: CustomThemeListener()));
}

class CustomThemeListener extends StatelessWidget {
  const CustomThemeListener({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager.instance),
      ],
      child: BSSPremium(),
    );
  }
}
class BSSPremium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // onGenerateRoute: BSSRouter.generateRoute,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: context.theme,
      home: SplashScreen(),
      builder: EasyLoading.init(),

    );
  }
}

