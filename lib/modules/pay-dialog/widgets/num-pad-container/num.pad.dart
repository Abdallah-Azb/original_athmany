import 'package:app/modules/pay-dialog/pay.dialog.provider.dart';
import 'package:app/pages/home/num.pad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayDialogNumPad extends StatefulWidget {
  const PayDialogNumPad({Key key}) : super(key: key);

  @override
  _PayDialogNumPadState createState() => _PayDialogNumPadState();
}

class _PayDialogNumPadState extends State<PayDialogNumPad> {
  @override
  Widget build(BuildContext context) {
    PayDialogProvider payDialogProvider = context.watch<PayDialogProvider>();
    return NumPad(
      initialAmount: setInitialAmount(),
      getAmount: (String newAmount) {
        payDialogProvider.setClearAmount(false);
        payDialogProvider.setAmount(newAmount);
      },
    );
  }

  String setInitialAmount() {
    PayDialogProvider payDialogProvider = context.watch<PayDialogProvider>();
    if (payDialogProvider.activePaymentMethod == null ||
        payDialogProvider.clearAmount) {
      return "0";
    }
    return payDialogProvider
        .paymentMethods[payDialogProvider.activePaymentMethod]
        .payment
        .amountStr;
  }
}
