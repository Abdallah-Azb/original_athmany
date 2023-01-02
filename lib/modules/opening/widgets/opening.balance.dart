import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/modules/opening/provider/new.opening.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:nil/nil.dart';
import '../../../core/extensions/widget_extension.dart';
class OpeningBalanceList extends StatefulWidget {
  @override
  OpeningBalanceState createState() => OpeningBalanceState();
}

class OpeningBalanceState extends State<OpeningBalanceList> {
  List<OpeningBalance> openingBalanceList = [];
  String baseUrl;
  Future<void> getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.baseUrl = prefs.getString('base_url');
  }

  @override
  void initState() {
    super.initState();
    this.getBaseUrl();
  }

  int selectedPaymentMethod = 0;

  @override
  Widget build(BuildContext context) {
    this.openingBalanceList =
        context.read<NewOpeningProvider>().openingBalanceList;
    return Column(
      children: [
        label(),
        for (int i = 0; i < openingBalanceList.length; i++)
          Container(
            margin: EdgeInsets.all(4),
            child: InkWell(
              child: Row(
                children: [icon(i), balance(i)],
              ),
              onTap: () {
                openingBalanceDialog(i);
                this.selectedPaymentMethod = i;
                setState(() {});
              },
            ),
          )
      ],
    );
  }

  // label
  Widget label() {
    return Container(
      child: openingBalanceList.length > 1
          ? Text(
              Localization.of(context).tr('payment_methods'),
              style: TextStyle(fontSize: 20),
            ).paddingAll(6)
          : SizedBox.shrink(),
    );
  }

  // payment mehtod icon
  Widget icon(int i) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;

    Color color() {
      Color color = isDarkMode ? Colors.white70 : Colors.black38;
      return color;
    }

    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDarkMode ? darkContainerColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: this.selectedPaymentMethod == i
              ? Border.all(color: themeColor, width: 2)
              : Border.all(color: color(), width: 2),
        ),
        width: 120, height: 50,
        child: this.openingBalanceList[i].icon == null ||
                this.openingBalanceList[i].icon == ''
            ? Text(
                this.openingBalanceList[i].modeOfPayment,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            // : Text('asdf'),
            // merge ix , they add center as parent for follwong wifget
            : Image.network("$baseUrl/${this.openingBalanceList[i].icon}"),
        // : Image.asset(paymentMethos[i].icon, height: 22),
      ),
    );
  }

  // payment method opening balance
  Widget balance(int i) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;

    Color color() {
      Color color = isDarkMode ? Colors.white70 : Colors.black38;
      return color;
    }

    return Expanded(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 5, right: 5),
        height: 50,
        decoration: BoxDecoration(
          border: this.selectedPaymentMethod == i
              ? Border.all(color: themeColor, width: 2)
              : Border.all(color: color(), width: 2),
          color: isDarkMode ? darkContainerColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          openingBalanceList[i].openingAmount == null
              ? Localization.of(context).tr('enter_closing_amount')
              : openingBalanceList[i].openingAmount.toStringAsFixed(2),
          style: TextStyle(fontSize: 18),
        ),
        // child: balanceInput(i),
      ),
    );
  }

  TextFormField balanceInput(int i) {
    return TextFormField(
      style: TextStyle(fontSize: 22, height: 1.6),
      decoration: inputDecoration(),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      textAlign: TextAlign.center,
      // onTap
      onTap: () {
        this.selectedPaymentMethod = i;
        setState(() {});
      },
      // onchanged
      onChanged: (value) {
        if (value == '') {
          this.openingBalanceList[i].openingAmount = 0.0;
        }
        this.openingBalanceList[i].openingAmount = double.parse(value);
      },
    );
  }

  // input decoration
  InputDecoration inputDecoration() {
    return InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding:
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        hintText: "0.0",
        hintStyle: TextStyle(fontSize: 24, height: 1.1));
  }

  openingBalanceDialog(int index) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: OpeningBalanceDialog(
              openingBalanceList: openingBalanceList,
              baseUrl: this.baseUrl,
              tappedRowIndex: index),
        );
      },
    ).then((value) => {
          setState(() {}),
          // context.read<NewOpeningProvider>().openingBalanceList
        });
  }

  // openingBalanceDialog(context, int index) async {
  //   await showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20.0)), //this right here
  //         child: OpeningBalanceDialogRefactor(
  //             openingBalanceList: openingBalanceList,
  //             baseUrl: this.baseUrl,
  //             tappedRowIndex: index),
  //       );
  //     },
  //   ).then((value) => {
  //         setState(() {}),
  //         context.read<NewOpeningProvider>().openingBalanceList
  //       });
  // }

  // void setSubmitValue({bool disableSubmit}) {
  //   if (disableSubmit != null && disableSubmit == true)
  //     _submit = false;
  //   else {
  //     bool canSubmit = true;
  //     for (PaymentReconciliation paymentReconciliation
  //         in paymentReconciliations) {
  //       if (paymentReconciliation.closingAmount == null) canSubmit = false;
  //     }
  //     _submit = canSubmit;
  //     notifyListeners();
  //   }
  // }
}
