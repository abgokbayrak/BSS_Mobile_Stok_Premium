import 'package:flutter/widgets.dart';

class ScreenSizeService {
  static double? _screenWidth;
  static double? _screenHeight;

  static double? get screenWidth => _screenWidth;
  static double? get screenHeight => _screenHeight;

  static void updateScreenSize(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
  }
}