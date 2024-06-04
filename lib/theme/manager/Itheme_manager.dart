import 'package:bss_mobile_premium/theme/manager/theme_manager.dart';
import 'package:flutter/material.dart';
abstract class IThemeManager {
  late ThemeData currentTheme;
  late ThemeEnum currentThemeEnum;

  void changeTheme(ThemeEnum theme);
}