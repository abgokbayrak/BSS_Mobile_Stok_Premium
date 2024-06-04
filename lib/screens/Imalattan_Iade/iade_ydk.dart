// Expanded(
// child: SingleChildScrollView(
// child: Container(
// padding: EdgeInsets.all(10.0),
// child: Column(children: <Widget>[
//
// Padding(
// padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
// child: BarcodeRow(
// barcodeTextFieldController: _bobinBarkodNoTextField,
// getTextFieldText: getBarcodeInfos,
// errorOnBarcodeControl: (){},
// barcodeFocusNode: barcodeFocusNode,
// ),
// ),
// Padding(
// padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
// Expanded(
// flex: 0,
// child: Text(
// "${LocaleKeys.kg_text.tr().toUpperCase()} :",
// textAlign: TextAlign.center,
// style: textStyle,
// ),
// ),
// Expanded(flex: 2, child: SizedBox()),
// Expanded(
// flex: 18,
// child: TextField(
// keyboardType: TextInputType.number,
// controller: _kgTextFieldController,
// style: textFieldStyle,
// decoration: InputDecoration(
// isDense: true,
// contentPadding: EdgeInsets.all(8),
// enabledBorder: textFieldBorder,
// border: OutlineInputBorder(),
// ),
// ),
// ),
// ],
// ),
// ),
// Padding(
// padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
// child: StokAdiWidget(
// controller: _stokIsmiTextFieldController,
// ),
// ),
// Padding(
// padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
// child: Row(
// children: [
// Expanded(
// flex: 0, child: Text("HOL : ", style: textStyle)),
// Expanded(
// flex: 11,
// child: RaisedButton(
// color: Colors.black45,
// onPressed: () => getAllHoller(),
// child: Text(
// holTextSelected
// ? holText!
// : LocaleKeys.chooseHall_text.tr(),
// style: TextStyle(
// fontSize: 15,
// color: Colors.white,
// fontWeight: FontWeight.bold),
// ),
// ),
// ),
// Expanded(flex: 1, child: SizedBox()),
// Expanded(
// flex: 0,
// child: Text(
// "TARİH :  ",
// textAlign: TextAlign.center,
// style: textStyle,
// ),
// ),
// Expanded(
// flex: 13,
// child: context.locale == LanguageModel.faLocale
// ? RaisedButton(
// color: Colors.black45,
// onPressed: () =>
// buildMaterialDatePicker(context),
// child: Text(
// selectedDate.toString().toPersianDigit(),
// style: textStyle,
// ),
// )
// : RaisedButton(
// color: Colors.black45,
// onPressed: () => _selectDate(context),
// child: Text(
// "${selectedDate.toLocal()}".split(' ')[0],
// style: TextStyle(
// fontSize: 15,
// color: Colors.white,
// fontWeight: FontWeight.bold),
// ),
// ),
// ),
// ],
// ),
// ),
// ]),
// )),
//
// ),
