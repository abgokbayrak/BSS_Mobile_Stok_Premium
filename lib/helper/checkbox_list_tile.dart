import 'package:bss_mobile_premium/globals/globals.dart';
import 'package:easy_localization/easy_localization.dart';
import 'languages/locale_keys.g.dart';

class CheckBoxListTileModel {
  int? menuItemId;
  String? title;
  bool? isCheck;


  CheckBoxListTileModel({this.menuItemId, this.title, this.isCheck});
  static List<CheckBoxListTileModel> getUsers() {
    return <CheckBoxListTileModel>[
      CheckBoxListTileModel(
          menuItemId: 1, title: "Barkod Kabul", isCheck: globals.isIrsaliyeKabulOpen),
      // CheckBoxListTileModel(
      //     menuItemId: 2, title: LocaleKeys.stockAccept_text.tr(), isCheck: globals.isStokKabulOpen),
      CheckBoxListTileModel(
          menuItemId: 2,
          title: LocaleKeys.returnProduction_text.tr(),
          isCheck: globals.isImalattanIadeOpen),
      CheckBoxListTileModel(
          menuItemId: 3,
          title: LocaleKeys.outProduction_text.tr(),
          isCheck: globals.isImalattanCikisOpen),
      CheckBoxListTileModel(
          menuItemId: 4,
          title: LocaleKeys.coilEnd_text.tr(),
          isCheck: globals.isBobinBitirOpen),
      CheckBoxListTileModel(
          menuItemId: 5, title: LocaleKeys.counting_text.tr(), isCheck: globals.isSayimOpen),
      CheckBoxListTileModel(
          menuItemId: 6,
          title: "Transfer",
          isCheck: globals.isBobinKesimlOpen),
    ];
  }
}
