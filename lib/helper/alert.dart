import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'languages/locale_keys.g.dart';

showAlertWithOKButton(context, title, message) {
  EasyLoading.dismiss();
  Alert(
    context: context,
    title: title,
    desc: message,
    buttons: [
      DialogButton(
        child: Text(
          LocaleKeys.okey_text.tr(),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        width: 120,
      )
    ],
  ).show();
}
