import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/type_mobile_provider.dart';
import 'package:provider/provider.dart';

import '../invoice.dart';
import '../../../core/extensions/widget_extension.dart';
class SideInvoiceFotter extends StatefulWidget {
  final List<SalesTaxesDetails> salestaxesDetails;
  SideInvoiceFotter({this.salestaxesDetails});
  @override
  _SideInvoiceFotterState createState() => _SideInvoiceFotterState();
}

class _SideInvoiceFotterState extends State<SideInvoiceFotter> {

  String applyDiscountOn;
  hideTotalAmountF() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    this.applyDiscountOn = _prefs.getString('apply_discount_on');
  }

  @override
  void initState() {
    super.initState();
    hideTotalAmountF();
  }
  @override
  Widget build(BuildContext context) {
    return invoiceFotter();
  }

  // invoice fotter
  Widget invoiceFotter() {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            color: isDarkMode == false ? mainBlueColor : Color(0xff1F1F1F),
            child: Column(
              children: [
                // Items Total
                itemsTotal(),
                // DiscountTotal
                totalDiscount(),
                // VAT
                // vat(),
                // Grand Total
                total(),
                // Total After Discount
                // totalAfterDiscount(applyDiscountOn:applyDiscountOn),
                // Number of items
                totalOfItems(),
                // totalOfItems()
              ],
            ).paddingAll(20),
          )
        :
        // ==== Mobile =====
        Container(
            height: MediaQuery.of(context).size.height / 5.5,
            width: typeMobile == TYPEMOBILE.TABLET
                ? 350
                : MediaQuery.of(context).size.width,
            color: isDarkMode == false ? blueGrayColor : mainBlueColorDark,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Items Total
                itemsTotal(size: 14.0),
                // VAT
                vat(size: 14.0),
                // discout
                // totalDiscount(),
                // total
                total(size: 14.0),
                totalAfterDiscount(size: 14,applyDiscountOn:applyDiscountOn),
                totalOfItems(size: 14.0)
              ],
            ).paddingHorizontally(10),
          );
  }

  double invoiceItemsTotal = 0;

  // items total
  Widget itemsTotal({size = 18.0}) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: true);
    double total = 0;
    invoice.currentInvoice.itemsList.forEach((item) {
      double itemTotal = item.rate * item.qty;
      total += itemTotal;
    });
    this.invoiceItemsTotal = total;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Localization.of(context).tr('items_total'),
          // getTranslated(context, 'items_total'),
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(
            InvoiceRepositoryRefactor()
                .calculateInvoice(
                    invoice.currentInvoice.itemsList, widget.salestaxesDetails,discountAmount:invoice.currentInvoice.discountAmount)
                .total
                .toStringAsFixed(2),
            style: TextStyle(fontSize: 18, color: Colors.white))
      ],
    );
  }

  Widget totalAfterDiscount({size = 18.0,String applyDiscountOn}) {
    InvoiceProvider invoice =
    Provider.of<InvoiceProvider>(context, listen: true);
    double totalAfterDisc = InvoiceRepositoryRefactor().calculateInvoice(
        invoice.currentInvoice.itemsList, widget.salestaxesDetails,discountAmount:invoice.currentInvoice.discountAmount,applyDiscountOn: applyDiscountOn )
        .totalWithVat;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Localization.of(context).tr('totalAfterDiscount'),
          // Localization.of(context).tr('items_total'),
          // getTranslated(context, 'items_total'),
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(totalAfterDisc != null ? totalAfterDisc.toStringAsFixed(2): '0.00',
            style: TextStyle(fontSize: 18, color: Colors.white)),
      ],
    );
  }

  double invoiceTotalVat = 0;

  // vat
  Widget vat({size = 18.0}) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: true);
    invoice.currentInvoice.itemsList.forEach((item) {});
    // this.invoiceTotalVat = (total / 100) * widget.rate;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Localization.of(context).tr('vat'),
          // getTranslated(context, 'vat'),
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(
            InvoiceRepositoryRefactor()
                .calculateInvoice(
                  invoice.currentInvoice.itemsList,
                  widget.salestaxesDetails,
                discountAmount:invoice.currentInvoice.discountAmount
                )
                .vat
                .toStringAsFixed(2),
            // Text(this.invoiceTotalVat.toStringAsFixed(2),
            style: TextStyle(fontSize: 18, color: Colors.white,))
      ],
    );
  }

  double invoiceTotalDiscount = 0;

  // discount
  Widget totalDiscount() {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: true);
    invoice.currentInvoice.itemsList.forEach((item) {});
    // this.invoiceTotalDiscount = (total / 100) * widget.rate;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Discount',
          // getTranslated(context, 'discount'),
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        invoice.currentInvoice.additionalDiscountPercentage != null ?
        Text(invoice.currentInvoice.additionalDiscountPercentage != null ? ' ${invoice.currentInvoice.additionalDiscountPercentage}%' : '0.00',
            style: TextStyle(fontSize: 18, color: Colors.white)) :
        Text(invoice.currentInvoice.discountAmount != null ? invoice.currentInvoice.discountAmount.toStringAsFixed(2) : '0.00',
            style: TextStyle(fontSize: 18, color: Colors.white))
      ],
    );
  }

  double invoiceTotal = 0;

  // total
  Widget total({size = 18.0}) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: true);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          Localization.of(context).tr('total'),
          // getTranslated(context, 'total'),
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(
            InvoiceRepositoryRefactor()
                .calculateInvoice(
                  invoice.currentInvoice.itemsList,
                  widget.salestaxesDetails,
                discountAmount:invoice.currentInvoice.discountAmount
                )
                .totalWithVat
                .toStringAsFixed(2),
            style: TextStyle(fontSize: 18, color: Colors.white))
      ],
    );
  }

  List<ItemOption> itemsOptionsWith() {
    List<Item> items =
        context.watch<InvoiceProvider>().currentInvoice.itemsList;
    List<ItemOption> itemOptionsWith = [];
    for (Item item in items) {
      for (ItemOption itemOption in item.itemOptionsWith) {
        if (itemOption.selected) itemOptionsWith.add(itemOption);
      }
    }
    return itemOptionsWith;
  }

  // total of items
  Widget totalOfItems({size = 18.0}) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: true);
    invoice.currentInvoice.itemsList.forEach((item) {});
    // this.invoiceTotalVat = (total / 100) * widget.rate;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Items',
          // getTranslated(context, 'vat'),
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(getTotalOfItems().toString(),
            // Text(this.invoiceTotalVat.toStringAsFixed(2),
            style: TextStyle(fontSize: 18, color: Colors.white))
      ],
    );
  }

  // get total of items
  int getTotalOfItems() {
    int totalOfItems = 0;
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: true);
    for (Item item in invoice.currentInvoice.itemsList) {
      totalOfItems += item.qty;
    }
    return totalOfItems;
  }
}
