import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/item.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../invoice.dart';

class SideInvoiceTop extends StatefulWidget {
  @override
  _SideInvoiceTopState createState() => _SideInvoiceTopState();
}

class _SideInvoiceTopState extends State<SideInvoiceTop> {
  @override
  Widget build(BuildContext context) {
    return topInvoice();
  }

  // top invoie
  Widget topInvoice() {
    InvoiceProvider invoice = Provider.of<InvoiceProvider>(context);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.center,
            width: 350,
            height: 54,
            color: invoice.currentInvoice.docStatus == null
                ? themeColor
                : blueColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    Localization.of(context).tr('invoice_no') +
                        " " +
                        invoice.newId.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    InvoiceProvider invoiceProvider =
                        context.read<InvoiceProvider>();
                    bool state =
                        context.read<InvoiceProvider>().showItemOptions == true
                            ? false
                            : true;
                    invoiceProvider.switchShowItemOptions(state);
                    for (Item item
                        in invoiceProvider.currentInvoice.itemsList) {
                      item.showOptions = invoiceProvider.showItemOptions;
                    }
                  },
                  icon: Icon(
                      context.read<InvoiceProvider>().showItemOptions
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 34,
                      color: Colors.white),
                ),
                Text(
                  invoice.currentInvoice.tableNo == null
                      ? Localization.of(context).tr('take_away')
                      : Localization.of(context).tr('table') +
                          " " +
                          '${invoice.currentInvoice.tableNo}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
        :
        // ==== Mobile ====
        Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.center,
            width: typeMobile == TYPEMOBILE.TABLET
                ? 350
                : MediaQuery.of(context).size.width,
            // height: 54,
            height: 40,
            color: invoice.currentInvoice.docStatus == null
                ? themeColor
                : blueColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    Localization.of(context).tr('invoice_no') +
                        " " +
                        invoice.newId.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    InvoiceProvider invoiceProvider =
                        context.read<InvoiceProvider>();
                    bool state =
                        context.read<InvoiceProvider>().showItemOptions == true
                            ? false
                            : true;
                    invoiceProvider.switchShowItemOptions(state);
                    for (Item item
                        in invoiceProvider.currentInvoice.itemsList) {
                      item.showOptions = invoiceProvider.showItemOptions;
                    }
                  },
                  icon: Icon(
                      context.read<InvoiceProvider>().showItemOptions
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 30,
                      color: Colors.white),
                ),
                Text(
                  invoice.currentInvoice.tableNo == null
                      ? Localization.of(context).tr('take_away')
                      : Localization.of(context).tr('table') +
                          " " +
                          '${invoice.currentInvoice.tableNo}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          );
  }
}
