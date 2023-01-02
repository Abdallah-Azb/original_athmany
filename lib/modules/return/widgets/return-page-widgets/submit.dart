import 'package:app/core/enums/doc.status.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/models/item.dart';
import 'package:app/modules/invoice/models/invoice.dart';
import 'package:app/modules/invoice/provider/invoice.provider.dart';
import 'package:app/modules/return/models/return.model.dart';
import 'package:app/modules/return/return.invoice.dart';
import 'package:app/providers/home.provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturnSubmit extends StatefulWidget {
  ReturnInvoice data;
  Invoice invoice;
  String applyDiscountOn;
  BuildContext context;
  ReturnSubmit({this.data, this.invoice, this.applyDiscountOn, this.context});
  @override
  _ReturnSubmitState createState() => _ReturnSubmitState();
}

class _ReturnSubmitState extends State<ReturnSubmit> {
  String name;
  bool _isButttonDisable = false;
  bool checkItemsQty() {
    bool submit = false;
    ReturnInvoiceProvider returnInvoiceProvider =
        context.read<ReturnInvoiceProvider>();
    for (ReturnItem returnItem in returnInvoiceProvider.returnItems) {
      if ((returnItem.qty * -1) - returnItem.returnQty !=
          (returnItem.qty * -1)) {
        submit = true;
      }
    }
    return submit;
  }

  @override
  Widget build(BuildContext context) {
    ReturnInvoiceProvider returnInvoiceProvider =
        context.read<ReturnInvoiceProvider>();
    InvoiceProvider invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      width: double.infinity,
      child: TextButton(
        style: checkItemsQty()
            ? _isButttonDisable
                ? ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black38))
                : ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(themeColor))
            : ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black38)),
        child: Text(
          "Submit",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () async {
          // submit(widget.invoice, returnInvoiceProvider, widget.applyDiscountOn);
          print("isbutt :: ${_isButttonDisable}");
          setState(() {
            _isButttonDisable = true;
          });
          print("isbutt :: ${_isButttonDisable}");
          name = await invoiceProvider.submitReturnInvoice(
            context,
            isDarkMode,
            widget.invoice,
            returnInvoiceProvider,
            widget.applyDiscountOn,
          );
        },
      ),
    );
  }

  // Future<void> submit(
  //   Invoice invoice,
  //   ReturnInvoiceProvider returnInvoiceProvider,
  //   String applyDiscountOn,
  // ) async {
  //   bool isDarkMode =
  //       Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  //
  //   InvoiceProvider invoiceProvider =
  //       Provider.of<InvoiceProvider>(context, listen: false);
  //   Invoice currentInvoice = context.read<InvoiceProvider>().currentInvoice;
  //
  //   var i = 0;
  //   List<Item> returnedItems = [];
  //   for (i; i < returnInvoiceProvider.returnItems.length; i++) {
  //     if (returnInvoiceProvider.returnItems[i].returnQty != 0) {
  //       currentInvoice.itemsList[i].qty =
  //           returnInvoiceProvider.returnItems[i].returnQty * -1;
  //       currentInvoice.itemsList[i].rate =
  //           returnInvoiceProvider.returnItems[i].rate;
  //       returnedItems.add(currentInvoice.itemsList[i]);
  //     }
  //   }
  //
  //   // assign current itemsList to currentReturnInvoice
  //   currentInvoice.itemsList = returnedItems;
  //   invoiceProvider.setInvoice(currentInvoice);
  //
  //   await invoiceProvider.payReturn(
  //     context,
  //     isDarkMode,
  //     applyDiscountOn,
  //   );
  // }
}
