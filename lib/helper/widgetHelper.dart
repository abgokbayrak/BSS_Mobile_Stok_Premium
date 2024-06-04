import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import 'languages/languages_model.dart';
import 'languages/locale_keys.g.dart';

TextStyle textStyle = const TextStyle( fontSize: 13, fontWeight: FontWeight.w500);
TextStyle textFieldStyle = const TextStyle(fontSize: 20.0,);
var textFieldBorder = const OutlineInputBorder(
  borderSide: BorderSide(color: Colors.black, width: 1.0),
);
class KgAndStokAdiWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController kgController;

  KgAndStokAdiWidget({required this.controller,required this.kgController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 12,
          child: TextField(
            textAlign: TextAlign.center,
            maxLines: 2,
            controller: controller,
            enabled: false,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            ),
          ),
        ),
        SizedBox(width: 10,),
        Expanded(
          flex: 3,
          child: TextField(
            maxLines: 2,
            keyboardType: TextInputType.number,
            controller: kgController,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              enabledBorder: textFieldBorder,
              border: OutlineInputBorder(),
            ),
          ),
        ),

      ],
    );
  }
}

class StokAdiWidget extends StatelessWidget {
  final TextEditingController controller;

  StokAdiWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("STOK İSMİ :", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        TextField(
          textAlign: TextAlign.center,
          maxLines: 3,
          controller: controller,
          enabled: false,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }
}
class TedarikciBobinNoWidget extends StatelessWidget {
  final TextEditingController controller;

  TedarikciBobinNoWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
      return Row(
        children: [
          Expanded(flex:0,child: Text("TEDARİKÇİ BOBİN NO : ",style:textStyle)),
          Expanded(flex : 3,child:TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,                      // Added this
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black45, width: 2.0),
              ),
            ),
          ) ),
        ],
      );


  }
}


class ButtonsRow extends StatelessWidget {
  final VoidCallback onKapatPressed;
  final VoidCallback onYeniPressed;
  final VoidCallback onKaydetPressed;

  ButtonsRow({
    required this.onKapatPressed,
    required this.onYeniPressed,
    required this.onKaydetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          OutlinedButton.icon(
            onPressed: onKapatPressed,
            icon: Icon(Icons.close, color: Colors.white),
            label: Text(
              "Kapat",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              overlayColor: MaterialStateProperty.all(Colors.red),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onYeniPressed,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text(
              "Yeni",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey),
              overlayColor: MaterialStateProperty.all(Colors.red),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onKaydetPressed,
            icon: Icon(Icons.save, color: Colors.white),
            label: Text(
              "Kaydet",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
              overlayColor: MaterialStateProperty.all(Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class BarcodeRow extends StatelessWidget {
  final TextEditingController barcodeTextFieldController;
  final Function(String) getTextFieldText;
  final Function errorOnBarcodeControl;
  final FocusNode? barcodeFocusNode;

  BarcodeRow({
    required this.barcodeTextFieldController,
    required this.getTextFieldText,
    required this.errorOnBarcodeControl,
     this.barcodeFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 0,
          child: Text("BARKOD : ",style: textStyle,),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            onFieldSubmitted: (_) {
              if (barcodeTextFieldController.text.isNotEmpty &&
                  barcodeTextFieldController.text.length != 1) {
                getTextFieldText(barcodeTextFieldController.text);
              } else {
                errorOnBarcodeControl();
              }
            },
            controller: barcodeTextFieldController,
            keyboardType: TextInputType.number,
            focusNode: barcodeFocusNode,
            style: textFieldStyle,

            decoration: InputDecoration(
              isDense: true,                      // Added this
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              hintText: "${LocaleKeys.barcode_text.tr()}",
              enabledBorder: textFieldBorder,

            ),

          ),
        ),
      ],
    );
  }
}


class KgAndDateRow extends StatelessWidget {
  final TextEditingController kgTextFieldController;
  final DateTime selectedDate;
  final Function(BuildContext) selectDate;
  final Function(BuildContext) buildMaterialDatePicker;
  final TextStyle textStyle;
  final TextStyle textFieldStyle;
  final OutlineInputBorder textFieldBorder;

  KgAndDateRow({
    required this.kgTextFieldController,
    required this.selectedDate,
    required this.selectDate,
    required this.buildMaterialDatePicker,
    required this.textStyle,
    required this.textFieldStyle,
    required this.textFieldBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 0,
          child: Text(
            "${LocaleKeys.kg_text.tr().toUpperCase()} :  ",
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
        Expanded(flex: 2, child: SizedBox()),
        Expanded(
          flex: 11,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: kgTextFieldController,
            style: textFieldStyle,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(8),
              enabledBorder: textFieldBorder,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(flex: 1, child: SizedBox()),
        Expanded(
          flex: 0,
          child: Text(
            "TARİH :  ",
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
        Expanded(
          flex: 13,
          child: context.locale == LanguageModel.faLocale
              ? RaisedButton(
            color: Colors.black45,
            onPressed: () => buildMaterialDatePicker(context),
            child: Text(
              selectedDate.toString().toPersianDigit(),
              style: textStyle,
            ),
          )
              : RaisedButton(
            color: Colors.black45,
            onPressed: () => selectDate(context),
            child: Text(
              "${selectedDate.toLocal()}".split(' ')[0],
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }
}

