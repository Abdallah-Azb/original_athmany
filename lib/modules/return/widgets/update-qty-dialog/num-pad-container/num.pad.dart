import 'package:app/modules/return/provider/providers.dart';
import 'package:app/pages/home/num.pad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturnInvoiceUpdateQtyDialogNumPad extends StatefulWidget {
  const ReturnInvoiceUpdateQtyDialogNumPad({Key key}) : super(key: key);

  @override
  _ReturnInvoiceUpdateQtyDialogNumPadState createState() => _ReturnInvoiceUpdateQtyDialogNumPadState();
}

class _ReturnInvoiceUpdateQtyDialogNumPadState extends State<ReturnInvoiceUpdateQtyDialogNumPad> {
  @override
  Widget build(BuildContext context) {
    ReturnUpdateDialogProvider returnUpdateDialogProvider = context.watch<ReturnUpdateDialogProvider>();
    return NumPad(
      initialAmount: setInitialAmount(),
      getAmount: (String newAmount) {
        returnUpdateDialogProvider.setClearAmount(false);
        returnUpdateDialogProvider.setAmount(newAmount);
      },
    );
  }

  String setInitialAmount() {
    ReturnUpdateDialogProvider qtyDialogProvider = context.watch<ReturnUpdateDialogProvider>();
    if (qtyDialogProvider.clearAmount) {
      return '0';
    }
    return qtyDialogProvider.amount;
  }
}
