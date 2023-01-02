import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';

import 'package:app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import '../../pay.dialog.provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/widget_extension.dart';
class PaymentMethodInput extends StatefulWidget {
  final int index;
  PaymentMethodInput(this.index);

  @override
  _PaymentMethodInputState createState() => _PaymentMethodInputState();
}

class _PaymentMethodInputState extends State<PaymentMethodInput> {
  PayDialogProvider payDialogProvider;

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;

    this.payDialogProvider = context.watch<PayDialogProvider>();
    return typeMobile == TYPEMOBILE.TABLET
        ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              color: this.payDialogProvider.activePaymentMethod == widget.index
                  ? themeColor
                  : Colors.black12,
              alignment: Alignment.center,
              child: Text(
                double.parse(payDialogProvider
                        .paymentMethods[widget.index].payment.amountStr)
                    .toStringAsFixed(2),
                style: TextStyle(
                    color: isDarkMode == false ? Colors.black : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ).paddingAll(10),
            ),
          )

        // === Mobile ====

        : Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    this.payDialogProvider.activePaymentMethod == widget.index
                        ? themeColor
                        : Colors.black12,
                border: Border.all(
                    color: isDarkMode ? Colors.white70 : Colors.black38)),
            alignment: Alignment.center,
            child: Text(
              double.parse(payDialogProvider
                      .paymentMethods[widget.index].payment.amountStr)
                  .toStringAsFixed(2),
              style: TextStyle(
                  color:
                      this.payDialogProvider.activePaymentMethod == widget.index
                          ? Colors.white
                          : Colors.white60,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ).paddingAll(5),
          );
  }
}
