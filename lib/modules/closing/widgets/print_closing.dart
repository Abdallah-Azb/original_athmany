import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/modules/closing/models.dart/pos.transactions.dart';
import 'package:app/modules/closing/provider/closing.provider.dart';
import 'package:app/modules/closing/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrintClosing extends StatefulWidget {
  final List<PosTransaction> posTransaction;
  final double grandTotal;
  PrintClosing(this.posTransaction, this.grandTotal);
  @override
  _PrintClosingState createState() => _PrintClosingState();
}

class _PrintClosingState extends State<PrintClosing> {
  ClosingProvider closingProvider;
  @override
  Widget build(BuildContext context) {
    closingProvider = Provider.of<ClosingProvider>(context, listen: true);
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width / 3,
      child: TextButton(
        style: widget.posTransaction.length > 0
            ? ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
                backgroundColor: MaterialStateProperty.all(themeColor))
            : ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
                backgroundColor: MaterialStateProperty.all(Colors.black38)),
        child: Text(
          Localization.of(context).tr('print'),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: widget.posTransaction.length > 0
            ? () async {
                await PrintClosingInvoice();
              }
            : null,
      ),
    );
  }

  PrintClosingInvoice() async {
    // await ClosingRepository()
    //     .printInvoice(context, widget.posTransaction, widget.grandTotal);
  }
}
