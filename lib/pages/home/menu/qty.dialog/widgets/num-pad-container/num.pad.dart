import 'package:app/pages/home/menu/qty.dialog/qty.dialog.provider.dart';
import 'package:app/pages/home/num.pad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QtyDialogNumPad extends StatefulWidget {
  const QtyDialogNumPad({Key key}) : super(key: key);

  @override
  _QtyDialogNumPadState createState() => _QtyDialogNumPadState();
}

class _QtyDialogNumPadState extends State<QtyDialogNumPad> {
  @override
  Widget build(BuildContext context) {
    QtyDialogProvider qtyDialogProvider = context.watch<QtyDialogProvider>();
    return NumPad(
      initialAmount: setInitialAmount(),
      getAmount: (String newAmount) {
        qtyDialogProvider.setClearAmount(false);
        qtyDialogProvider.setAmount(newAmount);
      },
    );
  }

  String setInitialAmount() {
    QtyDialogProvider qtyDialogProvider = context.watch<QtyDialogProvider>();
    if (qtyDialogProvider.clearAmount) {
      return '0';
    }
    return qtyDialogProvider.amount;
  }
}
