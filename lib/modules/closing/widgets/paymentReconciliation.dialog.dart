import 'dart:io';

import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/closing/models.dart/paymentReconciliation.dart';
import 'package:app/modules/closing/provider/provider.dart';
import 'package:app/pages/home/num.pad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/extensions/widget_extension.dart';

class PaymentReconciliationDialog extends StatefulWidget {
  final String localPath;
  final int tappedRowIndex;
  final String hideTotalAmount;
  PaymentReconciliationDialog(
      {this.localPath, this.tappedRowIndex, this.hideTotalAmount});
  @override
  _PaymentReconciliationDialogState createState() =>
      _PaymentReconciliationDialogState();
}

class _PaymentReconciliationDialogState
    extends State<PaymentReconciliationDialog> {
  ClosingProvider closingProvider;
  int selectedRow;
  String amount = "0";
  bool clearAmount = true;

  @override
  void initState() {
    super.initState();
    this.closingProvider = Provider.of<ClosingProvider>(context, listen: false);
    initialSelectedRow();
  }

  void initialSelectedRow() {
    this.selectedRow = widget.tappedRowIndex;
    if (this
            .closingProvider
            .paymentReconciliations[selectedRow]
            .closingAmount !=
        null) {
      amount = this
          .closingProvider
          .paymentReconciliations[selectedRow]
          .closingAmount
          .toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return typeMobile == TYPEMOBILE.TABLET
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? darkContainerColor : Colors.white,
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    children: [
                      numPad(),
                      Expanded(
                        child: closingAmountInputs(widget.hideTotalAmount),
                      ),
                    ],
                  ),
                ),
              ),
              completeButton()
            ],
          )
        : Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.82,
                      color: isDarkMode ? darkContainerColor : Colors.white,
                      child: Column(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              Expanded(
                                // flex: 10,
                                child:
                                    closingAmountInputs(widget.hideTotalAmount),
                              ),
                              numPad(),
                            ],
                          ))
                        ],
                      ),
                    )),
                completeButton()
              ],
            ),
          );
  }

  Widget completeButton() {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return InkWell(
        child: Container(
          decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12))),
          alignment: Alignment.center,
          height: typeMobile == TYPEMOBILE.TABLET ? 64 : 45, // 45
          width: MediaQuery.of(context).size.width * 0.8,
          child: Text(
            Localization.of(context).tr('resume'),
            style: TextStyle(
                color: Colors.white,
                fontSize: typeMobile == TYPEMOBILE.TABLET ? 22 : 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        });
  }

  Widget numPad() {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Container(
      color: Colors.black12,
      padding: typeMobile == TYPEMOBILE.TABLET
          ? EdgeInsets.symmetric(horizontal: 40, vertical: 80)
          // ==== Mobile ===
          : EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NumPad(
            initialAmount: clearAmount ? "0" : amount,
            getAmount: (String newAmount) {
              clearAmount = false;
              setState(() {});
              setAmount(newAmount);
            },
          ),
        ],
      ),
    );
  }

  void setAmount(String updatedAmount) {
    amount = updatedAmount;
    setState(() {});
  }

  Widget closingAmountInputs(String hideTotalAmount) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    print("HOW COME>");
    return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          headerRow(hideTotalAmount),
          for (int i = 0;
              i < closingProvider.paymentReconciliations.length;
              i++)
            row(i, hideTotalAmount)
        ]).paddingAll(typeMobile == TYPEMOBILE.TABLET ? 20 : 4),
    );
  }

  Widget headerRow(String hideTotalAmount) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Container(
        height: typeMobile == TYPEMOBILE.TABLET ? 50 : 40,
        child: Row(children: [
          Container(
            width: 80,
          ),
          headerColumn(Localization.of(context).tr('amount')),
          headerColumn(Localization.of(context).tr('closing_amount')),
          // if hideTotal 1 hide it
          hideTotalAmount == '1'
              ? headerColumn('')
              : headerColumn(Localization.of(context).tr('different')),
        ]));
  }

  Widget headerColumn(String title) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Expanded(
      child: Container(
        // decoration: boxDecoration(0),
        alignment: Alignment.center,
        child: typeMobile == TYPEMOBILE.TABLET
            ? Text(title)
            // === Mobile ===
            : Text(
                title,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
      ),
    );
  }

  Widget row(int index, String hideTotalAmount) {
    return InkWell(
      child: Row(children: [
        modeOfPayment(index),
        expectedAmount(index),
        closingAmount(index),
        hideTotalAmount == '1' ? const SizedBox.shrink() : different(index),
      ]),
      onTap: () {
        this.selectedRow = index;
        clearAmount = true;
        setState(() {});
        if (this
                .closingProvider
                .paymentReconciliations[selectedRow]
                .closingAmount !=
            null) {
          amount = this
              .closingProvider
              .paymentReconciliations[selectedRow]
              .closingAmount
              .toStringAsFixed(2);
        } else {
          amount = "0";
        }
        setState(() {});
      },
    );
  }

  Widget different(int index) {
    PaymentReconciliation paymentReconciliation =
        closingProvider.paymentReconciliations[index];
    double different;
    if (paymentReconciliation.closingAmount == null) {
      different = paymentReconciliation.expectedAmount;
    } else {
      different = double.parse(
              paymentReconciliation.closingAmount.toStringAsFixed(2)) -
          double.parse(paymentReconciliation.expectedAmount.toStringAsFixed(2));
    }
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Expanded(
      child: Container(
        decoration: boxDecoration(index,
            color: differentColor(paymentReconciliation.expectedAmount,
                paymentReconciliation.closingAmount)),
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        alignment: Alignment.center,
        child: typeMobile == TYPEMOBILE.TABLET
            ? Text(different.toStringAsFixed(2), style: TextStyle(fontSize: 18))
            : FittedBox(
                child: Text(
                  different.toStringAsFixed(2),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.5,
                  ),
                ),
              ),
      ),
    );
  }

  // get differnt color
  Color differentColor(double expectedAmount, double closingAmount) {
    if (closingAmount == null) {
      return Colors.red;
    }
    double expectedAmountFixed =
        double.parse((expectedAmount).toStringAsFixed(2));
    double closingAmountFixed =
        double.parse((closingAmount).toStringAsFixed(2));
    if (expectedAmountFixed > closingAmountFixed) {
      return Colors.red;
    }
    if (expectedAmountFixed < closingAmountFixed) {
      return Colors.yellow;
    }
    return themeColor;
  }

  Widget closingAmount(int index) {
    PaymentReconciliation paymentReconciliation =
        closingProvider.paymentReconciliations[index];
    if (selectedRow == index) {
      if (paymentReconciliation.closingAmount == null) {
        paymentReconciliation.closingAmount = 0;
      } else {
        paymentReconciliation.closingAmount = double.parse(amount);
      }
    }
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Expanded(
      child: Container(
        decoration: boxDecoration(index),
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        alignment: Alignment.center,
        child: typeMobile == TYPEMOBILE.TABLET
            ? Text(
                paymentReconciliation.closingAmount == null
                    ? ""
                    : paymentReconciliation.closingAmount.toStringAsFixed(2),
                style: TextStyle(fontSize: 18),
              )
            : FittedBox(
                child: Text(
                  paymentReconciliation.closingAmount == null
                      ? ""
                      : paymentReconciliation.closingAmount.toStringAsFixed(2),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.5,
                  ),
                ),
              ),
      ),
    );
  }

  Widget expectedAmount(int index) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Expanded(
      child: Container(
        decoration: boxDecoration(index),
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        alignment: Alignment.center,
        child: typeMobile == TYPEMOBILE.TABLET
            ? Text(
                closingProvider.paymentReconciliations[index].expectedAmount
                    .toStringAsFixed(2),
                style: TextStyle(fontSize: 18))
            : FittedBox(
                child: Text(
                    closingProvider.paymentReconciliations[index].expectedAmount
                        .toStringAsFixed(2),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12.5,
                    )),
              ),
      ),
    );
  }

  Widget modeOfPayment(int index) {
    PaymentReconciliation paymentReconciliation =
        closingProvider.paymentReconciliations[index];
    return Container(
      decoration: boxDecoration(index),
      width: 80,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      alignment: Alignment.center,
      child:
          paymentReconciliation.icon != '' && paymentReconciliation.icon != null
              ? Image.file(
                  File(
                    '${widget.localPath}/${paymentReconciliation.modeOfPayment.replaceAll(new RegExp(r"\s+\b|\b\s"), "")}.png',
                  ),
                  scale: 10)
              : Text(paymentReconciliation.modeOfPayment),
    );
  }

  BoxDecoration boxDecoration(int rowIndex, {Color color}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return BoxDecoration(
        border: selectedRow == rowIndex
            ? Border.all(color: themeColor, width: 2)
            : null,
        color: color == null
            ? selectedRow == rowIndex
                ? isDarkMode != true
                    ? Colors.white
                    : Colors.grey.shade700
                : Colors.black12
            : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12));
  }
}
