import 'package:app/core/utils/const.dart';
import 'package:app/modules/pay-dialog/models/payment.method.dart';
import 'package:app/modules/pay-dialog/pay.dialog.provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';

class PaidTotalContainer extends StatelessWidget {
  const PaidTotalContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    double paidTotal = 0;
    for (PaymentMethodRefactor paymentMethod
        in context.watch<PayDialogProvider>().paymentMethods) {
      paidTotal += double.parse(paymentMethod.payment.amountStr);
      context.watch<PayDialogProvider>().setPaidTotal(paidTotal);
    }
    return typeMobile == TYPEMOBILE.TABLET
        ? Center(
            child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 80,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    border: Border.all(color: themeColor, width: 4)),
                child: Text(
                  context
                      .read<PayDialogProvider>()
                      .paidTotal
                      .toStringAsFixed(2),
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                )
                // child: Text(
                //   paidTotal.toStringAsFixed(2),
                //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                // )
                ),
          )
        // ===== Mobile ====
        : Center(
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
                border: Border.all(
                  color: themeColor,
                  width: 2,
                ),
              ),
              child: Text(
                context.read<PayDialogProvider>().paidTotal.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
  }
}
