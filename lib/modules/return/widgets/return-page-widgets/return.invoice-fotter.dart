import 'package:app/models/sales.taxes.details.dart';
import 'package:app/modules/invoice/provider/invoice.provider.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/return/models/return.model.dart';
import 'package:app/modules/return/return.invoice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturnInvoiceFotter extends StatefulWidget {
  final List<SalesTaxesDetails> salestaxesDetails;

  const ReturnInvoiceFotter({Key key, this.salestaxesDetails})
      : super(key: key);

  @override
  _ReturnInvoiceFotterState createState() => _ReturnInvoiceFotterState();
}

class _ReturnInvoiceFotterState extends State<ReturnInvoiceFotter> {
  InvoiceTotal invoiceTotal;

  // getInvoiceTotals() {
  //   this.invoiceTotal = this.calculateInvoice(
  //       context.read<ReturnInvoiceProvider>().returnItems,
  //       widget.salestaxesDetails);
  // }

  TextStyle textStyle() {
    return TextStyle(fontSize: 20);
  }

  @override
  Widget build(BuildContext context) {
    InvoiceProvider invoiceProvider = context.read<InvoiceProvider>();
    this.invoiceTotal = this.calculateInvoice(
        context.read<ReturnInvoiceProvider>().returnItems,
        widget.salestaxesDetails);
    invoiceProvider.returnTotal = this.invoiceTotal.totalWithVat;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          // fotterRow('Invoice Total: ', this.invoiceTotal.total),
          // fotterRow('Invoice Total with VAT: ', this.invoiceTotal.totalWithVat),
          fotterRow('Total return amount: ', this.invoiceTotal.totalWithVat),
        ],
      ),
    );
  }

  Container fotterRow(String title, double value) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: Text(
              title,
              style: textStyle(),
            ),
          ),
          Container(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value.toStringAsFixed(2),
                  style: textStyle(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // get invioce totals
  InvoiceTotal calculateInvoice(
      List<ReturnItem> returnItems, List<SalesTaxesDetails> salestaxesDetails) {
    double itemOptionsPriceTotal = 0;

    for (ReturnItem returnItem in returnItems) {
      for (ReturnItemOption returnItemOption in returnItem.returnItemOptions
          .where((element) => element.optionWith == 1)) {
        itemOptionsPriceTotal +=
            returnItemOption.priceListRate * returnItem.returnQty;
      }
    }

    // // get itemsPriceTotal
    double itemsPriceTotal = itemOptionsPriceTotal;
    returnItems.forEach((returnItem) {
      itemsPriceTotal += returnItem.rate * returnItem.returnQty;
    });

    double vat = 0;
    double netTotal = itemsPriceTotal;
    double totalWithVat = 0;
    double rate = 0;

    salestaxesDetails
        .forEach((t) => {if (t.includedInPrintRate == 1) rate += t.rate});

    if (rate > 0) netTotal = ((itemsPriceTotal * 100.0) / (100.0 + rate));

    for (int i = 0; i < salestaxesDetails.length; i++) {
      switch (salestaxesDetails[i].chargeType) {
        case "On Net Total":
          double taxAmount = netTotal * salestaxesDetails[i].rate / 100;
          vat += taxAmount;
          totalWithVat = netTotal + vat;
          break;
      }
    }

    return InvoiceTotal(
      total: itemsPriceTotal,
      vat: vat,
      totalWithVat: totalWithVat,
    );
  }

  // // get invioce totals
  // InvoiceTotal calculateInvoice(
  //     List<ReturnItem> returnItems, List<SalesTaxesDetails> salestaxesDetails) {
  //   double itemOptionsPriceTotal = 0;

  //   for (ReturnItem returnItem in returnItems) {
  //     for (ReturnItemOption returnItemOption in returnItem.returnItemOptions
  //         .where((element) => element.optionWith == 1)) {
  //       itemOptionsPriceTotal += returnItemOption.priceListRate *
  //           ((returnItem.qty * -1) - returnItem.returnQty);
  //     }
  //   }

  //   // // get itemsPriceTotal
  //   double itemsPriceTotal = itemOptionsPriceTotal;
  //   returnItems.forEach((returnItem) {
  //     itemsPriceTotal +=
  //         returnItem.rate * ((returnItem.qty * -1) - returnItem.returnQty);
  //   });

  //   double vat = 0;
  //   double netTotal = itemsPriceTotal;
  //   double totalWithVat = 0;
  //   double rate = 0;

  //   salestaxesDetails
  //       .forEach((t) => {if (t.includedInPrintRate == 1) rate += t.rate});

  //   if (rate > 0) netTotal = ((itemsPriceTotal * 100.0) / (100.0 + rate));

  //   for (int i = 0; i < salestaxesDetails.length; i++) {
  //     switch (salestaxesDetails[i].chargeType) {
  //       case "On Net Total":
  //         double taxAmount = netTotal * salestaxesDetails[i].rate / 100;
  //         vat += taxAmount;
  //         totalWithVat = netTotal + vat;
  //         break;
  //     }
  //   }

  //   return InvoiceTotal(
  //     total: itemsPriceTotal,
  //     vat: vat,
  //     totalWithVat: totalWithVat,
  //   );
  // }
}
