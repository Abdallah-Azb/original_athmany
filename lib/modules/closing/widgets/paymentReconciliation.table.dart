import 'dart:io';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/closing/models.dart/models.dart';
import 'package:app/modules/closing/provider/provider.dart';
import 'package:app/modules/closing/widgets/paymentReconciliation.dialog.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widget/widget/loading_animation_widget.dart';

class PaymentReconciliationTable extends StatefulWidget {
  final List<PaymentReconciliation> paymentReconciliation;
  PaymentReconciliationTable(this.paymentReconciliation);

  @override
  _PaymentReconciliationTableState createState() =>
      _PaymentReconciliationTableState();
}

class _PaymentReconciliationTableState
    extends State<PaymentReconciliationTable> {
  Future localPathFuture;
  ClosingProvider closingProvider;
  String localPath;
  String hideTotalAmount;

  Future<String> getLocalPath() async {
    this.localPath = await CacheItemImageService().localPath;
    return this.localPath;
  }

  hideTotalAmountF() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    this.hideTotalAmount = _prefs.getString('hide_total_amount');
  }

  @override
  void initState() {
    super.initState();
    hideTotalAmountF();
    this.localPathFuture = getLocalPath();
    this.closingProvider = Provider.of<ClosingProvider>(context, listen: false);
    this.closingProvider.paymentReconciliations = widget.paymentReconciliation;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getLocalPath(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (snapshot.hasData) {
          this.localPath = snapshot.data;
          return table(hideTotalAmount);
        }
        return Center(
            child: LoadingAnimation(
          typeOfAnimation: "staggeredDotsWave",
          color: themeColor,
          size: 100,
        ));
      },
    );
  }

  Widget table(String hideTotalAmount) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Table(
          columnWidths: typeMobile == TYPEMOBILE.TABLET
              ? {
                  0: FlexColumnWidth(0.2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                }
              : {
                  0: FlexColumnWidth(0.3),
                  1: FlexColumnWidth(0.7),
                  2: FlexColumnWidth(0.7),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(0.7),
                },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                headerCell(Localization.of(context).tr('no')),
                headerCell(Localization.of(context).tr('mode_of_payment')),
                headerCell(Localization.of(context).tr('amount')),
                headerCell(Localization.of(context).tr('closing_amount')),
                hideTotalAmount == '1'
                    ? headerCell('')
                    : headerCell(Localization.of(context).tr('different')),
              ],
            ),
            for (int i = 0; i < widget.paymentReconciliation.length; i++)
              TableRow(
                children: <Widget>[
                  cell((i + 1).toString()),
                  modeOfPaymentCell(closingProvider.paymentReconciliations[i]),
                  hideTotalAmount == '1'
                      ? cell('xxx')
                      : cell(closingProvider
                          .paymentReconciliations[i].expectedAmount
                          .toStringAsFixed(2)),
                  closingAmountCell(i, hideTotalAmount),
                  hideTotalAmount == '1' ? cell('') : differentCell(i),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget headerCell(String title) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        alignment: Alignment.center,
        height: typeMobile == TYPEMOBILE.TABLET ? 55 : 50,
        color: blueGrayColor,
        child: Text(
          title,
          maxLines: 1,
          style: TextStyle(
            color: Colors.white,
            fontSize: typeMobile == TYPEMOBILE.TABLET ? 18 : 12,
          ),
        ),
      ),
    );
  }

  Widget cell(String title) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        alignment: Alignment.center,
        height: 55,
        color: isDarkMode == false ? Colors.white : darkContainerColor,
        child: Text(title,
            style: TextStyle(
              fontSize: typeMobile == TYPEMOBILE.TABLET ? 18 : 12,
              color: isDarkMode == false ? Colors.black : Colors.white,
            )),
      ),
    );
  }

  Widget differentCell(int index) {
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
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        color: isDarkMode == false ? Colors.white : darkContainerColor,
        alignment: Alignment.center,
        child: Container(
            decoration: BoxDecoration(
              color: differentColor(paymentReconciliation.expectedAmount,
                      paymentReconciliation.closingAmount)
                  .withOpacity(0.2),
            ),
            alignment: Alignment.center,
            width: double.infinity,
            height: 55,
            child: typeMobile == TYPEMOBILE.TABLET
                ? Text(different.toStringAsFixed(2),
                    style: TextStyle(fontSize: 18))
                : FittedBox(
                    child: Text(
                      different.toStringAsFixed(2),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12.5,
                      ),
                    ),
                  )),
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

  Widget modeOfPaymentCell(PaymentReconciliation paymentReconciliation) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        alignment: Alignment.center,
        height: 55,
        color: isDarkMode == false ? Colors.white : darkContainerColor,
        child: paymentReconciliation.icon != '' &&
                paymentReconciliation.icon != null
            ? Image.file(
                File(
                  '${this.localPath}/${paymentReconciliation.modeOfPayment.replaceAll(new RegExp(r"\s+\b|\b\s"), "")}.png',
                ),
                scale: 10)
            : Text(paymentReconciliation.modeOfPayment),
      ),
    );
  }

  Widget closingAmountCell(int index, String hideTotalAmount) {
    PaymentReconciliation paymentReconciliation =
        closingProvider.paymentReconciliations[index];
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: InkWell(
        child: Container(
          alignment: Alignment.center,
          height: 55,
          color: isDarkMode == false ? Colors.white : darkContainerColor,
          child: Text(
            paymentReconciliation.closingAmount == null
                ? Localization.of(context).tr('enter_closing_amount')
                : paymentReconciliation.closingAmount.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: typeMobile == TYPEMOBILE.TABLET ? 18 : 13,
              color: isDarkMode == false ? Colors.black : Colors.white,
            ),
          ),
        ),
        onTap: () {
          openPaymentReconciliationDialog(context, index);
        },
      ),
    );
  }

  openPaymentReconciliationDialog(context, int index) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: PaymentReconciliationDialog(
              localPath: this.localPath,
              tappedRowIndex: index,
              hideTotalAmount: hideTotalAmount),
        );
      },
    ).then((value) => {setState(() {}), closingProvider.setSubmitValue()});
  }
}
