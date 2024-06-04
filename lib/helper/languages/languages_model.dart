import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as UI;

import 'locale_keys.g.dart';

class LanguageModel{
  final int id;
  final String name;
   String flag;
  final Locale languageCode;
  final UI.TextDirection textDirection;
  static const Locale trLocale = Locale('tr', 'TR');
  static const Locale enLocale = Locale('en', 'US');
  static const Locale faLocale = Locale('fa', 'IR');
  static UI.TextDirection directionLTR = UI.TextDirection.ltr;
  static UI.TextDirection directionRTL = UI.TextDirection.rtl;
  LanguageModel(this.id,this.name,this.flag,this.languageCode,this.textDirection);
  static List<LanguageModel> languageList(){
  return<LanguageModel>[
    LanguageModel(1, LocaleKeys.turkish_text.tr(), "🇹🇷",trLocale,directionLTR),
    // LanguageModel(2, LocaleKeys.english_text.tr(), "🇬🇧",enLocale,directionLTR),
    // LanguageModel(3, LocaleKeys.persian_text.tr(), "🇮🇷",faLocale,directionRTL),
  ];

  }

}